#' Push R Dataframes to Postgres

require(RPostgres)
require(stringr)
require(dbplyr)

## package parameters:
#df <- brck_mrtr_dim  #1 input table
#pg_conn <- db_postgres #2 pg conn
#table_name <- "sister_app_logs" #3 name of new table
#schema_name <- "landing" #4 name of final schema if not public
#orderby <- "NA" #"co_loc_ref_I"
#primary_keys <- "NA" # paste("co_loc_i", "co_loc_ref_i", sep = ",")#5 list of primary keys

# Example:
# to_postgres(df = brck_mrtr_dim, pg_conn = db_XXX, table_name = "brck_mrtr_dim", schema_name = "prod", orderby = "co_loc_ref_i", primary_keys = "co_loc_i,co_loc_ref_i")

to_postgres <- function(df,pg_conn,table_name,schema_name,orderby = "NA", primary_keys = "NA") {
  # Input Table
  col_tolower <- stringr::str_to_lower(base::colnames(df))

  names(df) <- col_tolower

  public_table <- paste0("public.",table_name)

  # Drop table public.* table if it exist, applies to both sections below
  RPostgres::dbRemoveTable(conn = con, public_table, fail_if_missing = FALSE )

  # New Post_gres table

  ## If schema == public
  if ( (trimws(tolower(schema_name))) == "public" ) {
    RPostgres::dbWriteTable(pg_conn, name = table_name, value = df, row.names = FALSE, overwrite = TRUE)

    if(primary_keys == "NA") { warning("Primary Keys Not Used") }
    else {
      keys_create_tbl <-  dbplyr::build_sql(
        "ALTER TABLE ", sql(public_table),
        " ADD CONSTRAINT ", sql(paste0(table_name,"_keys"))," PRIMARY KEY (",sql(primary_keys),");
        ")
      RPostgres::dbSendQuery(pg_conn, keys_create_tbl)
    }


  } else {
    RPostgres::dbWriteTable(pg_conn, name = table_name, value = df, row.names = FALSE, overwrite = TRUE)

    # Create Table Name
    new_table <- paste0(schema_name,'.',table_name)

    # Drop Old Table
    drop_new_tbl <- dbplyr::build_sql("DROP TABLE IF EXISTS ", sql(new_table))
    RPostgres::dbSendQuery(con, drop_new_tbl)

    # Build New Table
    create_pg_tbl <- dbplyr::build_sql("
                                       CREATE TABLE IF NOT EXISTS ", sql(new_table), " AS
                                       SELECT *
                                       FROM ", sql(public_table), "
                                       ORDER BY ", sql(orderby), "
                                       ")

    create_pg_tbl2 <-
      if(orderby == "NA") {
        gsub("ORDER BY NA", " ",create_pg_tbl)
      } else {create_pg_tbl}

    RPostgres::dbSendQuery(pg_conn, create_pg_tbl2)

    if(primary_keys == "NA") { warning("Primary Keys Not Set") }
    else {
      keys_create_tbl <-  dbplyr::build_sql(
        "ALTER TABLE ", sql(new_table),
        " ADD CONSTRAINT ", sql(paste0(table_name,"_keys"))," PRIMARY KEY (",sql(primary_keys),");
        ")
      RPostgres::dbSendQuery(pg_conn, keys_create_tbl)
    }

  }

  }
