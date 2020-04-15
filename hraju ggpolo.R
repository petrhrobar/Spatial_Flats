library(tidyverse)


mtcars %>% 
  gather("key", "value", -hp) %>% 
  ggplot(aes(hp, value)) + 
  geom_point() +
  facet_wrap(~key, scales = "free"
             )


mtcars %>% 
  ggplot(aes(hp, carb))+  
  geom_point()
