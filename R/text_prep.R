#' transform_text
#' 
#' @param long_runs one parameter per row
#' 
#' @export
reshape_runs <- function(long_runs){
  suppressWarnings(
    long_runs %>% 
      ### spread each run seperatly
      split(.$timestamp) %>% 
      purrr::map_dfr(~{
        .x %>% 
          dplyr::select(id, model_name, data, param, value, timestamp) %>% 
          tidyr::spread(param, value) 
      }) %>% 
      ### cast as numeric if possible
      mutate_if(function(x) !is.na(sum(as.numeric(x))), as.numeric) %>%
      ### append each model's step and whether it performed best within the run
      group_by(id) %>% 
      mutate(step = as.numeric(as.factor(timestamp))) %>% 
      mutate(best = ifelse(test_acc == max(test_acc), T, F)) %>%
      ungroup %>% 
      ### arrange by data and performance
      arrange(data, desc(test_acc)) %>% 
      ### regex backend and clean model_name
      mutate(backend = model_name %>% str_extract("textlearnR::.*?_") %>% str_remove_all("textlearnR::|\\_")) %>% 
      mutate(model_name = model_name %>% str_remove("textlearnR::keras_"))
  )
}

#' transform_text
#' 
#' @param x a list of parameters (and data)
#' 
#' @export

transform_text <- function(x){
  
  ## only perform if sequences are not delivered
  if(is.null(x$x_train)){
    
    tokenizer <- text_tokenizer(num_words = x$input_dim, lower = F, split = " ", char_level = F)
    fit_text_tokenizer(tokenizer, x$text_train)
    
    x$x_train <- tokenizer %>% 
      texts_to_sequences(x$text_train) %>%
      pad_sequences(maxlen = x$seq_len)
    
    x$x_test <- tokenizer %>% 
      texts_to_sequences(x$text_test) %>%
      pad_sequences(maxlen = x$seq_len)
  }
  
  return(x)
}


#' transform_features
#' 
#' @param x is a text string
#' 
#' @export
transform_features <- function(x){
  text <- tibble(text = x) %>% 
    #tidytext::unnest_tokens(sentence, text, token = "sentences", to_low = F) %>%
    mutate(id = 1:n()) %>%
    tidytext::unnest_tokens(word, text, token = "words", to_low = F) %>%
    group_by(id) %>% 
    mutate(tid = 1:n()) %>%
    ungroup 
  #cnlp_annotate(as_strings = T) %>% 
  #.$token %>% 
  #filter(!upos %in% c("PUNCT", "DET"), tid != 0) %>% 
  #select(id, sid, tid, word, lemma)
  
  ngram <- text %>%
    group_by(id) %>%
    summarise(
      text_word = paste(word, collapse = " ")
      #text_lemma = paste(lemma, collapse = " ")
    ) %>%
    ungroup %>% 
    #mutate(text_lemma = text_lemma %>% str_remove("\\|")) %>%
    tidytext::unnest_tokens(ngram, text_word, token = "ngrams", n = 5, to_low = F) %>%
    group_by(id) %>%
    mutate(tid = 1:n())
  
  out <- text %>% 
    left_join(ngram) %>% 
    mutate(ngram = ifelse(is.na(ngram), word, ngram))
  
  return(out)
}  
