#' keras simple lstm
#'
#' Word embedding + (bidirectional) long short-term memory
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param lstm_dim Number of recurrent neurons (default 64)
#' @param lstm_drop Recurrent dropout ratio 
#' @param bidirectional default is F
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_simple_lstm <- function(
  input_dim, embed_dim = 128, seq_len = 50, 
  lstm_dim = 64, lstm_drop = .2, dropout = .2, bidirectional = F,
  output_dim = 2, output_fun = "softmax"
){
  
  model <- keras::keras_model_sequential() %>%
    keras::layer_embedding(
      input_dim = input_dim, 
      output_dim = embed_dim, 
      input_length = seq_len
    )
  
  if(bidirectional){
    model %<>% keras::bidirectional(layer_lstm(units = lstm_dim, dropout = .2, recurrent_dropout = lstm_drop)) #return_sequences = T??
  } else {
    model %<>% keras::layer_lstm(units = lstm_dim, dropout = dropout, recurrent_dropout = lstm_drop)
  }
  
  model %<>% 
    keras::layer_dense(units = output_dim, activation = output_fun)
  
  return(model)
}