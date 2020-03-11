rm(list = ls())
set.seed(010)
#Smazeme cele prostředí...

-------------------------------------
######### Packages loading #########
-------------------------------------

library(tidyverse)
library(quantreg)
library(spdep)
library(ggmap)
library(stargazer)
library(kableExtra)

-------------------------------------
####### Always set directory ########
-------------------------------------



-------------------------------------
######### Datasets loading  #########
-------------------------------------

df <- read.csv("Dataset_Filtered_cleaned.csv", sep = ",")
df %>% head
df %>% colnames()
df %>% select(gps.lon, gps.lat) %>% plot()

-------------------------------------
######### Latex summary table #######
-------------------------------------

df[ ,4:12] %>% stargazer::stargazer(type = "text", flip = T)



-------------------------------------
######### General Formula #########
-------------------------------------
formula <- as.formula(log(price) ~ Rooms + Meters + I(Rooms^2) + Mezone + KK + panel + balcony_or_terrase + novostavba)


-------------------------------------
######## OLS and Quant model ########
-------------------------------------
model <- lm(formula, data = df)
model_quant <- rq(formula, data = df)


model %>% summary()
model_quant %>% summary(se = "boot")



-------------------------------------
######## Bootstrap std. OLS #########
-------------------------------------
rep = 500
bs.coeffs <- matrix(NA, nrow = rep, ncol = 9)
for (b in 1:rep) {
bs.model = lm(formula,
  data=df,
  subset=sample(nrow(df), size = nrow(df), replace=TRUE))
bs.coeffs[b, ] = bs.model$coef
}

VCE.bootstrap = cov(bs.coeffs)

lmtest::coeftest(model, VCE.bootstrap)


-------------------------------------
###### Quantile sensitivity #########
-------------------------------------


rq(data=df, 
   tau= 1:9/10,
   formula = formula) %>%
  broom::tidy(se.type = "boot") %>%
  #filter(!grepl("Intercept", term)) %>%
  #filter(!grepl("factor", term)) %>%
  ggplot(aes(x=tau,y=estimate))+
  geom_point(color="#27408b", size = 3)+ 
  geom_line(color="#27408b", size = 1)+ 
  geom_smooth(method=  "lm", colour = "red", se = T, fill = "red", alpha = 0.15) +  
  facet_wrap(~term, scales="free", ncol=3) + 
  geom_ribbon(aes(ymin=conf.low,ymax=conf.high),alpha=0.25, fill="#27408b") + 
  #my_theme +
  ggtitle("Quantile and OLS comparison")



-------------------------------------
##### Adding small rand. number #####
-------------------------------------
  
CORD = cbind(df$gps.lon, df$gps.lat)
CORD[ ,1] %>% unique() %>% length()
CORD[ ,1] <- CORD[ ,1] + runif(min = -10E-4, max = 10E-4, dim(CORD)[1])
CORD[ ,2] <- CORD[ ,2] + runif(min = -10E-4, max = 10E-4, dim(CORD)[1])
CORD[ ,1] %>% unique() %>% length()



-------------------------------------
####### Kmean of Coordinates ########
-------------------------------------

KME <- kmeans(CORD, 3)
df$KMEAN = KME$cluster

purrr::map(set_names(3:6), ~kmeans(CORD, .x)) %>% 
  purrr::map(broom::augment, CORD) %>% 
  imap(~mutate(.x, num_clust = .y)) %>% 
  bind_rows() %>% 
  ggplot(aes(X1, X2)) + 
  geom_point(aes(color = .cluster)) + 
  stat_ellipse(aes(x=X1, y=X2, fill=factor(.cluster)),
               geom="polygon", level=0.95, alpha=0.2) + 
  facet_wrap(~num_clust) + 
  theme(legend.position = "none")



model_kmeans <- lm(log(price) ~ Rooms + Meters + I(Rooms^2) + Mezone + KK + panel + balcony_or_terrase + novostavba + factor(KMEAN), df)
model_kmeans %>% summary()


stargazer::stargazer(model, 
                     model_kmeans, 
                     model_quant, type = "text")


-------------------------------------
### Clustering residuals from OLS ###
-------------------------------------


d = 
  data.frame(model$fitted.values, df$price) %>% 
  mutate(df.price = df.price,
         model.fitted.values = exp(model.fitted.values),
         pred_res = ((abs(model.fitted.values - df.price))/model.fitted.values)) %>% 
  select(pred_res)

d %>% head()
d$res_coded<-replace(d$res_coded,d$pred_res>=0,6)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.05,5)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.15,4)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.25,3)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.5,2)
d$res_coded<-replace(d$res_coded,d$pred_res>=.75,1)
d$res_coded<-replace(d$res_coded,d$pred_res>=1,0)

d %>% sample_n(12)
d %>% head

d %>% 
  ggplot(aes(res_coded)) + 
  geom_bar() + 
  geom_vline(xintercept = mean(d$res_coded), color = "red")  + 
  ggtitle("Sloupcový graf kategorií reziduí")

d$res_coded<-factor(d$res_coded)




-------------------------------------
##### Spatial Models - W_matrix #####
# Distance - matrix
-------------------------------------
cns <- dnearneigh(CORD, d1=0, d2=0.9, longlat = T)
summary(cns)
plot(cns, CORD, col = "red")
W <- nb2listw(cns, zero.policy = TRUE)
plot(W, CORD)

-------------------------------------
  ##### Spatial Models - W_matrix #####
# NN - matrix
-------------------------------------
cns <- knearneigh(CORD, k=4, longlat=T) 
scnsn <- knn2nb(cns, row.names = NULL, sym = T) 
W <- nb2listw(scnsn)


-------------------------------------
###### DataFrame from W_matrix ######
# For ggplot 
-------------------------------------

data_df <- data.frame(CORD)
colnames(data_df) <- c("long", "lat")

n = length(attributes(W$neighbours)$region.id)
from <- rep(1:n,sapply(W$neighbours,length))
to <- unlist(W$neighbours)[]
weight <- numeric(length(to))
weight[which(to != 0)] <- unlist(W$weights)
DA = data.frame(from = from, to = to, weight = weight)
DA <- DA[DA$to != 0,]
DA = cbind(DA, data_df[DA$from,], data_df[DA$to,])

colnames(DA)[4:7] = c("long","lat","long_to","lat_to")


plot(CORD)
plot(W, coordinates(CORD), add = T, col = "red")


-------------------------------------
########## Map of Prague  ###########
-------------------------------------

bboxPrague <- c(14.22,49.94,14.71,50.18)
ggMapPrague <- get_map(location = bboxPrague, source = "osm",maptype = "terrain", crop = TRUE, zoom = 12)

 ggmap(ggMapPrague) + 
   geom_point(data = df, aes(x = CORD[ ,1], y = CORD[ ,2], color = factor(d$res_coded)),
              size = 0.6, alpha = 0.70) +
  
  # geom_point(data = df, aes(x = CORD[ ,1], y = CORD[ ,2]),
  #            size = 0.6, alpha = 0.70) +
  # 
  #  geom_segment(data = DA, aes(xend = long_to, yend = lat_to, x = DA$long, y = DA$lat), size=0.5, color = "red") +

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


setwd("C:/Users/petr7/Desktop")
ggsave("net.pdf", height = 7, width = 7)



-------------------------------------
##### Spatial Autocorr. testing #####
-------------------------------------
moran.test(df$price, W)
lm.morantest(model, W)[1]

moran.plot(log(df$price), W)
lm.LMtests(model, W, test=c("LMlag", "LMerr", "RLMlag", "RLMerr")) %>% 
  summary()


-------------------------------------
######## Lag and Error models #######
-------------------------------------
spatial.err <- errorsarlm(formula, data=df, W)
summary(spatial.err)

spatial.lag <- lagsarlm(formula, data=df, W)
summary(spatial.lag)

save.image(file="Spatial.err.RData")
save.image(file="Spatial.lag.RData")
-------------------------------------
####### All in-sample metrics #######
### latex table
-------------------------------------

data.frame(
  OLS = c(model %>% AIC, model %>% logLik(), cor(model$fitted.values, log(df$price))^2, nrow(df)),
  Quantile = c(model_quant %>% AIC, model_quant %>% logLik(), cor(model_quant$fitted.values, log(df$price))^2, nrow(df)),
  Spatial.Error = c(spatial.err %>% AIC, spatial.err %>% logLik(), cor(spatial.err$fitted.values, log(df$price))^2, nrow(df)),
  Spatial.Lag = c(spatial.lag %>% AIC, spatial.lag %>% logLik(), cor(spatial.lag$fitted.values, log(df$price))^2, nrow(df)),
  row.names = c("AIC", "Log-like.", "R", "n")
) %>%
  #stargazer(type = "text", summary = F, title = "Metriky modelu")
  kable() %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

-------------------------------------
#### Data Frames for all models #####
# OLS, Quant, Error, Lag
-------------------------------------

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
  #scale_fill_brewer() +
  facet_wrap(model~.) +
  geom_abline(intercept = 0, slope = 1, size = 1, colour = "#FC4E07") + 
#  my_theme2 + 
  ggtitle("Porovnání Predikèní schopnosti modelù") + 
  theme(legend.justification=c(0, 1), legend.position=c(0.05, 0.95),
        legend.text=element_text(size=7), legend.title=element_text(size=7),
        legend.key.size = unit(0.6, "cm"),
        legend.box.background = element_rect(colour = "black", size = 0.75)
  ) 


-------------------------------------
####### Latex of all models #########
-------------------------------------
capture.output(
  summary(model),
  summary(model_quant),
  summary(model_kmeans),
  summary(spatial.lag),
  summary(spatial.err),
  
file = "A.txt"
)
