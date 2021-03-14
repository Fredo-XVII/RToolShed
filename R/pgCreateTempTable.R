#' Create Primary Indexes for Postgres Table
#'
#' Description
#'
#' @details The table name needs to include the schema in the Postgres server.
#' The list of primary keys can simply be "var1,var2,var3" because this will be
#' inserted into an SQL statement that will be sent to the server.
#'
#' @param schema_tbl character Schema.table name.
#' @param index_cols character expects a vector of column names...c('col1','col2','col3')
#' @param pg_conn connection string Postgres connection pointer/string (PqConnection)
#' created from RPostgres::Postgres(). JDBC connections will break this function.
#'
#' @return The results will look like the print out below.  It is a generic print
#' out from RPostgres.  Check the table metadata in Postgres server to check primary
#' key build.
#'
#' @import RPostgres
#' @importFrom DBI SQL
#' @export

pgCreateTempTable <- function(pg_conn, schema_tbl, index_cols, query) {

  # Build SQL
  sql_query <- DBI::SQL(query)
  # Drop Table if Exists
  RPostgres::dbSendQuery(conn = pg_conn,drop_if_exists(schema_tbl))
  print('Table Dropped')
  # Create temp table in query
  RPostgres::dbSendQuery(conn = pg_conn,sql_query)
  print('Temp Table Created')
  # Create Index Columns
  RPostgres::dbSendQuery(conn = pg_conn,create_index(schema_tbl,index_cols))
  print('Index Created')
  # Add Verbose
  RPostgres::dbSendQuery(conn = pg_conn,add_verbose(schema_tbl))
  print('Verbose Added')
  # Pull Temp Table
  print('Start Data Pull')
  RPostgres::dbGetQuery(conn = pg_conn,select_star(schema_tbl))
}
