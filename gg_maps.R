d <- data.frame(model$fitted.values, df$price) %>% 
  mutate(df.price = log(df.price),
    pred_res = ((df.price - model.fitted.values)/model.fitted.values)*100)%>% 
  select(pred_res)


d %>% head(20)
d$res_coded<-replace(d$pred_res,d$pred_res<(-1),8)
d$res_coded<-replace(d$res_coded,d$pred_res>=-1,7)
d$res_coded<-replace(d$res_coded,d$pred_res>=-0.4,6)
d$res_coded<-replace(d$res_coded,d$pred_res>=-0.1,5)
d$res_coded<-replace(d$res_coded,d$pred_res>=0,4)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.1,3)
d$res_coded<-replace(d$res_coded,d$pred_res>=0.4,2)
d$res_coded<-replace(d$res_coded,d$pred_res>=1,1)


df <- df %>% 
  mutate(pred_res = d$res_coded)
df %>% colnames()

df$pred_res <- as.factor(df$pred_res)
 
bboxPrague <- c(14.25, 49.959, 14.69, 50.165)
ggMapPrague <- get_map(location = bboxPrague, source = "osm", maptype = "toner", crop = TRUE, zoom = 12, messaging = T)

df[ ,2] <- df[ ,2] + runif(min = -10E-4, max = 10E-4, dim(df)[1])
df[ ,3] <- df[ ,3] + runif(min = -10E-4, max = 10E-4, dim(df)[1])

ggmap(ggMapPrague) + 
  geom_point(data = df, aes(x = df$gps.lon, y = df$gps.lat, color = df$pred_res), size = 2, alpha = 0.35) + 
  #scale_color_brewer(palette="RdYlGn") +
  stat_density2d(data=df, mapping=aes(x=df$gps.lon, y=df$gps.lat, fill=df$pred_res), geom="polygon", alpha = 0.005, fill = "#FC4E07") + 
  scale_color_brewer(palette="RdYlGn") +
  my_theme + 
  theme(legend.position = "none") + 
  facet_wrap(~"Shluková analýza Reziduí")

ggsave("C:/Users/petr7/Desktop/net.pdf", height = 10, width = 10)
