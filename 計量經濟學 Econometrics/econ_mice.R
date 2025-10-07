
econ <- read.csv("econ2025.csv")
library(tidyr)
library(dplyr)
library(plm)
library(mice)
econ <- read.csv("econ2025.csv")
names(econ)[names(econ) == "Foreign direct investment, net (BoP, current US$)"] <- "FDI"


##### 補值 #####
num_vars <- names(Filter(is.numeric, econ))
num_vars <- setdiff(num_vars, c("Country", "Year"))

econ_filled <- econ %>%
  group_by(Country) %>%
  mutate(across(all_of(num_vars), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .))) %>%
  ungroup()

colSums(is.na(econ_filled))

##### 選取 #####
econ <- econ_filled %>%
  select(-c('Foreign.direct.investment..net.inflows....of.GDP.','law')) %>%
  drop_na()
# 取 log
econ <- econ %>%
  mutate(
    log_Taxes = log(Taxes),
    log_Population = log(Population),
    log_Military = log(militaryexpenditure)
  ) %>%
  select(-Taxes, -Population, -militaryexpenditure)
# 確保一下都是 numeric
econ <- econ %>%
  mutate(across(-c(Country, Year), ~ {
    if (is.factor(.)) as.numeric(as.character(.)) else .
  }))
# 轉成 panel 形式
econ_panel <- pdata.frame(econ, index = c("Country", "Year"))

# 簡化一下
vars <- setdiff(names(econ_panel), c("Foreign.direct.investment..net..BoP..current.US..", "Country", "Year"))
reg_func <- as.formula(paste("Foreign.direct.investment..net..BoP..current.US.. ~", paste(vars, collapse = " + ")))

# 檢查共變異
cor_mat <- cor(econ_panel[, vars], use = "pairwise.complete.obs")
which(abs(cor_mat) > 0.95 & abs(cor_mat) < 1, arr.ind = TRUE)

# 檢查 variety
variety <- sapply(econ[vars], var, na.rm = TRUE)
variety





##### entity FE #####
country.lm <- plm(reg_func, data = econ_panel, model = "within", effect = "individual")
summary(country.lm)


##### time FE #####
year.lm <- plm(reg_func, data = econ_panel, model = "within", effect = "time")
summary(year.lm)

#### both FE #####
tw.lm <- plm(reg_func,data = econ_panel, model = "within", effect = "twoways")
summary(tw.lm)



##### linear reg. #####
vars1 <- setdiff(names(econ), c("Foreign.direct.investment..net..BoP..current.US..", "Country", "Year"))
colSums(is.na(econ[, vars1]))
reg_func1 <- as.formula(paste("Foreign.direct.investment..net..BoP..current.US..  ~", paste(vars1, collapse = " + ")))
lm1 <- lm(reg_func1, data = econ)
summary(lm1)
step_lm1 <- step(lm1, direction = "both")
summary(step_lm1)

library(lmtest)
library(sandwich)
# robust
coeftest(country.lm, vcov = vcovHC(country.lm, type = "HC1"))
# cluster
coeftest(country.lm, vcov = vcovHC(country.lm, type = "HC1", cluster = "group"))
# both
coeftest(country.lm, vcov = vcovHC(country.lm, method = "arellano", type = "HC1", cluster = "group"))

cluster_se <- vcovHC(country.lm, type = "HC1", cluster = "group")
coeftest(country.lm, cluster_se)
