#' keras deep lstm
#'
#' Word embedding + Deep (bidirectional) long short-term memory
#' 
#' Stacking lstm modules of different size.
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param hidden_dims Number of neurons per layer as vector of integers c(256, 128, 64)
#' @param bidirectional default is F
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_deep_lstm <- function(
  input_dim, embed_dim = 128, seq_len = 50, 
  hidden_dims = c(128, 64, 32), bidirectional = F,
  output_fun = "softmax", output_dim = 2
){
  
  model <- keras::keras_model_sequential() %>%
    keras::layer_embedding(
      input_dim = input_dim, 
      output_dim = embed_dim, 
      input_length = seq_len
    )
  
  # Dnymaically scale the network by increasing hidden_layer and hidden_dims 
  for(layer in 1:length(hidden_dims)){
    if(bidirectional){
      model %<>% 
        keras::bidirectional(
          layer_lstm(
            units =  hidden_dims[layer], 
            dropout = .2, 
            recurrent_dropout = .2, 
            return_sequences = T#ifelse(layer == length(hidden_dims), F, T)
          )
        )
    } else {
      model %<>% 
        keras::layer_lstm(
          units =  hidden_dims[layer], 
          dropout = .2, 
          recurrent_dropout = .2, 
          return_sequences = T#ifelse(layer == length(hidden_dims), F, T)
        )
    }
  }
  
  model %<>% 
    keras::layer_flatten() %>% 
    keras::layer_dense(units = output_dim, activation = output_fun)
  
  return(model)
}
