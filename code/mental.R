library(dplyr)
library(magrittr)
mental <- read.csv("mxmh_survey.csv")
mental <- mental %>% filter(Music.effects == "Improve")

mental <- mental %>%
  mutate(Group = case_when(
    Anxiety > 5.84 ~ "HighAnxiety",
    Depression > 4.8 ~ "HighDepression",
    Insomnia > 3.74 ~ "HighInsomnia",
    OCD > 2.6 ~ "HighOCD"
  ))

mental <- na.omit(mental)
convert_freq <- function(x) {
  recode(x,
         "Never" = 1,
         "Rarely" = 2,
         "Sometimes" = 3,
         "Very frequently" = 4)
}
genre_vars <- grep("Frequency", names(mental), value = TRUE)
mental_df <- mental %>%
  mutate(across(all_of(genre_vars), convert_freq, .names = "num_{.col}")) %>%
  mutate(BPM = as.numeric(BPM)) 

mental_df <- na.omit(mental_df)



##### 分組 #####
vars_num <- grep("^num_", names(mental_df), value = TRUE)

genre_summary <- mental_df %>%
  group_by(Group) %>%
  summarise(across(all_of(c("BPM", vars_num)), ~mean(., na.rm = TRUE))) %>%
  ungroup()
write.csv(genre_summary, "genre_summary.csv", row.names = FALSE)

##### 回歸 #####
vars <- setdiff(names(econ_panel), c("FDI", "Country", "Year"))
reg_func <- as.formula(paste("FDI ~", paste(vars, collapse = " + ")))

lm_Metal <- lm(num_Frequency..Metal. ~ Anxiety + Depression + Insomnia + OCD, data = mental_df)
summary(lm_Metal)

lm_Classical <- lm(num_Frequency..Classical. ~ Anxiety + Depression + Insomnia + OCD, data = mental_df)
summary(lm_Classical)

lm.Country <- lm(num_Frequency..Country. ~ Anxiety + Depression + Insomnia + OCD, data = mental_df)
summary(lm_Country)

lm.EDM <- lm(num_Frequency..EDM. ~ Anxiety + Depression + Insomnia + OCD, data = mental_df)
summary(lm_EDM)

lm.Folk <- lm(num_Frequency..Folk. ~ Anxiety + Depression + Insomnia + OCD, data = mental_df)
summary(lm_Folk)


##### 不確定 #####
genre_num <- grep("^num_Frequency", names(mental_df), value = TRUE)

results <- lapply(genre_num, function(genre) {
  formula <- as.formula(paste(genre, "~ Anxiety + Depression + Insomnia + OCD"))
  model <- lm(formula, data = mental_df)
  coef(summary(model))
})
names(results) <- genre_num
##### 大家一起回歸 #####
x_vars <- c("Anxiety", "Depression", "Insomnia", "OCD")
y_vars <- grep("^num_Frequency", names(mental_df), value = TRUE)
results <- lapply(y_vars, function(y) {
  formula <- as.formula(paste(y, "~", paste(x_vars, collapse = " + ")))
  model <- lm(formula, data = mental_df)
  coef(summary(model))
})

##### 選歌 #####
library(dplyr)
library(magrittr)
library(readr)
spotify <- read.csv("spotify_songs.csv")
high <- spotify %>% filter(
    danceability >= 0.50 & danceability <= 0.80,
    energy >= 0.53 & energy <= 0.83)

high_anxiety_songs <- spotify %>%
  filter(
    instrumentalness >= 0 & instrumentalness <= 0.17,
    speechiness >= 0.10 & speechiness <= 0.40
  )

high_anxiety_insomnia_songs <- spotify %>%
  filter(
    danceability >= 0.35 & danceability <= 0.65,
    speechiness >= 0.00 & speechiness <= 0.18
  )
stress_sample <- high %>% slice_sample(n = 20)
anxiety_sample <- high_anxiety_songs %>% slice_sample(n = 20)
insomnia_sample <- high_anxiety_insomnia_songs %>% slice_sample(n = 20)

# 全面高壓型
cat("【全面高壓型 隨機 20 首】\n")
high %>%
  slice_sample(n = 20) %>%
  pull(track_name) %>%
  print()

# 高憂慮型
cat("\n【高憂慮型 隨機 20 首】\n")
high_anxiety_songs %>%
  slice_sample(n = 20) %>%
  pull(track_name) %>%
  print()

# 高憂慮失眠型
cat("\n【高憂慮失眠型 隨機 20 首】\n")
high_anxiety_insomnia_songs %>%
  slice_sample(n = 20) %>%
  pull(track_name) %>%
  print()

 ##### 選歌單 30 首 #####
library(dplyr)
song <- read.csv("songs.csv")
# --- 全面高壓型條件 ---
high_pressure <- song %>%
  filter(
    danceability >= 0.55 & danceability <= 0.75,
    energy >= 0.45 & energy <= 0.75,
    valence >= 0.55 & valence <= 0.85,
    tempo >= 100 & tempo <= 130
  ) %>%
  slice_sample(n = 30)

# --- 高憂慮型條件 ---
high_anxiety <- song %>%
  filter(
    danceability >= 0.65 & danceability <= 0.80,
    energy >= 0.67 & energy <= 0.75,
    valence >= 0.35 & valence <= 0.65,
    speechiness >= 0.25 & speechiness <= 0.40,
    tempo >= 85 & tempo <= 115
  ) %>%
  slice_sample(n = 30)

# --- 高憂慮失眠型條件 ---
high_anxiety_insomnia <- song %>%
  filter(
    energy >= 0.85 & energy <= 1.00,
    danceability >= 0.45 & danceability <= 0.60,
    valence >= 0.35 & valence <= 0.65,
    tempo >= 100 & tempo <= 130
  ) %>%
  slice_sample(n = 30)

# --- 合併並加上群體標籤（可選）---
selected_songs <- bind_rows(
  high_pressure %>% mutate(Group = "全面高壓型"),
  high_anxiety %>% mutate(Group = "高憂慮型"),
  high_anxiety_insomnia %>% mutate(Group = "高憂慮失眠型")
)

# --- 查看結果（只看歌名與群體）---
selected_songs %>% select(Group, track_name)
# --- 全面高壓型 ---
cat("【全面高壓型】\n")
cat(paste0("[", 1:30, "] ", high_pressure$track_name, " - ", high_pressure$track_artist), sep = "\n")

# --- 高憂慮型 ---
cat("\n【高憂慮型】\n")
cat(paste0("[", 1:30, "] ", high_anxiety$track_name, " - ", high_anxiety$track_artist), sep = "\n")

# --- 高憂慮失眠型 ---
cat("\n【高憂慮失眠型】\n")
cat(paste0("[", 1:30, "] ", high_anxiety_insomnia$track_name, " - ", high_anxiety_insomnia$track_artist), sep = "\n")
