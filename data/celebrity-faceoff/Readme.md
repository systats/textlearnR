Celebrity-Faceoff Dataset
================

-   [taken from jlacko github](https://github.com/jlacko/celebrity-faceoff)

The underlying dataset consits of 9,000 tweets, collected on 2019-02-02 via rtweet. It consists of 1,500 tweets each from

-   Hadley Wickham,
-   Wes McKinney,
-   François Chollet,
-   Kim Kardashian,
-   Kourtney Kardashian,
-   Khloe Kardashian

From each account 1,200 tweets (80%) are included in training dataset and 300 (20%) in verification set.

``` r
pacman::p_load(tidyverse)

tweets <- read_csv("train_tweets.csv") %>% 
  mutate(split = "train") %>% 
  bind_rows(read_csv("test_tweets.csv")) %>% 
  glimpse
```

    ## Parsed with column specification:
    ## cols(
    ##   id = col_double(),
    ##   name = col_character(),
    ##   created = col_datetime(format = ""),
    ##   text = col_character()
    ## )
    ## Parsed with column specification:
    ## cols(
    ##   id = col_double(),
    ##   name = col_character(),
    ##   created = col_datetime(format = ""),
    ##   text = col_character()
    ## )

    ## Observations: 9,000
    ## Variables: 5
    ## $ id      <dbl> 1.091806e+18, 1.091806e+18, 1.091798e+18, 1.091776e+18, …
    ## $ name    <chr> "hadleywickham", "hadleywickham", "KimKardashian", "hadl…
    ## $ created <dttm> 2019-02-02 21:11:49, 2019-02-02 21:09:52, 2019-02-02 20…
    ## $ text    <chr> "@dvaughan32 Fails to mention that code can only ever ex…
    ## $ split   <chr> "train", "train", "train", "train", "train", "train", "t…

``` r
tweets %>% count(split)
```

    ## # A tibble: 2 x 2
    ##   split     n
    ##   <chr> <int>
    ## 1 train  7200
    ## 2 <NA>   1800

``` r
#save(tweets, file = "tweets.Rdata")
```
