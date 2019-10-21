#' Push R Dataframes to Postgres schemas other than Public.
#'
#' There some cases where the Postgres servers are set up so that R is not able to build tables
#' in schemas other than public. This function will delete any named tables that exit in both
#' the public schema and the destination schema, then it will re-build the data into public then
#' into the desired schema.
#'
#' @details
#' No Details
#'
#' # package parameters:
#' @param df Dataframe that will be pushed to Postgres, required.
#' @param pg_conn Postgres connection, required.
#' @param table_name <string> Name of new table in Postgres, required.
#' @param schema_name <string> Name of final schema if not public, default is public.
#' @param orderby <string> Fields to order by, used in a SQL statement, default is NA.
#' @param primary_keys <string< Fields to for primary keys, used in a SQL statement, default is NA.
#' @return Paste copy of output here.  You will get a generic message from RPostgres, check
#' Postgres server for the data to ensure that the data was transferred.
#'
#' @examples
#' \dontrun{
#' to_postgres(df = DF, pg_conn = db_CON, table_name = "data_upload", schema_name = "prod",
#' orderby = "group,date", primary_keys = "group,date")
#' }
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export

# RPostgres::dbWriteTable(con, name = DBI::Id(schema = "landing", table = "iris"), value = iris, overwrite = TRUE)
to_postgres <- function(df,pg_conn,table_name,schema_name = "public", primary_keys = "NA") {
  # Input Table
  col_tolower <- stringr::str_to_lower(base::colnames(df))

  names(df) <- col_tolower

  schema_table <- paste0(schema_name,'.',table_name)

  # Drop table public.* table if it exist, applies to both sections below
  RPostgres::dbRemoveTable(conn = pg_conn, schema_table, fail_if_missing = FALSE )

  # New Post_gres table
  RPostgres::dbWriteTable(con = pg_conn, name = DBI::Id(schema = schema_name, table = table_name), value = df, overwrite = TRUE)

  # Add keys
  if(primary_keys == "NA") { warning("Primary Keys Not Set") }
  else {
    RToolshed::dbCreatePrimaryIndex(pg_conn = pg_conn, table_name = schema_table, primary_keys = primary_keys)
  }
}
df <- datasets::mtcars
db_pg <- LSAB::pg_jdbc()
pg_conn <- LSAB::pg_jdbc()
schema_name <- "landing"
table_name <- "mtcars"
to_postgres(df = df,pg_conn = db_pg,table_name = "mtcars", schema_name = "landing")
