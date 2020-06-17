
#' @export

test_na <- function(.data,col_n) {
  df_col <- enquo(col_n)
  message(paste(glue::glue("{col_n} has NA's: "), sum(is.na(select(.data,!!df_col))) != 0))
  testthat::test_that(
    desc = sprintf("Test NA for column: %s", paste0(substitute(.data),'$',col_n)),
    code = testthat::expect_equal(
      is.na(.data$col_n) %>% sum(), 0
    )
  )
}