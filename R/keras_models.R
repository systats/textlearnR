#' get_keras_model
#' 
#' @param x a list of parameters
#' 
#' @export
get_keras_model <- function(x){
  
  updated_params <- x$model %>%
    ### Model arguments
    args() %>% 
    as.list %>% 
    compact %>%
    ### Update model defaults
    imap(~{
      if(.y %in% names(x)){
        return(x[[.y]])
      } else {
        return(.x)
      }
    })
  
  x$model_final <- do.call(x$model, updated_params)
  
  is_not_provided <- names(updated_params) %in% names(x)
  add_params <- updated_params[!is_not_provided] %>% compact
  x <- c(x, add_params)
  
  return(x)
}

#' compile_keras_model
#' 
#' @param x a list of parameters
#' 
#' @export
compile_keras_model <- function(x){
  
  ### here the list gets flatten through model compilation
  x$final_model <- x$model_final %>% 
    keras::compile(
      loss = x$loss,
      optimizer = x$optimizer,
      metrics = x$metrics
    )
  
  return(x)
}

#' %error%
#' 
#' @param x ...
#' @param y ...
#' 
#' @export
`%error%`<- function(x, y){
  ifelse(is.null(x), y, x)
}

#' fit_keras_model
#' 
#' @param x a list of parameters
#' 
#' @export
fit_keras_model <- function(x){
  
  tictoc::tic()
  if(is.null(x$class_weight)){
    x$final_model %>% 
      keras::fit(
        x$x_train, x$y_train, 
        batch_size = 100, 
        shuffle = T,
        epochs = 10, # old: x$epochs %error%  in combination with early stoping: free lunch!
        validation_split = .2,
        callbacks = c(
          keras::callback_early_stopping(monitor = "val_loss", patience = 1, mode = "auto")
        )
      )
  } else {
    x$final_model %>% 
      keras::fit(
        x$x_train, x$y_train, 
        batch_size = 100, 
        shuffle = T,
        #class_weight = 'auto',
        class_weight = x$class_weight,
        epochs = 10, # old: x$epochs %error%  in combination with early stoping: free lunch!
        validation_split = .2,
        callbacks = c(
          keras::callback_early_stopping(monitor = "val_loss", patience = 1, mode = "auto")
        )
      )
  }

  time <- tictoc::toc(log = T)
  suppressMessages(
    x$duration <- as.numeric(time$toc - time$tic) %>% round(1)
  )
  return(x)
}

#' eval_keras_model
#' 
#' @param x a list of parameters
#' 
#' @export
eval_keras_model <- function(x){
  
  scores <- x$final_model %>%
    evaluate(
      x$x_test, x$y_test,
      batch_size = 100,
      verbose = 1
    ) %>% 
    set_names(paste0("test_", names(.))) %>% 
    map(round, 3)
  ### preferably balance test set more or less
  #if(is.null(x$class_weight)){
  # } else {
  #   scores <- x$final_model %>%
  #     evaluate(
  #       x$x_test, x$y_test,
  #       batch_size = 100, 
  #       class_weight = x$class_weight,
  #       verbose = 1
  #     ) %>% 
  #     set_names(paste0("test_", names(.))) %>% 
  #     map(round, 3)
  # }


  out <- c(x, scores) %>% 
    keep(~is.vector(.x) & length(.x) == 1) %>% 
    bind_cols %>% 
    gather(param, value, -id, -model_name, -data)

  return(out)
}
