#' keras cnn gru
#'
#' Word embedding + 1D pooled convolution + gru layer
#' 
#' pool_size is determined automatically
#'
#' @param input_dim Number of unique vocabluary/tokens
#' @param embed_dim Number of word vectors
#' @param seq_len Length of the input sequences
#' @param n_filters the number of convolutional filters 
#' @param filter_size the window size (kernel_size)
#' @param output_dim Number of neurons of the output layer
#' @param output_fun Output activation function
#' @return keras model
#' 
#' @export

keras_multi_cnn <- function(
  input_dim, embed_dim = 128, seq_len = 50, 
  filter_sizes = c(1, 2, 3, 4), num_filters = 50,
  output_dim = 2, output_fun = "softmax"
){
  
  inputs <- keras::layer_input(shape = seq_len)
  
  embedding<- inputs %>%
    keras::layer_embedding(
      input_dim = input_dim, 
      output_dim = embed_dim
      #input_length = seq_len
    ) %>% 
    #layer_spatial_dropout_1d(0.2) %>% 
    keras::layer_reshape(list(seq_len, embed_dim, 1))
  
  block1 <- embedding %>% 
    keras::layer_conv_2d(
      num_filters, 
      kernel_size = list(filter_sizes[1], embed_dim), 
      kernel_initializer = 'normal',
      activation='elu'
    ) %>% 
    keras::layer_max_pooling_2d(pool_size=list(seq_len - filter_sizes[1] + 1, 1))
  
  block2 <- embedding %>% 
    keras::layer_conv_2d(
      num_filters, 
      kernel_size = list(filter_sizes[2], embed_dim), 
      kernel_initializer = 'normal',
      activation='elu'
    ) %>% 
    keras::layer_max_pooling_2d(pool_size=list(seq_len - filter_sizes[2] + 1, 1))
  
  block3 <- embedding %>% 
    keras::layer_conv_2d(
      num_filters, 
      kernel_size = list(filter_sizes[3], embed_dim), 
      kernel_initializer = 'normal',
      activation='elu'
    ) %>% 
    keras::layer_max_pooling_2d(pool_size = list(seq_len - filter_sizes[3] + 1, 1))
  
  block4 <- embedding %>% 
    keras::layer_conv_2d(
      num_filters, 
      kernel_size = list(filter_sizes[4], embed_dim), 
      kernel_initializer = 'normal',
      activation='elu'
    ) %>% 
    keras::layer_max_pooling_2d(pool_size=list(seq_len - filter_sizes[4] + 1, 1))
  
  z <- keras::layer_concatenate(list(block1, block2, block3, block4), axis = 1) %>% 
    keras::layer_flatten()
    # does not work quite well
    #keras::layer_dropout(dropout)
  
  output <- z %>% 
    keras::layer_dense(output_dim, activation=output_fun)
  
  model <- keras::keras_model(inputs, output)
  
  return(model)
}