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
save(toxic_dat, file = "toxic_dat.Rdata")
```
