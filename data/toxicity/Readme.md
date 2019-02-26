Toxic Comment Classification
================

-   [Kaggle Challange](https://www.kaggle.com/c/jigsaw-toxic-comment-classification-challenge/data)

You are provided with a large number of Wikipedia comments which have been labeled by human raters for toxic behavior. The types of toxicity are:

-   `toxic`
-   `severe_toxic`
-   `obscene`
-   `threat`
-   `insult`
-   `identity_hate`

You must create a model which predicts a probability of each type of toxicity for each comment.

``` r
pacman::p_load(tidyverse)
toxic_dat <- read_csv("train.csv") %>% 
  glimpse
```

    ## Parsed with column specification:
    ## cols(
    ##   id = col_character(),
    ##   comment_text = col_character(),
    ##   toxic = col_double(),
    ##   severe_toxic = col_double(),
    ##   obscene = col_double(),
    ##   threat = col_double(),
    ##   insult = col_double(),
    ##   identity_hate = col_double()
    ## )

    ## Observations: 159,571
    ## Variables: 8
    ## $ id            <chr> "0000997932d777bf", "000103f0d9cfb60f", "000113f07…
    ## $ comment_text  <chr> "Explanation\nWhy the edits made under my username…
    ## $ toxic         <dbl> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1,…
    ## $ severe_toxic  <dbl> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ obscene       <dbl> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ threat        <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ insult        <dbl> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ identity_hate <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…

``` r
#save(toxic_dat, file = "toxic_dat.Rdata")
```
