#' @title Geometric Mean

#' This functions creates a geometric mean of a numeric vector.
#'
#' @param x numeric vector or dataframe column.
#' @param roll_window numeric - length of the vector, or can be used to build a
#' rolling geometric mean.
#'
#' @return Returns the geometric mean of a vector, or one number.
#'
#' @examples
#' geom_mean_3 <- purrr::partial(geom_mean, roll_window = 3)
#' geom_mean_roll_3 <- tibbletime::rollify(geom_mean_3,window = 3)
#' data <- c(20,25,38,15,70)
#' geom_mean(data)
#' geom_mean_roll_3(data)
#'
#' @export


geom_mean <- function(x, roll_window = length(x)) {
  y <- c(x)*1/100 + 1
  z <- prod(c(y))^(1/roll_window) - 1
  return(z*100)
}

