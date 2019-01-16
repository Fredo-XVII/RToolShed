#' Push R Dataframes to Postgres schemas other than Public.
#'
#' There some cases where the Postgres servers are set up so that R is not able to build tables
#' in schemas other than public. This function will create a delete any tables that exit in both
#' the public schema and the destination schema, then it will re-build the data into public then
#' into the desired schema.
#'
#' @details
#' # package parameters:
#' df <- brck_mrtr_dim  #1 input table
#' pg_conn <- db_postgres #2 pg conn
#' table_name <- "sister_app_logs" #3 name of new table
#' schema_name <- "landing" #4 name of final schema if not public
#' orderby <- "NA" #"co_loc_ref_I"
#' primary_keys <- "NA" # paste("co_loc_i", "co_loc_ref_i", sep = ",")#5 list of primary keys
#'
#' # package parameters:
#' @param df Dataframe that will be pushed to Postgres, required.
#' @param pg_conn Postgres connection, required.
#' @param table_name <string> Name of new table in Postgres, required.
#' @param schema_name <string> Name of final schema if not public, default is public.
#' @param orderby <string> Fields to order by, used in a SQL statement, default is NA.
#' @param primary_keys <string< Fields to for primary keys, used in a SQL statement, default is NA.
#' @return Paste copy of output here
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
to_postgres <- function(df,pg_conn,table_name,schema_name = "public",orderby = "NA", primary_keys = "NA") {
  # Input Table
  col_tolower <- stringr::str_to_lower(base::colnames(df))

  names(df) <- col_tolower

  public_table <- paste0("public.",table_name)

  # Drop table public.* table if it exist, applies to both sections below
  RPostgres::dbRemoveTable(conn = pg_conn, public_table, fail_if_missing = FALSE )

  # New Post_gres table

  ## If schema == public
  if ( (trimws(tolower(schema_name))) == "public" ) {
    RPostgres::dbWriteTable(pg_conn, name = table_name, value = df, row.names = FALSE, overwrite = TRUE)

    if(primary_keys == "NA") { warning("Primary Keys Not Used") }
    else {
      keys_create_tbl <-  dbplyr::build_sql(
        "ALTER TABLE ", dplyr::sql(public_table),
        " ADD CONSTRAINT ", dplyr::sql(paste0(table_name,"_keys"))," PRIMARY KEY (",dplyr::sql(primary_keys),");
        ")
      RPostgres::dbSendQuery(pg_conn, keys_create_tbl)
    }


  } else {
    RPostgres::dbWriteTable(pg_conn, name = table_name, value = df, row.names = FALSE, overwrite = TRUE)

    # Create Table Name
    new_table <- paste0(schema_name,'.',table_name)

    # Drop Old Table
    drop_new_tbl <- dbplyr::build_sql("DROP TABLE IF EXISTS ", dplyr::sql(new_table))
    RPostgres::dbSendQuery(pg_conn, drop_new_tbl)

    # Build New Table
    create_pg_tbl <- dbplyr::build_sql("
                                       CREATE TABLE IF NOT EXISTS ", dplyr::sql(new_table), " AS
                                       SELECT *
                                       FROM ", dplyr::sql(public_table), "
                                       ORDER BY ", dplyr::sql(orderby), "
                                       ")

    create_pg_tbl2 <-
      if(orderby == "NA") {
        gsub("ORDER BY NA", " ",create_pg_tbl)
      } else {create_pg_tbl}

    RPostgres::dbSendQuery(pg_conn, create_pg_tbl2)

    if(primary_keys == "NA") { warning("Primary Keys Not Set") }
    else {
      keys_create_tbl <-  dbplyr::build_sql(
        "ALTER TABLE ", dplyr::sql(new_table),
        " ADD CONSTRAINT ", dplyr::sql(paste0(table_name,"_keys"))," PRIMARY KEY (",dplyr::sql(primary_keys),");
        ")
      RPostgres::dbSendQuery(pg_conn, keys_create_tbl)
    }

  }

  }
