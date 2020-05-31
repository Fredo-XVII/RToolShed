# Build function for geometric mean

#' @examples
#' geom_mean_3 <- purrr::partial(geom_mean, roll_window = 3)
#' geom_mean_roll_3 <- tibbletime::rollify(geom_mean_3,window = 3)
#'
#' @export
geom_mean <- function(x,roll_window) {
  y <- c(x)*1/100 + 1
  z <- prod(c(y))^(1/roll_window) - 1
  return(z*100)
}
