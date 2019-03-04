#' keras cnn lstm
#'
#' Word embedding + 1D pooled convolution + lstm layer
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param n_filters the number of convolutional filters 
#' @param filter_size the window size (kernel_size)
#' @param pool_size pooling dimension (filters)
#' @param lstm_dim Number of lstm neurons (default 32)
#' @param lstm_drop default is 2
#' @param bidirectional default is F
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_cnn_lstm <- function(
  input_dim, embed_dim = 128, seq_len = 50, 
  filter_size = 5, n_filters = 100, pool_size = 4, 
  lstm_dim = 64, lstm_drop = .2, bidirectional = F, dropout = .2, 
  output_dim = 2, output_fun = "softmax"
){
  
  model <- keras::keras_model_sequential() %>%
    keras::layer_embedding(
      input_dim = input_dim, 
      output_dim = embed_dim, 
      input_length = seq_len
    ) %>%
    #layer_dropout(0.25) %>%
    keras::layer_conv_1d(
      n_filters, 
      filter_size, # -> kernel_size
      padding = "valid",
      activation = "relu",
      strides = 1
    ) %>%
    keras::layer_max_pooling_1d(pool_size)
  
  if(bidirectional){
    model %<>% keras::bidirectional(
        keras::layer_lstm(units = lstm_dim, dropout = dropout, recurrent_dropout = lstm_drop)
      )
  } else {
    model %<>% keras::layer_lstm(units = lstm_dim, dropout = dropout, recurrent_dropout = lstm_drop)
  }
  
  model %<>% keras::layer_dense(units = output_dim, activation = output_fun) 
  
  return(model)
}
