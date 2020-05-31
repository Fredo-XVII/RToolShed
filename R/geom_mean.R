# Build function for geometric mean

geom_mean <- function(x,roll_window) {
  y <- c(x)*1/100 + 1
  z <- prod(c(y))^(1/roll_window) - 1
  return(z*100)
}
