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
toxic_dat <- read_csv("train.csv") %>% 
  glimpse

set.seed(2019)
split_id <- sample(c(T, F), size = nrow(toxic_dat), prob = c(.9,.1), replace = T)

train <- toxic_dat %>% 
  filter(split_id) %>% 
  mutate(split = (toxic + severe_toxic + obscene + threat + insult + identity_hate) > 0) %>% 
  #count(toxic)
  split(.$split) %>% 
  map2_dfr(c(50000, 14.599), ~{
    .x %>% sample_n(.y)
  }) %>% 
  arrange(sample(1:n(), n())) %>% 
  select(split)

text_train <- train$comment_text

y_train <- train %>% 
  select(toxic:identity_hate) %>%
  as.matrix

test <- toxic_dat %>% 
  filter(!split_id) %>% 
  group_by(toxic) %>% 
  sample_n(1532) %>% 
  ungroup %>% 
  arrange(sample(1:n(), n()))

text_test <- test$comment_text

y_test <- test %>% 
  select(toxic:identity_hate) %>% 
  as.matrix

toxic_dat <- list(
  text_train = text_train, 
  text_test = text_test, 
  y_train = y_train, 
  y_test = y_test
)

toxic_dat %>% glimpse
#save(toxic_dat, file = "toxic_dat.Rdata")
```

    ## List of 4
    ##  $ text_train: chr [1:93762] "Martyman is a sad little man with no penis and he enjoys sucking penis. \n\n is a sad little man with no penis "| __truncated__ "\"\nNo, you utter RETARD! HISPANIC MEANS FROM SPAIN! Mexicans are not hispanic, only idiot, uneducated yanks ca"| __truncated__ "\"\n\n Edit request on 14 September 2012 \n\nPLEASE CHANGE \"\"Armstrong's family announced he would be buried "| __truncated__ "\"Bias\n\nThe following seems to be irrelevant and biased.\n\n\"\"These popular psychology tricksters often emp"| __truncated__ ...
    ##  $ text_test : chr [1:3064] "\"give me other \"\"favours\"\". Call me again soon... ;)\"" "\"\nIt does indeed seem in my annoyance, I over-stepped. Thanks for stepping in. DocHeuh  \"" "Mostrim?\n\nAnybody know when the name Edgeworthstown was put on the town? It is still very commonly known by t"| __truncated__ "Materazzi is Italy's disgrace. The vistory of Italy come to nothing, it did not have any value because of Materazzi." ...
    ##  $ y_train   : num [1:93762, 1:6] 1 1 0 0 0 0 0 0 0 1 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:6] "toxic" "severe_toxic" "obscene" "threat" ...
    ##  $ y_test    : num [1:3064, 1:6] 0 0 0 1 0 0 1 1 0 0 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:6] "toxic" "severe_toxic" "obscene" "threat" ...
