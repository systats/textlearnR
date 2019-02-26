Democrat Vs. Republican Tweets
================

-   [Kaggle Challange](https://www.kaggle.com/kapastor/democratvsrepublicantweets)

Extracted tweets from all of the representatives (latest 200 as of May 17th 2018)

``` r
pacman::p_load(tidyverse)
demrep_dat <- read_csv("ExtractedTweets.csv") %>% 
  glimpse
```

    ## Parsed with column specification:
    ## cols(
    ##   Party = col_character(),
    ##   Handle = col_character(),
    ##   Tweet = col_character()
    ## )

    ## Observations: 86,460
    ## Variables: 3
    ## $ Party  <chr> "Democrat", "Democrat", "Democrat", "Democrat", "Democrat…
    ## $ Handle <chr> "RepDarrenSoto", "RepDarrenSoto", "RepDarrenSoto", "RepDa…
    ## $ Tweet  <chr> "Today, Senate Dems vote to #SaveTheInternet. Proud to su…

``` r
#write_rds(toxic_dat, path = "toxic_dat.rds")
#save(demrep_dat, file = "demrep_dat.Rdata")
```
