#' run_mbo
#'
#' tidy MBO
#'
#' @data data input
#' @param data input
#' @param params params
#' @param const constants
#' @param n_init burn in iterations
#' @param n_main main iterations
#' @return list(data = data, params = params)
#'
#' @export
run_mbo <- function(data, params, const = NULL, prior = NULL, n_init = 5, n_main = 30, name = "", metric = "accuracy", parallel = F){
  
  n_obj <- length(metric)
  #metric <- "accuracy"
  
  list_metrics <- list(
    accuracy = F, 
    ce = T, 
    auc = F, 
    f1 = F
    #logLoss = T, 
    #ll = T
  ) # Minimize?
  
  minimize <- list_metrics[metric] %>% 
    unlist %>% 
    as.logical()
  
  ### Main Definition Function
  if(n_obj == 1) {
    constructor <- smoof::makeSingleObjectiveFunction(
      #name = name,
      fn = function(x) {
        perform <- run_mbo_steps(container = list(data = data, params = c(const, x)), metric = metric)
        return(perform)
      },
      par.set = params, 
      has.simple.signature = F, # function expects a named list of parameter values
      minimize = minimize # to increase accuracy
    )
    # cat(crayon::blue("[1] ") %+% 
    #   crayon::green("Single Objective Function") %+% 
    #   crayon::red(paste0(" (", paste(metric, collapse = ", ") ,")\n")))
  } else {
    constructor <- smoof::makeMultiObjectiveFunction(
      name = name,
      fn = function(x) {
        perform <- run_mbo_steps(container = list(data = data, params = c(const, x)), metric = metric)
        return(perform)
      },
      par.set = params, 
      n.objectives = n_obj,
      has.simple.signature = F, # function expects a named list of parameter values
      minimize = minimize # to increase accuracy
    )
    # cat(crayon::blue("[1] ") %+% 
    #   crayon::green("Multi Objective Function") %+% 
    #   crayon::red(paste0(" (", paste(metric, collapse = ", ") ,")\n"))) 
  }
  
  if(is.null(prior)){
    
    init <- ParamHelpers::generateDesign(
      n = n_init,
      par.set = ParamHelpers::getParamSet(constructor),
      fun = lhs::randomLHS
    )
    
    progress_fun <- progressively(.f = constructor, .n = nrow(init))
    
    if(n_obj == 1){
      var_names <- "y"
    } else { 
      var_names <- paste0("y_", 1:n_obj)
    }
    
    init <- init %>%
      split(seq_along(init[[1]])) %>%
      purrr::map(progress_fun) %>%
      purrr::reduce(rbind) %>%
      as_tibble() %>%
      magrittr::set_colnames(value = var_names) %>%
      cbind(init, .)
  } else {
    cont_names <- names(const)
    init <- prior %>% 
      dplyr::rename_("y" = metric) %>% 
      dplyr::select(everything(), y) %>%
      .[!names(.) %in% c(cont_names, "step", "exec.time")] %>%
      dplyr::mutate_if(is.character, as.factor) %>%
      as_tibble()
  }
  
  #names(const)# %>% map(~.x[1])
  init %>% arrange(desc(y)) %>% glimpse()
  
  # type <- init %>%
  #   purrr::map(class) %>%
  #   purrr::map(~.x == "factor") %>%
  #   unlist %>%
  #   any() %>%
  #   ifelse(., "factor", "integer")
  
  # if(type == "integer"){
  #   
  #   cat(crayon::blue("[3] ") %+% 
  #     crayon::green("Continous Search Space\n"))
  #   
  #   cat(crayon::blue("[4] ") %+% 
  #     crayon::green("Surrogate Model: ") %+% 
  #     crayon::red("Bayesian Optimization\n"))
  #   
  #   surrogate <- mlr::makeLearner(
  #     cl = "regr.km",
  #     predict.type = "se",
  #     covtype = "matern3_2",
  #     control = list(trace = F)
  #   )
  #   
  #   control <- mlrMBO::makeMBOControl() %>%
  #     mlrMBO::setMBOControlTermination(iters = n_main) %>%
  #     mlrMBO::setMBOControlInfill(crit = makeMBOInfillCritEI())
  # }
  
  # if(type == "factor"){
  
  # cat(crayon::blue("[3] ") %+% 
  #   crayon::green("Discrete Search Space\n"))
  # 
  # cat(crayon::blue("[4] ") %+% 
  #   crayon::green("Surrogate Model: ") %+% 
  #   crayon::red("Random Forest Regression\n"))
  # 
  surrogate <- mlr::makeLearner("regr.randomForest", predict.type = "se")
  
  control <- mlrMBO::makeMBOControl() %>%
    mlrMBO::setMBOControlInfill(
      crit = mlrMBO::makeMBOInfillCritCB(cb.lambda = 5),
      opt.focussearch.points = 500
    ) %>%
    mlrMBO::setMBOControlTermination(
      iters = n_main
    )
  #}
  
  if(n_obj > 1){
    control <- mlrMBO::makeMBOControl(n.objectives = n_obj) %>%
      mlrMBO::setMBOControlTermination(iters = n_main) %>%
      mlrMBO::setMBOControlInfill(crit = makeMBOInfillCritDIB())
  }
  
  #start_parallel_core(parallel, cores = 2)
  
  run <- mlrMBO::mbo(
    constructor,
    design = init,
    learner = surrogate,
    control = control,
    show.info = T
  )
  
  #kill_parallel_core(parallel)
  
  final <- tidyMBO::tidy(run, const, data, metric)
  
  return(final)
}