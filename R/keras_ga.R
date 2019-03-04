#' normalize_params
#' 
#' @param x a vector of proposal points
#' 
#' @export

normalize_params <- function(x){ 
  ### e.g. dropout ratios
  smaller_one <- function(x) ifelse(x < 1, T, F)
  bigger_one <- function(x) ifelse(x > 1, T, F)
  
  ### only flatten integers 
  out <- x %>% 
    # round droput to 2 digits (maybe only 1?)
    map_if(smaller_one, round, 2) %>% 
    map_if(bigger_one, floor) %>% 
    as.numeric
  
  return(out)
}


#' add_update_params
#' 
#' @param org a original list
#' @param new  a new list
#' 
#' @export
add_update_params <- function(org, new){
  
  new <- new[!(new %in% names(org))]
  added <- c(org, new)
  
  updated <- added %>%
    compact %>%
    ### Update model defaults
    imap(~{
      if(.y %in% names(new)){
        return(new[[.y]])
      } else {
        return(.x)
      }
    })
  
  return(updated)
}

#' get_ga_bounds
#' 
#' @param dial a list of dial parameter objects
#' 
#' @export
get_ga_bounds <- function(dial){
  dial %>% 
    purrr::map_dfr(~{
      tibble(
        name = .x$label %>% names, 
        desc = .x$label, 
        lower = .x$range$lower, 
        upper = .x$range$upper
      )
    })
}

#' fit_ga_search
#' 
#' @param static a list of static data
#' @param params a list of dial parameter objects
#' 
#' @export

fit_ga_search <- function(id, data, model, params, static, ...){
  
  ### check DB for id 
  con <- dbConnect(RSQLite::SQLite(), "data/model_dump.db")
  # only if tables exists
  if(length(dbListTables(con)) == 1) {
    
    id_already <- con %>% 
      tbl("runs") %>% 
      select(id) %>% 
      distinct %>% 
      pull(id)
    
    # count id appearences and add + 1
    if(id %in% id_already){
      id_clean <- id_already %>% 
        str_remove_all("\\(\\d+\\)")
      num <- id_clean[id_clean %in% id] %>% length
      id <- paste0(id, "(", num + 1, ")")
    }
  }
  dbDisconnect(con)

  ### Combine and add parameters
  static$id <- id
  static$search <- "ga"
  static <- c(data, static)
  static$model <- model
  static$data <- deparse(substitute(data))
  static$model_name <- deparse(substitute(model))
  
  
  if(length(static$ouput_dim) == 0){
    static$output_dim <- ncol(data$y_train)
  }
  
  ### Mapping dial parameters to GA
  bounds <- params %>%
    get_ga_bounds
  
  ### Fitting fun
  run_keras <- function(x) { 
    
    # floor doubles to ineteger
    new_params <- x %>% 
      normalize_params %>%
      purrr::set_names(bounds$name)

    # Here are the static params!!!
    setup <- static %>% 
      add_update_params(new_params) %>% 
      # preprocess text -> x_train, x_test
      transform_text %>%
      # run keras steps
      get_keras_model %>% 
      compile_keras_model %>% 
      fit_keras_model %>% 
      eval_keras_model %>% 
      mutate(timestamp = as.character(Sys.time()))
    
    # Add run to database
    con <- dbConnect(RSQLite::SQLite(), "data/model_dump.db")
    if(!is.null(dbListTables(con))) {
      dbWriteTable(con, "runs", setup, append = T)
    } else {
      dbWriteTable(con, "runs", setup)
    }
    dbDisconnect(con)

    # performance evaluation
    out <- setup %>% 
      dplyr::filter(param == "test_loss") %>% 
      dplyr::pull(value) %>% 
      as.numeric()

    # Custome GA Message
    verbose <- setup %>% 
      mutate(par_set = glue::glue("{param}={value} ")) %>%
      split(1:nrow(.)) %>% 
      map(~{
        if(.x$param %in% bounds$name){
          crayon::green(.x$par_set)
        } else if(str_detect(.x$param, "test_|duraction")){
          crayon::magenta(.x$par_set)
        } else {
          crayon::blue(.x$par_set)
        }
      })

    
    
    cat(crayon::bold(static$model_name) %+% glue::glue(" [{id}]: "))
    verbose %>% walk(cat)
    cat("\n")

    return(-out)
  }
  
  ### Main Run
  ga_out <- GA::ga(
    type = "real-valued", 
    fitness = run_keras, 
    lower = bounds$lower, 
    upper = bounds$upper, 
    ...
  )
  
  return(ga_out)
}

