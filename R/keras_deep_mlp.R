#' keras deep mlp
#'
#' Word Embedding + Deep Multilayer Perceptron 
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param hidden_dims Number of neurons per layer as vector of integers c(256, 128, 64)
#' @param hidden_fun Hidden activation function ("relu" by default)
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_deep_mlp <- function(
  input_dim, embed_dim = 64, seq_len, 
  hidden_dims = c(256, 128, 64), hidden_fun = "relu",
  output_fun = 'softmax', output_dim
  ){
  
  model <- keras::keras_model_sequential() %>% 
    keras::layer_embedding(input_dim = input_dim, output_dim = embed_dim, input_length = seq_len) %>%
    keras::layer_flatten()
  
  # Dnymaically scale the network by increasing hidden_layer and hidden_dims 
  for(layer in 1:length(hidden_dims)){
    model %<>% keras::layer_dense(units = hidden_dims[layer], activation = hidden_fun)
  }
  
  model %<>% keras::layer_dense(units = output_dim, activation = output_fun)
  
  return(model)
}

