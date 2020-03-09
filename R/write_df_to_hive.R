#' @title Write an R dataframe to Hive
#'
#' @details
#' Uploads an R dataframe and uploads it to Hive.  This assumes that when you log into
#' Hive/Hadoop, the login is similar to `XXXXX@edge.hadoop.co.com``
#'
#' @param df dataframe Dataframe to upload.
#' @param id string ID of user
#' @param server string server extention or path
#' @param schema_table string "schema.table" Name of the table to write to in Hive.
#' @return Does not return anything.
#'
#' @examples
#' \dontrun{
#' library(ssh)
#' library(dplyr)
#' library(readr)
#' library(rstudioapi)
#' df <- mtcars
#' zid <- 'XXXXX'
#' server <- 'edge.hadoop.co.com'
#' schema_table <- 'schema.table'
#' .pwd <- rstudioapi::askForPassword('password')
#' write_df_to_hive(df = df, id = zid, server = server, schema_table = schema_table)
#' }
#'
#' @importFrom magrittr %>%
#' @import ssh
#' @import dplyr
#' @import readr
#' @import askpass
#' @export

write_df_to_hive <- function(df, id, server, schema_table) {

  # Get Password and set csv file name
  .pwd <- askpass::askpass('password')
  files <- c("table_for_hive.csv")

  # Build MetaData
  readr::write_csv(df, files)
  col_names <- names(df)
  col_types <- sapply(df, class)
  schema_df <- data.frame(col_names, col_types) %>%
    dplyr::mutate(hive_col_types = dplyr::case_when(tolower(col_types) %in% c('character', 'date') ~ 'STRING',
                                      tolower(col_types) == 'integer' ~ 'INT',
                                      tolower(col_types) == 'numeric' ~ 'FLOAT',
                                      TRUE ~ 'STRING'))
  cols_for_hive <- paste(schema_df$col_names, " ", schema_df$hive_col_types, collapse = ",\n")

  # ssh to hive
  login <- paste0(toupper(id),'@',server)
  session <- ssh::ssh_connect(login, passwd = .pwd)

  # Upload Csv file
  files <- c('table_for_hive.csv')
  ssh::scp_upload(session, files, to = "~/data-from-rstudio/")

  query <- dplyr::sql(paste0(
    "hive -e ",
    "'create table if not exists ", schema_table, " (\n",
    cols_for_hive,
    ') COMMENT "TABLE CREATED BY R CODE" \n',
    'ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ","
    STORED AS TEXTFILE ',
    'tblproperties ("skip.header.line.count"="1");',
    "\n LOAD DATA LOCAL INPATH ", '"/home_dir/',
    tolower(id),
    "/data-from-rstudio/",
    '" OVERWRITE INTO TABLE ',
    schema_table,
    ";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query)))

  # Disconnect and rm password and csv file
  ssh::ssh_disconnect(session)
  rm(.pwd)
  file.remove(sprintf('./%s',files))
}
