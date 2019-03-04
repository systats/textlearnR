#' keras gru cnn
#'
#' Word embedding + gru global average & max + 1D pooled convolution 
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param gru_dim Number of lstm neurons (default 32)
#' @param gru_drop default is 2
#' @param n_filters the number of convolutional filters 
#' @param filter_size the window size (kernel_size)
#' @param pool_size pooling dimension (filters)
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_gru_cnn <- function(
  input_dim, embed_dim = 128, seq_len = 50, 
  gru_dim = 64, gru_drop = .2, #bidirectional = T,
  filter_sizes = c(3, 2), n_filters = c(120, 60), pool_size = 4, 
  output_fun = "softmax", output_dim = 1
){
  
  input <- keras::layer_input(shape = seq_len, dtype = "int32", name = "input")
  
  embedding <- input %>%
    keras::layer_embedding(
      input_dim = input_dim, 
      output_dim = embed_dim
      #input_length = seq_len
    ) %>%
    keras::layer_spatial_dropout_1d(rate = .1)
  
  block1 <- embedding %>%
    keras::bidirectional(keras::layer_gru(units = gru_dim, return_sequences = T, recurrent_dropout = gru_drop)) %>% 
    keras::layer_conv_1d(n_filters[1], filter_sizes[1], padding = "valid", activation = "relu", strides = 1) 
  
  block2 <- embedding %>%
    keras::bidirectional(keras::layer_gru(units = gru_dim, return_sequences = T, recurrent_dropout = gru_drop)) %>% 
    keras::layer_conv_1d(n_filters[2], filter_sizes[2], padding = "valid", activation = "relu", strides = 1) 
  
  max_pool1 <- block1 %>% keras::layer_global_max_pooling_1d()
  ave_pool1 <- block1 %>% keras::layer_global_average_pooling_1d()
  max_pool2 <- block2 %>% keras::layer_global_max_pooling_1d()
  ave_pool2 <- block2 %>% keras::layer_global_average_pooling_1d()
  
  output <- keras::layer_concatenate(list(ave_pool1, max_pool1, ave_pool2, max_pool2)) %>%
    keras::layer_dense(units = output_dim, activation = output_fun)
  
  model <- keras::keras_model(input, output)
  
  return(model)
}