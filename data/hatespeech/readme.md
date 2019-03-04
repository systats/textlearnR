Automated Hate Speech Detection
================

[Paper Github](https://github.com/t-davidson/hate-speech-and-offensive-language)

-   `count` number of CrowdFlower users who coded each tweet (min is 3, sometimes more users coded a tweet when judgments were determined to be unreliable by CF).
-   `hate_speech` number of CF users who judged the tweet to be hate speech.
-   `offensive_language` = number of CF users who judged the tweet to be offensive.
-   `neither` = number of CF users who judged the tweet to be neither offensive nor non-offensive.
-   `class` = class label for majority of CF users. 0 - hate speech 1 - offensive language 2 - neither

You must create a model which predicts a probability of each type of toxicity for each comment.

``` r
pacman::p_load(tidyverse)
hate_dat <- read_csv("labeled_data.csv") %>% 
  rename(id = X1) %>%
  glimpse
```

    ## Warning: Missing column names filled in: 'X1' [1]

    ## Parsed with column specification:
    ## cols(
    ##   X1 = col_double(),
    ##   count = col_double(),
    ##   hate_speech = col_double(),
    ##   offensive_language = col_double(),
    ##   neither = col_double(),
    ##   class = col_double(),
    ##   tweet = col_character()
    ## )

    ## Observations: 24,783
    ## Variables: 7
    ## $ id                 <dbl> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,…
    ## $ count              <dbl> 3, 3, 3, 3, 6, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, …
    ## $ hate_speech        <dbl> 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, …
    ## $ offensive_language <dbl> 0, 3, 3, 2, 6, 2, 3, 3, 3, 2, 3, 3, 2, 3, 2, …
    ## $ neither            <dbl> 3, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, …
    ## $ class              <dbl> 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
    ## $ tweet              <chr> "!!! RT @mayasolovely: As a woman you shouldn…

``` r
# write_rds(toxic_dat, path = "toxic_dat.rds")
# save(toxic_dat, file = "hate_dat")
```
