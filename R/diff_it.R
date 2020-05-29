# Functions Roxygen format
#' @title Difference Variables `n` Lags, `k` Differences
#'
#' @description This function takes a column and builds the differences based
#'     on the difference `k` between the column and the lag `n` specified.
#'
#' @details Build the differences of a variable
#'
#' @param df Must be a dataframe or tibble
#' @param col Specify the column/field/variable for differencing.
#' @param lags Specify the number of lags for differencing.
#' @param diff Specify the number of differences for differencing.
#' @param mutate_type Select whether to `mutate()` or `transmute()` from dplyr.
#'
#' @return A dataframe with the lagged differences of the column specified.
#'
#' @examples
#' \dontrun{
#' library(magrittr)
#>' df <- datasets::airmiles %>% as.vector() %>% tibble::enframe(name = "airmiles")
#>' diff_it(df, col = "airmiles") %>% head()
#' }
#'
#' @import dplyr
#' @importFrom glue glue
#' @import rlang
#' @importFrom stats setNames
#' @importFrom magrittr %>%
#'
#' @export

diff_it <- function(df,col = NULL,lags = 1, diff = 1, mutate_type = c("mutate","trans")) {

  if(is.null(col)){
    rlang::abort(message = "'col' argument is missing, please specify a column name",
                 .subclass = "col error",
                 col = col)
  }

  # Build Lags and Differences, and Column Names
  lags_num <- 1:lags
  diff_num <- 1:diff
  col_names <- paste(col, "diff", diff_num, "lag", lags_num, sep = "_" )

  # Build functions based on lags
  build_fx <- glue::glue("tsibble::difference(., lag = { lags_num }, difference = { diff })")
  lag_functions <- stats::setNames(build_fx, col_names)

  # Choose between mutate and transmutate
  if (mutate_type[1] == "trans") {
    out_df <- df %>% dplyr::transmute_at(dplyr::vars(!!col), dplyr::funs_(lag_functions))
  } else {
    out_df <- df %>% dplyr::mutate_at(dplyr::vars(!!col), dplyr::funs_(lag_functions))
  }
  return(out_df)
}

