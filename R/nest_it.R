#' @title Nest Dataframe
#'
#' Simple function to nest dataframes given a list of column names.
#'
#' @import dplyr
#' @import tidyr
#' @import rlang
#' @export

nest_it <- function(.data, ...){
  df_group_by <- tidyr::nest(dplyr::group_by(.data, ...))
  return(df_group_by)
}

