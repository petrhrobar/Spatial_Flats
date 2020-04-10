rmarkdown::render("Flats_Presentation.Rmd")


########################################################### #
#########             Spatial Stability             #########
########################################################### #
df <- read.csv("Dataset_Filtered_cleaned.csv", sep = ",")


CORD = cbind(df$gps.lon, df$gps.lat)
CORD[ ,1] <- CORD[ ,1] + runif(min = -10E-4, max = 10E-4, dim(CORD)[1])
CORD[ ,2] <- CORD[ ,2] + runif(min = -10E-4, max = 10E-4, dim(CORD)[1])


s2.df <- data.frame(NN= 0, 
                    AIC= 0, 
                    LL= 0, 
                    Intercept= 0, 
                    Rooms= 0, 
                    log_Meters = 0, 
                    Mezone = 0, 
                    KK = 0, 
                    panel =0, 
                    balcony_or_terrase = 0, 
                    novostavba = 0, 
                    Lambda = 0, 
                    Intercept_SE = 0, 
                    Rooms_SE= 0, 
                    log_Meters_SE = 0, 
                    Mezone_SE = 0, 
                    KK_SE = 0, 
                    panel_SE =0, 
                    balcony_or_terrase_SE = 0, 
                    novostavba_SE = 0, 
                    Lambda_SE = 0
                    )



for (k in seq(2, 40, by = 2)) {
  message(paste("Právě probíhá", k, "Sousedů"))
  scnsn <- knn2nb(knearneigh(CORD, k=k, longlat=T), row.names = NULL, sym = T) 
  W <- nb2listw(scnsn)
  spatial.err <- errorsarlm(formula, data=df, W)

s2.df <- rbind(
  s2.df,
  c(
  NN = k,
  AIC(spatial.err), 
  logLik(spatial.err), 
  spatial.err$coefficients[1],
  spatial.err$coefficients[2],
  spatial.err$coefficients[3],
  spatial.err$coefficients[4],
  spatial.err$coefficients[5],
  spatial.err$coefficients[6],
  spatial.err$coefficients[7],
  spatial.err$coefficients[8],
  spatial.err$lambda, 
  spatial.err$rest.se[1],
  spatial.err$rest.se[2],
  spatial.err$rest.se[3], 
  spatial.err$rest.se[4],
  spatial.err$rest.se[5], 
  spatial.err$rest.se[6], 
  spatial.err$rest.se[7],
  spatial.err$rest.se[8], 
  spatial.err$lambda.se
)
)

}

gg_AIC <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, AIC)) + 
    geom_line(color = "royalblue", size = 0.85) + 
    facet_wrap(~"AIC") + 
    my_theme

gg_LL <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, LL)) + 
  geom_line(color = "royalblue", size = 0.85) + 
  facet_wrap(~"Log-likelihood") + 
  my_theme



gg_lambda <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, Lambda)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=Lambda - 1.96*Lambda_SE, ymax=Lambda + 1.96*Lambda_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =Lambda - 1.96*Lambda_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =Lambda + 1.96*Lambda_SE), color = "red", linetype = 2) + 
  facet_wrap(~"Lambda") + 
  my_theme

gg_Intercept <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, Intercept)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=Intercept - 1.96*Intercept_SE, ymax=Intercept + 1.96*Intercept_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =Intercept - 1.96*Intercept_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =Intercept + 1.96*Intercept_SE), color = "red", linetype = 2) + 
  facet_wrap(~"Intercept") + 
  my_theme
    
gg_Rooms <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, Rooms)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=Rooms - 1.96* Rooms_SE, ymax=Rooms + 1.96* Rooms_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =Rooms + 1.96* Rooms_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =Rooms - 1.96* Rooms_SE), color = "red", linetype = 2) + 
  facet_wrap(~"Rooms") + 
  my_theme

gg_log_meters <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, log_Meters)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=log_Meters - 1.96 * log_Meters_SE, ymax=log_Meters + 1.96 * log_Meters_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =log_Meters + 1.96 * log_Meters_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =log_Meters - 1.96 * log_Meters_SE), color = "red", linetype = 2) + 
  facet_wrap(~"log_Meters") + 
  my_theme

gg_Mezone <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, Mezone)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=Mezone - 1.96 * Mezone_SE, ymax=Mezone + 1.96 * Mezone_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =Mezone + 1.96 * Mezone_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =Mezone - 1.96 * Mezone_SE), color = "red", linetype = 2) + 
  facet_wrap(~"Mezone") + 
  my_theme

gg_KK <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, KK)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=KK - 1.96 * KK_SE, ymax=KK + 1.96 * KK_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =KK + 1.96 * KK_SE), color = "red", linetype= 2) + 
  geom_line(aes(y =KK - 1.96 * KK_SE), color = "red", linetype= 2) + 
  facet_wrap(~"KK") + 
  my_theme

gg_panel <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, panel)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=panel - 1.96 * panel_SE, ymax=panel + 1.96 * panel_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =panel + 1.96 * panel_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =panel - 1.96 * panel_SE), color = "red", linetype = 2) + 
  facet_wrap(~"panel") + 
  my_theme


gg_balcon <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, balcony_or_terrase)) + 
  geom_line(color = "royalblue", size= 0.85)  + 
  geom_ribbon(aes(ymin=balcony_or_terrase - 1.96 * balcony_or_terrase_SE, ymax=balcony_or_terrase + 1.96 * balcony_or_terrase_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =balcony_or_terrase + 1.96 * balcony_or_terrase_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =balcony_or_terrase - 1.96 * balcony_or_terrase_SE), color = "red", linetype = 2) + 
  facet_wrap(~"balcony_or_terrase") + 
  my_theme

gg_novo <- 
  s2.df[-1, ] %>% 
  ggplot(aes(NN, novostavba)) + 
  geom_line(color = "royalblue", size = 0.85)  + 
  geom_ribbon(aes(ymin=novostavba - 1.96 * novostavba_SE, ymax=novostavba + 1.96 * novostavba_SE),alpha=0.09, fill="red") +
  geom_line(aes(y =novostavba + 1.96 * novostavba_SE), color = "red", linetype = 2) + 
  geom_line(aes(y =novostavba - 1.96 * novostavba_SE), color = "red", linetype = 2) + 
  facet_wrap(~"novostavba") + 
  my_theme

A <- 
  gridExtra::grid.arrange(
  gg_AIC,
  gg_LL,
  gg_lambda, 
  gg_Intercept, 
  gg_Rooms,
  gg_log_meters, 
  gg_Mezone,
  gg_KK,
  gg_panel,
  gg_balcon, 
  gg_novo,
  top=textGrob("Vývoj koeficientů pro různé relace sousednosti",gp=gpar(fontsize=15,font="serif"))
  )
  

ggsave("PLOTS_PDFs/spatial_sensiv.pdf", height = 8, width = 11, A)  
