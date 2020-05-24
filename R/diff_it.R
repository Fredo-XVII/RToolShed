# Functions Roxygen format
#' @title Difference Variables `n` Lags, `k` Differences
#'
#' @description This function takes a column and builds the differences based
#'     on the differences between the column and the lag specified.
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

diff_it <- function(df,col,lags = 1, diff = 1, mutate_type = c("mutate","trans")) {
  
  # Build Lags and Differences, and Column Names
  lags_num <- 1:lags
  diff_num <- 1:diff
  col_names <- paste(col, "diff", diff_num, "lag", lags_num, sep = "_" )
  
  # Build functions based on lags
  build_fx <- glue::glue("tsibble::difference(., lag = { lags_num }, difference = { diff })")
  lag_functions <- setNames(build_fx, col_names)
  
  # Choose between mutate and transmutate  
  if (mutate_type[1] == "trans") {
    out_df <- df %>% transmute_at(vars(!!col), funs_(lag_functions)) 
  } else {
    out_df <- df %>% mutate_at(vars(!!col), funs_(lag_functions)) 
  }
  return(out_df)
}
