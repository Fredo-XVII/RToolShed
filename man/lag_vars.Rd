% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lag_vars.R
\name{lag_vars}
\alias{lag_vars}
\title{Lag Variables up to \code{n} lags}
\usage{
lag_vars(df, col = NULL, lags = 1, mutate_type = c("mutate", "trans"))
}
\arguments{
\item{df}{dataframe or tibble}

\item{col}{string - specify the column/field/variable for differencing.}

\item{lags}{number - specify the number of lags for differencing.}

\item{mutate_type}{string - select whether to \code{mutate()} or \code{transmute()} from dplyr.}
}
\value{
A dataframe with the lags of the column specified.
}
\description{
This function builds lags of a variable up to the \code{n} lag.
}
\details{
Build the lags of a variable.
}
\examples{
library(magrittr)
df <- datasets::airmiles \%>\% as.vector() \%>\% tibble::enframe(name = "airmiles")
lag_vars(df, col = "airmiles") \%>\% head()

}
