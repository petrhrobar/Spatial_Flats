library(tidyverse)

df <- read.csv("C:/Users/petr7/OneDrive/ŠKOLA/PROSTOROVÉ BYTY/pragueflats.csv", sep = ";")
df %>% head
df %>% colnames()
df$name <- df$name %>% substring(13)

df <- 
  df %>% 
  mutate(Rooms = map_dbl(name,  ~
                           str_extract(.x, "^\\d+\\+\\d*") %>% 
                           str_replace("\\+$", "+0") %>% 
                           rlang::parse_expr(.) %>% 
                           eval ), 
         Meters = str_extract(name, "(?<=\\s)\\d+(?=Â)"),
         Mezone = +(str_detect(name, "Mezone")),
         new_building = +(str_detect(labelsAll, "new_building")),
         metro = +(str_detect(labelsAll, "metro")),
         terrace_balcony = +(str_detect(labelsAll, "terrace")),
         terrace_balcony = +(str_detect(labelsAll, "balcony")),
         panel = +(str_detect(labelsAll, "panel")),
         brick = +(str_detect(labelsAll, "brick")),
         parking_lots = +(str_detect(labelsAll, "parking_lots")), 
         KK = +(str_detect(name, "kk")))

df %>% head()

dataset <- df %>% 
  select(gps.lon, 
         gps.lat,
         price,
         Rooms, Meters,
         Mezone,
         new_building,
         metro,
         terrace_balcony,
         panel,
         KK,
         brick,
         parking_lots
         )

dataset$Meters <- as.numeric(dataset$Meters)
dataset %>% select(-gps.lon, -gps.lat) %>% reshape2::melt() %>% 
  ggplot(aes(x = value)) + 
  geom_histogram(aes(fill = variable), bins = 15, color = "black") + 
  facet_wrap(~variable, scales = "free", ncol = 3)



modeldata <- dataset %>% select(-gps.lon, -gps.lat)
lm(price ~., modeldata) %>% summary()

