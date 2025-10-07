library(tidyr)
library(dplyr)
library(mice)
library(plm)

econ <- read.csv("econ2025.csv")
names(econ)[names(econ) == "Foreign direct investment, net (BoP, current US$)"] <- "FDI"

##### 變數處理 #####
econ <- econ %>%
  mutate(
    log_Taxes = log(Taxes + 1),
    log_Population = log(Population + 1),
    log_Military = log(militaryexpenditure + 1)
  )

econ_mice <- econ %>%
  select(CPI, GDP.growth, GDP.per.capita, Labor.force.participation.rate,
         Political.Stability, controlofcorruption, regulatoryquality, unemployment,
         log_Taxes, log_Population, log_Military)

##### mice補值 #####
imp <- mice(econ_mice, m = 5, method = "pmm", seed = 123)

imputed_data <- complete(imp, 1)

# 補值與原始合併
imputed_data$FDI <- econ$Foreign.direct.investment..net..BoP..current.US..
imputed_data$Country <- econ$Country
imputed_data$Year <- econ$Year
econ_panel <- pdata.frame(imputed_data, index = c("Country", "Year"))

##### 回歸模型 #####
vars <- setdiff(names(econ_panel), c("FDI", "Country", "Year"))
reg_func <- as.formula(paste("FDI ~", paste(vars, collapse = " + ")))


country.lm <- plm(reg_func, data = econ_panel, model = "within", effect = "individual")
summary(country.lm)

year.lm <- plm(reg_func, data = econ_panel, model = "within", effect = "time")
summary(year.lm)

tw.lm <- plm(reg_func, data = econ_panel, model = "within", effect = "twoways")
summary(tw.lm)


vars1 <- setdiff(names(imputed_data), c("FDI", "Country", "Year"))
colSums(is.na(imputed_data[, vars1]))
reg_func1 <- as.formula(paste("FDI ~", paste(vars1, collapse = " + ")))
lm1 <- lm(reg_func1, data = imputed_data)
summary(lm1)
step_lm1 <- step(lm1, direction = "both")
summary(step_lm1)


library(car)
vif(lm1)
econ_cor <- econ %>%
  select(log_Military, Political.Stability, regulatoryquality, controlofcorruption) %>%
  mutate(across(everything(), as.numeric))

cor(econ_cor, use = "pairwise.complete.obs")



##### robust & cluster SE #####
install.packages("lmtest")     
install.packages("sandwich")   
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
