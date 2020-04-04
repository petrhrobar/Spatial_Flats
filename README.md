Spatial Model - Flat Market of Prague
================
Petr Hrobař

In this study we apply ***Spatial Econometrics models*** and evaluate
flats prices. We suppose that **price** of the flat is not only the
function of flat’s own characteristics but also function of its
neighbourhood characteristics.

  - Firstly we test for spatial dependency
  - Then applying spatial models

<!-- end list -->

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 3.6.3

    ## -- Attaching packages --------------------------------------------------------- tidyverse 1.3.0 --

    ## <U+221A> ggplot2 3.2.1     <U+221A> purrr   0.3.3
    ## <U+221A> tibble  2.1.3     <U+221A> dplyr   0.8.3
    ## <U+221A> tidyr   1.0.0     <U+221A> stringr 1.4.0
    ## <U+221A> readr   1.3.1     <U+221A> forcats 0.4.0

    ## Warning: package 'ggplot2' was built under R version 3.6.2

    ## Warning: package 'tibble' was built under R version 3.6.1

    ## Warning: package 'tidyr' was built under R version 3.6.1

    ## Warning: package 'readr' was built under R version 3.6.1

    ## Warning: package 'purrr' was built under R version 3.6.3

    ## Warning: package 'dplyr' was built under R version 3.6.2

    ## Warning: package 'stringr' was built under R version 3.6.2

    ## Warning: package 'forcats' was built under R version 3.6.1

    ## -- Conflicts ------------------------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()
