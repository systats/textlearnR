#' keras pooled gru
#'
#' Word embedding + spatial dropout + (pooled) gated recurrent unit
#' 
#' Taken from https://www.kaggle.com/yekenot/pooled-gru-fasttext
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param gru_dim Number of recurrent neurons (default 64)
#' @param gru_drop Recurrent dropout ratio 
#' @param bidirectional default is F
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_pooled_gru <- function(
  input_dim, embed_dim = 128, seq_len = 50, 
  gru_dim = 64, gru_drop = .2, bidirectional = F,
  output_fun = "softmax", output_dim = 2
){
  
  input <- keras::layer_input(shape = seq_len)
  
  block <- input %>%
    keras::layer_embedding(
      input_dim = input_dim, 
      output_dim = embed_dim 
      #input_length = maxlen
    ) %>% 
    keras::layer_spatial_dropout_1d(0.2)
  
  if(bidirectional){
    block %<>% keras::bidirectional(keras::layer_gru(units = gru_dim, return_sequences = T))
  } else {
    block %<>% keras::layer_gru(units = gru_dim, return_sequences = T)
  }
  
  ### global average
  avg_pool <- block %>% keras::layer_global_average_pooling_1d()
  ### global max
  max_pool <- block %>% keras::layer_global_max_pooling_1d()
  
  output <- keras::layer_concatenate(c(avg_pool, max_pool)) %>% 
    keras::layer_dense(output_dim, activation = output_fun)
  
  model <- keras::keras_model(input, output)
  
  return(model)
}
