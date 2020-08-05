#' @title Write a Dataframe to Hive 3
#'
#' @details Uploads an R dataframe to the edge node as a CSV, uploads it to
#' Hive, and creates a managed table. The function also cleans up the csv file
#' on the edge node and in the users' hdfs home location.  This assumes that
#' when you log into Hive/Hadoop, the login is similar to
#' `XXXXX@edge.hadoop.co.com`
#'
#' @param df must be a dataframe/tibble
#' @param id string ID of user. Password will be requested at function call.
#' @param schema string schema name in hive
#' @param table string name for the table in hive.  One will be created if not
#'   exists.
#' @param server string server extention or path
#' @param append_data logical, defaults to FALSE for overwrite; TRUE appends the
#'   to the data.
#'
#' @return Does not return anything.
#'
#' @examples
#' \dontrun{
#' library(ssh)
#' library(dplyr)
#' library(readr)
#' library(rstudioapi)
#' library(magrittr)
#'
#' df <- as.data.frame(Seatbelts)
#' id <- 'XXXXX'
#' server <- 'edge.hadoop.co.com'
#' schema <- 'schema'
#' table <- 'table'
#' write_df_to_hive3(df =
#'                    id = id,
#'                    schema = schema,
#'                    table = table,
#'                    server = server,
#'                    append_data = FALSE)
#' }
#'
#' @importFrom magrittr %>%
#' @import ssh
#' @import dplyr
#' @import readr
#' @import askpass
#' @export

write_df_to_hive3 <- function(df,
                              id,
                              schema,
                              table,
                              server,
                              append_data = FALSE) {

  # build parameters for table names
  schema_table <- paste0(tolower(schema),".",table) # Managed Table
  schema_table_stg <- paste0(schema_table,"_stg") # External Table
  csv_name <- paste0(substitute(df),".csv")
  csv_folder <- "."
  csv_file <- file.path(csv_folder,csv_name) # Build path to file

  # get gassword and set csv file name
  .pwd <- askpass::askpass('password')

  # build metadata
  readr::write_csv(df, csv_file)
  col_names <- names(df)
  col_types <- sapply(df, class)
  schema_df <- data.frame(col_names, col_types) %>%
    dplyr::mutate(hive_col_types = dplyr::case_when(tolower(col_types) %in% c('character', 'date') ~ 'STRING',
                                                    tolower(col_types) == 'integer' ~ 'INT',
                                                    tolower(col_types) == 'numeric' ~ 'FLOAT',
                                                    TRUE ~ 'STRING'))
  cols_for_hive <- paste(schema_df$col_names, " ", schema_df$hive_col_types, collapse = ",\n")

  # ssh to hive ---------------------------------------------------------------
  login <- paste0(toupper(id),'@',server)
  session <- ssh::ssh_connect(login, passwd = .pwd)

  # make directory for SCP to edge node
  edge_dir <- sprintf("/home_dir/%s/write_df_to_hive",tolower(id))
  ssh::ssh_exec_wait(session, command = c(paste('mkdir',edge_dir)))

  # upload csv file to edge node
  ssh::scp_upload(session, csv_file, to = edge_dir)

  # prep hdfs and copy csv file to hdfs from edge node:
  # hdfs dfs -put -f <local path> <hdfs path> <=> moves file to folder
  ssh::ssh_exec_wait(session, command = c('hdfs getconf -confKey fs.defaultFS'), std_out = './name_node.txt')
  name_node <- read_file('./name_node.txt') %>% stringr::str_replace("\n","")
  hdfs_dir <- paste0(file.path(name_node,"user",toupper(id),"hive",table),"/")
  ssh::ssh_exec_wait(session, command = c(paste('hdfs dfs -mkdir',hdfs_dir)))
  ssh::ssh_exec_wait(session, command = c(paste('hdfs dfs -put -f',file.path(edge_dir,csv_name),hdfs_dir)))


  # Step #1: build external table ---------------------------------------------
  query_external <- dplyr::sql(paste0(
    "hive -e ",
    "'CREATE EXTERNAL TABLE IF NOT EXISTS ", schema_table_stg, " (\n",
    cols_for_hive,
    ') COMMENT "TABLE CREATED BY R CODE" \n',
    'ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ","
    STORED AS TEXTFILE ',
    "\n LOCATION ",
    '"',file.path('',"user",toupper(id),"hive",table),'/"',
    '\n tblproperties ("skip.header.line.count"="1")',
    ";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query_external)))

  # Step #2: build the manage table ---------------------------------
  # build managed table schema
  query_managed <- dplyr::sql(paste0(
    "hive -e ",
    "'create table if not exists ", schema_table, " (\n",
    cols_for_hive,
    ') COMMENT "TABLE CREATED BY R CODE" \n',
    ";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query_managed)))

  # overwrite/append managed table with data from staged external table
  # append or not append, that is the question
  append_script <- if (append_data == TRUE) {
    ' INSERT INTO TABLE '
  } else {
    ' INSERT OVERWRITE TABLE '
  }

  load_managed <- dplyr::sql(paste0(
    "hive -e ",
    "'", append_script, schema_table,
    " \n select * from ", schema_table_stg,";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(load_managed)))

  # Step #3: clean up  --------------------------------------------------------
  # remove stage table and external file
  query_rm_stg <- dplyr::sql(
    sprintf("hive -e 'drop table %s;'", schema_table_stg)
  )

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query_rm_stg)))
  ssh::ssh_exec_wait(session, command = c(paste('hdfs dfs -rm -r',hdfs_dir)))

  # Disconnect and rm password and csv file from edge node
  ssh::ssh_exec_wait(session, command = c(sprintf('rm -rf %s',edge_dir)))
  ssh::ssh_disconnect(session)
  file.remove('./name_node.txt')
  file.remove(sprintf('./%s',csv_file))
  rm(.pwd)
}

