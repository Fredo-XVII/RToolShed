#' Remove Database Names from Columns Names.
#'
#' Remove the database column extensions that are created when query databases such as Hive.  In other words,
#' when pulling data into R from HIVE, the name of the HIVE database is prefixed to all the column names.
#' For example, if you HIVE table is called FOO, then your columns in R would be of the form FOO.variable1 FOO.variable2 ... etc.
#'
#' @param df Dataframe
#' @param db_name <string> The name of the table in the database that you want removed from the column names.
#' @return A dataframe is returned with the prefix database name of the column names removed.  In the example above
#' the new dataframe would have column names variable1, variable2...etc.
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export


rm_db_name <- function(df,db_name) {
  df_cols <- colnames(df)
  df_cols <- stringr::str_remove(df_cols,paste0(db_name,"."))
  names(df) <- df_cols
  return(df)
}
