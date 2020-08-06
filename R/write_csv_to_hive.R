#' @title Write a CSV file to Hive
#'
#' @details
#' Uploads a CSV file and uploads it to Hive.  This assumes that when you log into
#' Hive/Hadoop, the login is similar to `XXXXX@edge.hadoop.co.com``
#'
#' @param csv_file path to CSV file to upload, if only the name of file is provided,
#' then it is assumed the file is in the current working directory reported by
#' getwd(); see dplyr::read_csv documentation for further information.
#' @param id string ID of user. Password will be requested from the user at function call.
#' @param server string server extention or path
#' @param schema_table string "schema.table" Name of the table to write to in Hive.
#' @param append_data logical, defaults to FALSE for overwrite; TRUE appends the to the data.
#' @return Does not return anything.
#'
#' @examples
#' \dontrun{
#' library(ssh)
#' library(dplyr)
#' library(readr)
#' library(askpass)
#' library(magrittr)
#' df <- mtcars
#' zid <- 'XXXXX'
#' server <- 'edge.hadoop.co.com'
#' schema_table <- 'schema.table'
#' file <- c('table_for_hive.csv')
#' write_csv_to_hive(csv_file = file, id = zid, server = server, schema_table = schema_table)
#' }
#'
#' @importFrom magrittr %>%
#' @import ssh
#' @import dplyr
#' @import readr
#' @import askpass
#' @export

write_csv_to_hive <- function(csv_file, id, server, schema_table, append_data = FALSE) {

  # Get Password and set csv file name
  .pwd <- askpass::askpass('password')

  # Build MetaData
  df <- readr::read_csv(file = csv_file)
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

  # Make Directory for SCP
  hdfs_dir <- sprintf("/home_dir/%s/write_csv_to_hive/",tolower(id))
  ssh::ssh_exec_wait(session, command = c(paste('mkdir',hdfs_dir)))

  # Upload Csv file
  ssh::scp_upload(session, csv_file, to = hdfs_dir)

  # Append or not Append, that is the question
  append_script <- if (append_data == TRUE) {
    ' INTO TABLE '
  } else {
    ' OVERWRITE INTO TABLE '
  }

  query <- dplyr::sql(paste0(
    "hive -e ",
    "'create table if not exists ", schema_table, " (\n",
    cols_for_hive,
    ') COMMENT "TABLE CREATED BY R CODE" \n',
    'ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ","
    STORED AS TEXTFILE ',
    'tblproperties ("skip.header.line.count"="1");',
    "\n LOAD DATA LOCAL INPATH ",
    '"',hdfs_dir,
    '"',append_script,
    schema_table,
    ";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query)))

  # Disconnect and rm password and csv file from hadoop
  ssh::ssh_exec_wait(session, command = c(sprintf('rm -rf %s',hdfs_dir))) # rm -rf dirname
  ssh::ssh_disconnect(session)
  rm(.pwd)
}
