#' Remove Database Names from Columns Names.
#'
#' Remove the database column extensions that are created when query databases such as Hive.
#' @param df Dataframe
#' @param db_name The name of the table in the database that you want removed from the column names.
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export


rm_db_name <- function(df,db_name) {
  df_cols <- colnames(df)
  df_cols <- stringr::str_remove(df_cols,paste0(db_name,"."))
  names(df) <- df_cols
  return(df)
}
