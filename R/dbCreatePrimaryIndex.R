#' Create Primary Indexes for Postgres Table
#'
#' Description
#'
#' @details The table name needs to include the schema in the Postgres server.
#' The list of primary keys can simply be "var1,var2,var3" because this will be
#' inserted into an SQL statement that will be sent to the server.
#'
#' @param table_name <string> Postgres table name including schema.
#' @param primary_keys <string> list of primary keys.
#'
#' @return The results will look like the print out below.  It is generic.
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export

dbCreatePrimaryIndex <- function (pg_conn, table_name, primary_keys = "NA") {
  # Ensure Primary Keys were supplied
  if(primary_keys == "NA") { stop("Primary Keys Not Set") }
  # Build the SQL to create the Primary Keys for the table.
  else {
    keys_create_tbl <-  dbplyr::build_sql(
      "ALTER TABLE ", dplyr::sql(table_name),
      " ADD CONSTRAINT ", dplyr::sql(paste0(table_name,"_keys"))," PRIMARY KEY (",dplyr::sql(primary_keys),");
      ")
  # Send the query to Postgres
    RPostgres::dbSendQuery(pg_conn, keys_create_tbl)
  }

}
