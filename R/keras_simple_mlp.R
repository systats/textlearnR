#' keras simple mlp
#'
#' Word Embedding + Simple Multilayer Perceptron 
#'
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param pooling one of c("flatten", "global_average", "average")
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' \if{html}{
#' \out{
#'  <img src = "https://media.giphy.com/media/IB9foBA4PVkKA/giphy.gif">
#' }}
#'
#' @export

keras_simple_mlp <- function(
  input_dim, embed_dim, seq_len, 
  pooling = 'flatten', 
  dense_dim = 128, dense_fun = 'relu', dropout = .5, 
  output_fun = 'softmax', output_dim
){
  
  model <- keras::keras_model_sequential() %>% 
    keras::layer_embedding(input_dim = input_dim, output_dim = embed_dim, input_length = seq_len) 
  # the 3D tensor of embeddings gets falttened into a 2D tensor of shape `(samples, maxlen * output_dim)
  
  if(pooling == 'global_average'){
    model %<>% keras::layer_global_average_pooling_1d() 
  #} else if(pooling == 'average'){
    # model %<>% keras::layer_average_pooling_1d(pool_size = ) 
  } else {
    model %<>% keras::layer_flatten()
  } 
  model %<>% 
    keras::layer_dense(units = dense_dim, activation = dense_fun) %>% 
    keras::layer_dropout(rate = dropout) %>% 
    keras::layer_dense(units = output_dim, activation = output_fun)
  
  return(model)
}
