#' Create Primary Indexes for Postgres Table
#'
#' Description
#'
#' @details The table name needs to include the schema in the Postgres server.
#' The list of primary keys can simply be "var1,var2,var3" because this will be
#' inserted into an SQL statement that will be sent to the server.
#'
#' @param table_name string Postgres table name.
#' @param schema_name string Posgres schema name.
#' @param primary_keys string list of primary keys.
#' @param pg_conn connection string Postgres connection pointer/string (PqConnection)
#' created from RPostgres::Postgres(). JDBC connections will break this function.
#'
#' @return The results will look like the print out below.  It is a generic print
#' out from RPostgres.  Check the table metadata in Postgres server to check primary
#' key build.
#'
#' @import rlang
#' @import dplyr
#' @import RPostgres
#' @export

pgCreatePrimaryIndex <- function (pg_conn, schema_name, table_name, primary_keys = "NA") {
  # Build SQL Names
  schema_table1 <- paste0(schema_name,'.',table_name)
  schema_table2 <- paste0(schema_name,'_',table_name,"_keys")

  # Ensure Primary Keys were supplied
  if(primary_keys == "NA") { stop("Primary Keys Not Set") }
  # Build the SQL to create the Primary Keys for the table.
  else {
    keys_create_tbl <-  dbplyr::build_sql(
      "ALTER TABLE ", dplyr::sql(schema_table1),
      " ADD CONSTRAINT ", dplyr::sql(schema_table2)," PRIMARY KEY (",dplyr::sql(primary_keys),");
      ",con = pg_conn)
  # Send the query to Postgres
    RPostgres::dbSendQuery(pg_conn, keys_create_tbl)
  }

}
