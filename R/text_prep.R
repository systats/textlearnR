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
  
  tokenizer <- text_tokenizer(num_words = x$input_dim, lower = F, split = " ", char_level = F)
  fit_text_tokenizer(tokenizer, x$text_train)
  
  x$x_train <- tokenizer %>% 
    texts_to_sequences(x$text_train) %>%
    pad_sequences(maxlen = x$seq_len)
  
  x$x_test <- tokenizer %>% 
    texts_to_sequences(x$text_test) %>%
    pad_sequences(maxlen = x$seq_len)
  
  return(x)
}