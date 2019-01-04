#' Remove Database Names from Columns
#' Remove the database column extensions that are created when query databases such as Hive.

rm_db_name <- function(df,db_name) {
  df_cols <- colnames(df)
  df_cols <- stringr::str_remove(df_cols,paste0(db_name,"."))
  names(df) <- df_cols
  return(df)
} 
