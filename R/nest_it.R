#' @title Nest Dataframe
#' @import dplyr
#' @export

nest_it <- function(.data, ...){
  group_var <- enquos(...)
  df_group_by <- .data %>% dplyr::ungroup() %>% dplyr::group_by(!!! group_var) %>% tidyr::nest()
  return(df_group_by)
}
