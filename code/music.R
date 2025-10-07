
remotes::install_github("charlie86/spotifyr")
devtools::install_github("charlie86/spotifyr")
packageVersion("httr")
library(spotifyr)
library(httr)
library(httpuv)
##### API #####
Sys.setenv(SPOTIFY_CLIENT_ID = 'cd4b929444c6424b98fc181c2d59233a')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'a464e07a149d4f509cc841668ff5f6c3')
Sys.setenv(SPOTIFY_REDIRECT_URI = "https://example.com/callback")
print(Sys.getenv("SPOTIFY_CLIENT_ID"))
print(Sys.getenv("SPOTIFY_CLIENT_SECRET"))
print(Sys.getenv("SPOTIFY_REDIRECT_URI"))


auth_url <- paste0(
  "https://accounts.spotify.com/authorize?",
  "response_type=code&",
  "client_id=", Sys.getenv("SPOTIFY_CLIENT_ID"), "&",
  "redirect_uri=", URLencode(Sys.getenv("SPOTIFY_REDIRECT_URI"), reserved = TRUE), "&",
  "scope=user-library-read"
)
browseURL(auth_url)
response <- POST(
  url = 'https://accounts.spotify.com/api/token',
  authenticate(Sys.getenv("SPOTIFY_CLIENT_ID"), Sys.getenv("SPOTIFY_CLIENT_SECRET")),
  body = list(
    grant_type = 'authorization_code',
    code = 'AQDtY6D52lIPC_AbXpBobUv0FKAqzlrTeE6lIqr3ZqRZeyJK5cCKigXDN_HCYVMglstP_eNegQ5I0bwj4BIj1pqiC3vgtUfaCw8g5DH_WG4nSFmrmDjIeOX7IvWC7hnP8oAWu1fD0ykwUsbQgeLfNLzBz9VyhgAPeaEI8nf4m1e5HBCX0n96jvrF7HAj9rRTf_FO',
    redirect_uri = Sys.getenv("SPOTIFY_REDIRECT_URI")
  ),
  encode = 'form'
)

token_data <- content(response)
print(token_data)

res <- GET(
  url = "https://api.spotify.com/v1/me/tracks",
  add_headers(Authorization = paste0("Bearer ", "BQAM-XXCthuq5JSjfUlSJaikEIUqdAiVxrzGYSosWje6YWNafqhw950dbFlXkmGkVndlesC1S6JRcomXD6aQ9RHRwFtmWnCd-NAiFd_PyvJZcEAOi4fAmAp_mD672AzbY4DMHWj0xh3YTGucBM2XI7thVqDCp2qNzye_qZHaOltP5D3RQWkcQvQdlEMSBV9UZOs4YKqLi-e2P2LZSw0cHAzelpwoPbrAyAz3Uw5Pl0B7FNBjokS-7QlFErWriq8"))
)

content(res)














svt <- search_spotify("Seventeen", type = "artist")
svt_id <- svt$id[1]  # 通常第一個就是官方的

# 抓取所有歌曲（包括 EP、單曲、專輯）
seventeen_tracks <- get_artist_audio_features(svt_id)

# 篩選出常見的分析變數
seventeen_data <- seventeen_tracks %>%
  select(track_name, album_name, release_date,
         danceability, energy, valence, tempo,
         speechiness, acousticness, instrumentalness, duration_ms)

# 看前幾筆
head(seventeen_data)


##### mind ####
spotify <- read.csv("spotify_songs.csv")

library(readr)
library(dbplyr)
spotify <- read_csv("spotify_songs.csv")
diamonds %>% filter(carat > 2, price < 14000)
