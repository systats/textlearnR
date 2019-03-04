#' keras deep lstm 2
#'
#' Word embedding + (bidirectional) long short-term memory + Deep dense layer
#' 
#' Taken from https://www.kaggle.com/gidutz/text2score-keras-rnn-word-embedding
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param lstm_dim Number of lstm neurons (default 32)
#' @param lstm_drop default is 2
#' @param bidirectional default is F
#' @param hidden_dims Number of neurons per layer as vector of integers
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_deep_lstm2 <- function(
  input_dim, embed_dim = 128, seq_len = 50, 
  lstm_dim = 32, lstm_drop = .2, bidirectional = F,
  hidden_dims = c(32, 32, 32),
  output_dim = 2, output_fun = "softmax"
){
  
  model <- keras::keras_model_sequential() %>%
    keras::layer_embedding(
      input_dim = input_dim, 
      output_dim = embed_dim, 
      input_length = seq_len
    )
  
  if(bidirectional){
    model %<>% keras::bidirectional(
      keras::layer_lstm(
        units = lstm_dim, recurrent_dropout = lstm_drop, dropout = 0.2, 
        kernel_regularizer = keras::regularizer_l2(2e-5),
        activity_regularizer = keras::regularizer_l1(2e-5)
      )
    ) 
  } else {
    model %<>% keras::layer_lstm(
      units = lstm_dim, recurrent_dropout = lstm_drop, dropout = 0.2, 
      kernel_regularizer = keras::regularizer_l2(2e-5),
      activity_regularizer = keras::regularizer_l1(2e-5)
    )
  }
    
  for(layer in 1:length(hidden_dims)){
    model %<>% keras::layer_dense(
        units = hidden_dims[layer], 
        kernel_regularizer = keras::regularizer_l2(2e-5),
        activity_regularizer = keras::regularizer_l1(2e-5), 
        activation = "relu"
      ) %>%
      keras::layer_dropout(.2) %>%
      keras::layer_batch_normalization()
  }
  
  ### Output
  model %<>% keras::layer_dense(units = output_dim, activation = output_fun)
  
  return(model)
}
