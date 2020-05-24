# Functions Roxygen format
#' @title Lag Variables up to `n` lags
#'
#' @description This function builds lags of a variable up to the `n` lag.
#'
#' @details lag_it(df, col, lags, mutate_type)
#'
#' @param df Must be a dataframe or tibble
#' @param col \<text\> Specify the column/field/variable for differencing.
#' @param lags \<number\> Specify the number of lags for differencing.
#' @param mutate_type \<text\> Select whether to `mutate()` or `transmute()` from dplyr.
#'
#' @return A dataframe with the lags of the column specified.
#'
#' @examples
#' library(magrittr)
#' df <- datasets::airmiles %>% as.vector() %>% tibble::as_tibble()
#' names(df) <- c("airmiles")
#' lag_it(df, col = "airmiles") %>% head()
#'
#' @import dplyr
#' @importFrom glue glue
#' @importFrom rlang abort .data
#' @importFrom stats setNames
#' @importFrom magrittr %>%
#'
#' @export

# Lags and Differences
lag_it <- function(df,col = NULL,lags = 1, mutate_type = c("mutate","trans")) {

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
  return(out_df)
}
