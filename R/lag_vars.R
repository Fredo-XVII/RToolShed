# Functions Roxygen format
#' @title Lag Variables up to `n` lags
#'
#' @description This function builds lags of a variable up to the `n` lag.
#'
#' @details Build the lags of a variable.
#'
#' @param df dataframe or tibble
#' @param col string - specify the column/field/variable for differencing.
#' @param lags number - specify the number of lags for differencing.
#' @param mutate_type string - select whether to `mutate()` or `transmute()` from dplyr.
#'
#' @return A dataframe with the lags of the column specified.
#'
#' @examples
#>' \dontrun{
#' library(magrittr)
#' df <- datasets::airmiles %>% as.vector() %>% tibble::enframe(name = "airmiles")
#' lag_vars(df, col = "airmiles") %>% head()
#>' }
#'
#' @import dplyr
#' @importFrom glue glue
#' @import rlang
#' @importFrom stats setNames
#' @importFrom magrittr %>%
#'
#' @export


lag_vars <- function(df,col = NULL,lags = 1, mutate_type = c("mutate","trans")) {

  if(is.null(col)){
    rlang::abort(message = "'col' argument is missing, please specify a column name",
                 .subclass = "col error",
                 col = col)
  }

  # Build Lags and Lag Column Names
  lags_num <- 1:lags
  col_names <- paste(col, "lag", lags_num, sep = "_" )

  # Build functions based on lags
  build_fx <- glue::glue("dplyr::lag(., { lags_num } )")
  lag_functions <- stats::setNames(build_fx, col_names)

  # Choose between mutate and transmutate
  if (mutate_type[1] == "trans") {
    out_df <- df %>% dplyr::transmute_at(dplyr::vars(!!col), dplyr::funs_(lag_functions))
  } else {
    out_df <- df %>% dplyr::mutate_at(dplyr::vars(!!col), dplyr::funs_(lag_functions))
  }
  out_df
}
