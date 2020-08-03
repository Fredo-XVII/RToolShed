#' @title Test if a Column/Variable has NA's
#'
#' @details
#' Sums up the total number of NA's and reports where a column has 1 or more NA's
#'
#' @param .data dataframe or tibble
#' @param col_n string name of the column/variable within the dataframe.
#' @return Outputs a message of whether a column has NA's.
#'
#' @examples
#' \dontrun{
#' library(magrittr)
#' library(dplyr)
#' library(glue)
#' library(testthat)
#' test_na(mtcars,'cyl')
#' }
#'
#' @importFrom magrittr %>%
#' @importFrom glue glue
#' @importFrom dplyr enquo
#' @importFrom testthat test_that expect_equal
#' @export

test_na <- function(.data,col_n) {
  df_col <- dplyr::enquo(col_n)
  message(paste(glue::glue("{col_n} has NA's: "), sum(is.na(select(.data,!!df_col))) != 0))
  na_sum <- is.na(dplyr::select(.data,!!df_col)) %>% sum()
  testthat::test_that(
    desc = sprintf("Test NA for column: %s", paste0(substitute(.data),'$',col_n)),
    code = testthat::expect_equal(
      na_sum, 0
    )
  )
}
