
rm(list = ls())

library(tidyverse)
library(stargazer)
library(knitr)
library(kableExtra)
library(quantreg)
library(spdep)
library(ggmap)
library(stargazer)
library(leaflet)

# Téma na ggplot
# my_theme <- 
#   theme_light() + 
#   theme(
#     plot.title = element_text(size = 16, face = "bold"),
#     axis.text = element_text(size = 10),
#     axis.title = element_text(size = 14),
#     axis.title.y = element_text(face = "bold", size = 12),
#     axis.title.x = element_text(face = "bold", size = 12),
#     legend.text = element_text(size = 10),
#     legend.title = element_text(size = 12),
#     panel.border = element_rect(colour = "gray35", fill=NA, size= 1.7),
#     panel.grid.major = element_line(colour = "lightgrey"),
#     legend.position = "bottom",
#     legend.direction = "vertical",
#     strip.background = element_rect(fill = "gray91", color =  "black"),
#     strip.text = element_text(color = "black"))

my_theme <- 
  theme_light() + 
  theme(
    plot.title = element_text(size = 16, face = "bold", family = "serif"),
    axis.text = element_text(size = 12, family="serif"),
    axis.title = element_text(size = 14, family="serif"),
    axis.title.y = element_text(face = "bold", size = 12, family="serif"),
    axis.title.x = element_text(face = "bold", size = 12, family="serif"),
    legend.text = element_text(size = 10, family="serif"),
    legend.title = element_text(size = 12, family="serif"),
    panel.border = element_rect(colour = "gray35", fill=NA, size= 1.7),
    panel.grid.major = element_line(colour = "lightgrey"),
    legend.position = "bottom",
    legend.direction = "vertical",
    strip.background = element_rect(fill = "gray91", color =  "black"),
    strip.text = element_text(color = "black", size = 12.5, family = "serif"))



setwd("C:/Users/petr7/OneDrive/ŠKOLA/PROSTOROVÉ BYTY")

#-------------------------------------#
######### Datasets loading  #########
#-------------------------------------#

df <- read.csv("Dataset_Filtered_cleaned.csv", sep = ",")


df %>% 
  dplyr::select(price, Meters, Rooms, Mezone, KK, panel, balcony_or_terrase, novostavba) %>%
  head() %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)




#### Distribuce promìnných
df %>% 
  dplyr::select(price, Meters, Rooms, Mezone, KK, panel, balcony_or_terrase, novostavba) %>% reshape2::melt() %>% 
  ggplot(aes(x = value)) + 
  geom_histogram(aes(fill = variable), color = "black") + 
  facet_wrap(~variable, scales = "free") + 
  scale_alpha_continuous() + 
  my_theme + 


#### Korelace mezi promìnnými

df %>% 
  dplyr::select(price, Meters, Rooms, Mezone, KK, panel, balcony_or_terrase, novostavba) %>% cor() %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

# Ke všem souøadnicím pøièteme malé náhodné èíslo, aby byla každá unikátní...

CORD = cbind(df$gps.lon, df$gps.lat)
CORD[ ,1] <- CORD[ ,1] + runif(min = -10E-4, max = 10E-4, dim(CORD)[1])
CORD[ ,2] <- CORD[ ,2] + runif(min = -10E-4, max = 10E-4, dim(CORD)[1])

bboxPrague <- c(14.22,49.94,14.71,50.18)
ggMapPrague <- get_map(location = bboxPrague, source = "osm",maptype = "terrain", crop = TRUE, zoom = 12)

ggmap(ggMapPrague) + 
  geom_point(data = df, aes(x = CORD[ ,1], y = CORD[ ,2]), color = "black", size = 0.75, alpha = 0.7) + 
  theme(legend.justification=c(0, 1), legend.position=c(0.05, 0.95),
        legend.text=element_text(size=7), legend.title=element_text(size=7),
        legend.key.size = unit(0.2, "cm"),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.box.background = element_rect(colour = "black", size = 0.05)
  ) +
  xlab(" ") + 
  ylab(" ") + 
  ggtitle("Distribuce pozorování")


KME <- kmeans(CORD, 5)
df$KMEAN = KME$cluster

MAPA <- df %>% select(gps.lon, gps.lat, KMEAN)
colnames(MAPA) = c("x", "y", "v")

ggmap(ggMapPrague) + 
  geom_point(data = MAPA, aes(x = x, y = y, color = factor(v)), size = 1.3) + 
  stat_ellipse(data= MAPA, aes(x=x, y=y, fill=factor(v)),
               geom="polygon", level=0.95, alpha=0.25) + 
  theme(legend.position = "none", 
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) + 
  ylab(" ") + 
  xlab(" ") + 
  ggtitle("Clusterování lokalit pražských bytù")


formula <- as.formula(log(price) ~ Rooms + log(Meters)  + Mezone + KK + panel + balcony_or_terrase + novostavba)


model <- lm(formula, data = df)
model_quant <- rq(formula, data = df)

#model_quant %>% summary(se = "boot")

KME <- kmeans(CORD, 5)
df$KMEAN = KME$cluster

model_kmeans <- lm(log(price) ~ Rooms + log(Meters)  + Mezone + KK + panel + balcony_or_terrase + novostavba + factor(KMEAN), df)

model_quant_kmean <- rq(log(price) ~ Rooms + log(Meters)  + Mezone + KK + panel + balcony_or_terrase + novostavba + factor(KMEAN), data = df)

stargazer(model, model_kmeans, model_quant, model_quant_kmean,
          type="html", 
          column.labels=c("OLS",
                          "OLS - kmeans",
                          "Quant reg.",
                          "Quant reg. - Kmeans"),
          omit.stat = c("rsq", "f")
)


gg_quant_sensitivyti <- function(lm_model, quant_models, ncol = 3) {
  
  A <- quant_models %>% broom::tidy(se  ="boot")
  B <- lm_model %>% broom::tidy()
  
  left_join(A, B, by = "term") %>% 
    #filter(!grepl("factor", term)) %>%   
    #filter(!grepl("Intercept", term)) %>%
    ggplot(aes(tau, estimate.x)) + 
    geom_point(color="#27408b", size = 3) +
    geom_line(color="#27408b", size = 1)+
    geom_hline(aes(yintercept = estimate.y), color  = "red") +
    geom_hline(aes(yintercept = estimate.y + 1.96*std.error.y), linetype = 2, color = "red", alpha = 0.65)  +
    geom_hline(aes(yintercept = estimate.y - 1.96*std.error.y), linetype = 2, color = "red", alpha = 0.65)  +
    geom_ribbon(aes(ymin=estimate.y - 1.96*std.error.y,ymax=estimate.y + 1.96*std.error.y),alpha=0.09, fill="red") +
    geom_ribbon(aes(ymin=conf.low,ymax=conf.high),alpha=0.25, fill="#27408b") + 
    facet_wrap(~term, scales = "free", ncol = ncol)
}

model_quant_10 <- rq(formula, data = df, tau = 1:9/10)

gg_quant_sensitivyti(model, model_quant_10) + 
  my_theme +
  ggtitle("Porovnání OLS a kvantilové regrese")


cns <- knearneigh(CORD, k=4, longlat=T) 
scnsn <- knn2nb(cns, row.names = NULL, sym = T) 
W <- nb2listw(scnsn)

moran <- 
  cbind(
    moran.test(df$price, W)[[3]][[1]],
    moran.test(df$price, W)[[3]][[3]], 
    moran.test(df$price, W)[[2]]
  ) %>% 
  data.frame(row.names = " ")

colnames(moran) = c("I Statistic", "Variance", "p-value")
moran %>%   
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


#### Maximální poètu sousedù (7 jednotky):

cns <- knearneigh(CORD, k=7, longlat=T) 
scnsn <- knn2nb(cns, row.names = NULL, sym = T) 
W <- nb2listw(scnsn)

moran <- 
  cbind(
    moran.test(df$price, W)[[3]][[1]],
    moran.test(df$price, W)[[3]][[3]], 
    moran.test(df$price, W)[[2]]
  ) %>% 
  data.frame(row.names = " ")

colnames(moran) = c("I-Statistic", "Variance", "p-value")
moran %>%   
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


#### Maximální vzdálenosti (500 metrù):

cns <- dnearneigh(CORD, d1=0, d2=0.5, longlat = T)
W <- nb2listw(cns, zero.policy = TRUE)

moran <- 
  cbind(
    moran.test(df$price, W, zero.policy = T)[[3]][[1]],
    moran.test(df$price, W, zero.policy = T)[[3]][[3]], 
    moran.test(df$price, W, zero.policy = T)[[2]]
  ) %>% 
  data.frame(row.names = " ")

colnames(moran) = c("I-Statistic", "Variance", "p-value")
moran %>%   
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


#### Maximální vzdálenosti (900 metrù):

cns <- dnearneigh(CORD, d1=0, d2=0.9, longlat = T)
W <- nb2listw(cns, zero.policy = TRUE)

moran <- 
  cbind(
    moran.test(df$price, W, zero.policy = T)[[3]][[1]],
    moran.test(df$price, W, zero.policy = T)[[3]][[3]], 
    moran.test(df$price, W, zero.policy = T)[[2]]
  ) %>% 
  data.frame(row.names = " ")

colnames(moran) = c("I-Statistic", "Variance", "p-value")
moran %>%   
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

cns <- knearneigh(CORD, k=7, longlat=T) 
scnsn <- knn2nb(knearneigh(CORD, k=7, longlat=T), row.names = NULL, sym = T) 


W <- nb2listw(knn2nb(knearneigh(CORD, k=1, longlat=T), row.names = NULL, sym = T))



spatial.err <- errorsarlm(formula, data=df, nb2listw(knn2nb(knearneigh(CORD, k=1, longlat=T), row.names = NULL, sym = T)))


spatial.lag <- lagsarlm(formula, data=df, W)
summary(spatial.lag)

data.frame(
  OLS = c(model %>% AIC, model %>% logLik(), cor(model$fitted.values, log(df$price))^2,
          nrow(df)),
  
  OLS_Kmeans = c(model_kmeans %>% AIC, model_kmeans %>% logLik(), cor(model_kmeans$fitted.values, log(df$price))^2,
                 nrow(df)),
  
  Quantile = c(model_quant %>% AIC, model_quant %>% logLik(), cor(model_quant$fitted.values, log(df$price))^2,
               nrow(df)),
  
  Quantile_Kmeans = c(model_quant_kmean %>% AIC, model_quant_kmean %>% logLik(), cor(model_quant_kmean$fitted.values, log(df$price))^2, 
                      nrow(df)),
  
  Spatial.Error = c(spatial.err %>% AIC, spatial.err %>% logLik(), cor(spatial.err$fitted.values, log(df$price))^2,
                    nrow(df)),
  
  Spatial.Lag = c(spatial.lag %>% AIC, spatial.lag %>% logLik(), cor(spatial.lag$fitted.values, log(df$price))^2,
                  nrow(df)),
  
  row.names = c("AIC", "Log-like.", "R", "n")
) %>% 
  round(3) %>%
  #stargazer(type = "text", summary = F, title = "Metriky modelu", flip = F)
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


OLS <- data.frame(
  fitted = model$fitted.values,
  residuals = model$residuals
) %>% mutate(
  actual = fitted + residuals, 
  model = "OLS"
) %>% 
  select(actual, model, fitted, residuals)

Quant_Req <- data.frame(
  fitted = model_quant$fitted.values,
  residuals = model_quant$residuals
) %>% mutate(
  actual = fitted + residuals, 
  model = "Quantile"
) %>% 
  select(actual, model, fitted, residuals)

Spatial_error <- data.frame(
  fitted = spatial.err$fitted.values,
  residuals = spatial.err$residuals
) %>% mutate(
  actual = fitted + residuals, 
  model = "Spatial Error"
) %>% 
  select(actual, model, fitted, residuals)

Spatial_Lag <- data.frame(
  fitted = spatial.lag$fitted.values,
  residuals = spatial.lag$residuals
) %>% mutate(
  actual = fitted + residuals, 
  model = "Spatial Lag"
) %>% 
  select(actual, model, fitted, residuals)

complete_diag = rbind(OLS, Quant_Req, Spatial_error, Spatial_Lag)
complete_diag <- complete_diag %>% arrange(residuals) %>% tail(11920)


ggplot(complete_diag, aes(x = actual, y = fitted)) + 
  geom_point(aes(colour = residuals), size = 2, alpha = 1) + 
  facet_wrap(model~.) +
  geom_abline(intercept = 0, slope = 1, size = 1, colour = "#FC4E07") + 
  my_theme + 
  ggtitle("Porovnání Predikení schopnosti modelu") + 
  theme(legend.justification=c(0, 1), legend.position=c(0.05, 0.95),
        legend.text=element_text(size=7), legend.title=element_text(size=7),
        legend.key.size = unit(0.6, "cm"),
        legend.box.background = element_rect(colour = "black", size = 0.75)
  ) 


#### Histogram reziduí

ggplot(complete_diag, aes(x = residuals)) + 
  geom_histogram(bins = 25, color = "#FC4E07", fill = "#00AFBB") + 
  #scale_fill_brewer() +
  facet_wrap(model~.) +
  my_theme +
  ggtitle("Porovnání Predikení schopnosti modelu") + 
  theme(legend.justification=c(0, 1), legend.position=c(0.05, 0.95),
        legend.text=element_text(size=7), legend.title=element_text(size=7),
        legend.key.size = unit(0.6, "cm"),
        legend.box.background = element_rect(colour = "black", size = 0.75)
  ) 


d = 
  data.frame(model$fitted.values, df$price) %>% 
  mutate(df.price = df.price,
         model.fitted.values = exp(model.fitted.values),
         pred_res = ((abs(model.fitted.values - df.price))/model.fitted.values)) %>% 
  select(pred_res)

d$res_coded<-replace(d$res_coded,d$pred_res>=0,6)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.05,5)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.15,4)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.25,3)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.5,2)
d$res_coded<-replace(d$res_coded,d$pred_res>=.75,1)
d$res_coded<-replace(d$res_coded,d$pred_res>=1,0)



ggmap(ggMapPrague) + 
  
  geom_point(data = df, aes(x = CORD[ ,1], y = CORD[ ,2], color = factor(d$res_coded)),
             size = 2, alpha = 0.70) +
  
  theme(legend.justification=c(0, 1), legend.position=c(0.05, 0.95),
        legend.text=element_text(size=7), legend.title=element_text(size=7),
        legend.key.size = unit(0.2, "cm"),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.box.background = element_rect(colour = "black", size = 0.05)
  ) +
  xlab(" ") + 
  ylab(" ") + 
  scale_color_brewer(palette="RdYlGn",name="Residua (%)",labels = c("[100;+inf)","[75;100)","[50;75)","[25;50)","[15;25)","[5;15)", "[0;5)")) + 
  ggtitle("Shluková Analýza Reziduí") + 
  guides(fill = guide_legend(override.aes = list(alpha = 1))) 


d = 
  data.frame(spatial.err$fitted.values, df$price) %>% 
  mutate(df.price = df.price,
         model.fitted.values = exp(spatial.err.fitted.values),
         pred_res = ((abs(model.fitted.values - df.price))/model.fitted.values)) %>% 
  select(pred_res)

d$res_coded<-replace(d$res_coded,d$pred_res>=0,6)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.05,5)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.15,4)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.25,3)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.5,2)
d$res_coded<-replace(d$res_coded,d$pred_res>=.75,1)
d$res_coded<-replace(d$res_coded,d$pred_res>=1,0)



ggmap(ggMapPrague) + 
  
  geom_point(data = df, aes(x = CORD[ ,1], y = CORD[ ,2], color = factor(d$res_coded)),
             size = 1, alpha = 0.70) +
  
  theme(legend.justification=c(0, 1), legend.position=c(0.05, 0.95),
        legend.text=element_text(size=7), legend.title=element_text(size=7),
        legend.key.size = unit(0.2, "cm"),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.box.background = element_rect(colour = "black", size = 0.05)
  ) +
  xlab(" ") + 
  ylab(" ") + 
  scale_color_brewer(palette="RdYlGn",name="Residua (%)",labels = c("[100;+inf)","[75;100)","[50;75)","[25;50)","[15;25)","[5;15)", "[0;5)")) + 
  ggtitle("Shluková Analýza Reziduí") + 
  guides(fill = guide_legend(override.aes = list(alpha = 1))) 

