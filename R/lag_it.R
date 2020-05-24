# Functions Roxygen format
#' @title Lag Variables up to `n` lags
#'
#' @description This function builds lags of a variable up to the `n` lag.
#'
#' @details
#'
#' @param
#'
#' @return
#'
#' @examples
#'
#>' @export

# Lags and Differences
lag_it <- function(df,col,lags = 1, mutate_type = c("mutate","trans")) {
  
  # Build Lags and Lag Column Names
  lags_num <- 1:lags
  col_names <- paste(col, "lag", lags_num, sep = "_" )
  
  # Build functions based on lags
  build_fx <- glue::glue("dplyr::lag(., { lags_num } )")
  lag_functions <- setNames(build_fx, col_names)
  
  # Choose between mutate and transmutate
  if (mutate_type[1] == "trans") {
    out_df <- df %>% transmute_at(vars(!!col), funs_(lag_functions))
  } else {
    out_df <- df %>% mutate_at(vars(!!col), funs_(lag_functions))
  }
  return(out_df)
}
