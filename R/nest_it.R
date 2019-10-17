#' @title Nest Dataframe by Grouping Variables
#'
#' Simple function to nest dataframes given a list of column names.
#'
#' @param .data a dataframe
#' @param ... list of column name separated by a ',' to group by for nesting.
#' Example: for the mctars df you would type: cyl, gear. No c(), no list(), no quotes.
#' @return This function returns a nested dataframe by the column names provided.
#' The structure will be "Classes ‘tbl_df’, ‘tbl’ and 'data.frame':"
#'
#' @examples
#' \dontrun{
#' nest_it(mtcars, cyl,gear)
#' mtcars %>% nest_it(cyl,gear)
#' }
#'
#' @import dplyr
#' @import rlang
#' @export

nest_it <- function(.data, ...){
  tidyr::nest(dplyr::group_by(.data, ...))
}

