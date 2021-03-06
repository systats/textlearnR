% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keras_pooled_gru.R
\name{keras_pooled_gru}
\alias{keras_pooled_gru}
\title{keras pooled gru}
\usage{
keras_pooled_gru(input_dim, embed_dim = 128, seq_len = 50,
  gru_dim = 64, gru_drop = 0.2, bidirectional = F,
  output_fun = "softmax", output_dim = 2)
}
\arguments{
\item{input_dim}{Number of unique vocabluary/tokens}

\item{embed_dim}{Number of word vectors}

\item{seq_len}{Length of the input sequences}

\item{gru_dim}{Number of recurrent neurons (default 64)}

\item{gru_drop}{Recurrent dropout ratio}

\item{bidirectional}{default is F}

\item{output_fun}{Output activation function}

\item{output_dim}{Number of neurons of the output layer}
}
\value{
keras model
}
\description{
Word embedding + spatial dropout + (pooled) gated recurrent unit
}
\details{
Taken from https://www.kaggle.com/yekenot/pooled-gru-fasttext
}
