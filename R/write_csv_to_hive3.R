#' @title Write a CSV file to Hive 3
#'
#' @details
#' Uploads a CSV file and uploads it to Hive.  This assumes that when you log into
#' Hive/Hadoop, the login is similar to `XXXXX@edge.hadoop.co.com``
#'
#' @param csv_file path to CSV file to upload, if only the name of file is provided,
#' then it is assumed the file is in the current working directory reported by
#' getwd(); see dplyr::read_csv documentation for further information.
#' @param id string ID of user. `.pwd` will be requested from the user at function call.
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
#' library(rstudioapi)
#' library(magrittr)
#' df <- mtcars
#' zid <- 'XXXXX'
#' server <- 'edge.hadoop.co.com'
#' schema_table <- 'schema.table'
#' .pwd <- askpass::askpass('password')
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

write_csv_to_hive <- function(csv_file,
                              csv_name,
                              id,
                              server,
                              #schema_table,
                              schema,
                              table,
                              append_data = FALSE) {

  # buil parameters
  schema_table <- paste0(tolower(schema),".",table) # Managed Table
  schema_table_stg <- paste0(schema_table,"_stg") # External Table

  # get gassword and set csv file name
  .pwd <- askpass::askpass('password')

  # build metadata
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

  # make directory for SCP to edge node
  edge_dir <- sprintf("/home_dir/%s/write_csv_to_hive",tolower(id)) # hdfs_dir
  ssh::ssh_exec_wait(session, command = c(paste('mkdir',edge_dir)))

  # upload csv file
  ssh::scp_upload(session, csv_file, to = edge_dir)

  # prep hdfs and copy csv file to hdfs from edge node : hdfs dfs -mkdir /user/z001c9v/folder
  hdfs_dir <- paste0(file.path('hdfs://bigred3ns',"user",toupper(id),"hive",table),"/") # "/", # 'hdfs://bigred3ns','user'
  ssh::ssh_exec_wait(session, command = c(paste('hdfs dfs -mkdir',hdfs_dir))) # if append, then mkdir optional
  #hdfs dfs -put <local path> <hdfs path>
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
    #'tblproperties ("skip.header.line.count"="1");',
    #"\n LOAD DATA LOCAL INPATH ",
    "\n LOCATION ",
    '"',file.path('',"user",toupper(id),"hive",table),'/"',
    #'"',hdfs_dir,'"',
    #'"',' OVERWRITE INTO TABLE ',
    #schema_table_stg,
    '\n tblproperties ("skip.header.line.count"="1")',
    ";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query_external)))

  #ssh::ssh_exec_wait(session, command = c("hdfs dfs -ls hdfs://user/z001c9v/"))
  #ssh::ssh_session_info(session)

  # Step #2: build/append to the manage table ---------------------------------
  # build managed table schema
  query_managed <- dplyr::sql(paste0(
    "hive -e ",
    "'create table if not exists ", schema_table, " (\n",
    cols_for_hive,
    ') COMMENT "TABLE CREATED BY R CODE" \n',
    #'ROW FORMAT DELIMITED
    #FIELDS TERMINATED BY ","
    #STORED AS TEXTFILE ',
    #'tblproperties ("skip.header.line.count"="1");',
    #"\n LOAD DATA LOCAL INPATH ",
    #'"',hdfs_dir,
    #'"',append_script,
    #schema_table,
    ";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query_managed)))

  # load managed table with staged external table
  # Append or not Append, that is the question
  append_script <- if (append_data == TRUE) {
    ' INSERT INTO TABLE '
  } else {
    ' INSERT OVERWRITE TABLE '
  }

  load_managed <- dplyr::sql(paste0(
    "hive -e ",
    #"'insert into table ", schema_table,
    #"'insert overwrite table ", schema_table,
    "'", append_script, schema_table,
    " \n select * from ", schema_table_stg,";'"
  ))

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(load_managed)))

  # Step #3: clean up query, remove stage table -------------------------------
  query_rm_stg <- dplyr::sql(
    sprintf("hive -e 'drop table %s;'", schema_table_stg)
  )

  ssh::ssh_exec_wait(session, command = c(dplyr::sql(query_rm_stg)))

  # Disconnect and rm password and csv file from hadoop
  ssh::ssh_exec_wait(session, command = c(sprintf('rm -rf %s',edge_dir))) # rm -rf dirname
  ssh::ssh_disconnect(session)
  rm(.pwd)
}


# locations in hdfs
#managed table location: hdfs://bigred3ns/warehouse/tablespace/managed/hive/z001c9v.db/seatbelts
# hdfs://bigred3ns/user/Z001C9V/hive/seatbelts
