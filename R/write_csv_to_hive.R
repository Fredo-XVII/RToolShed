
library(ssh)
library(dplyr)
library(readr)

# Parameters
df <- mtcars
zid <- 'XXXXX'
server <- 'edge.hadoop.co.com'
schema_table <- 'schema.table'
.pwd <- .rs.askForPassword('password')
file <- c('table_for_hive.csv')

write_csv_to_hive(csv_file = file, id = zid, server = server, schema_table = schema_table)

write_csv_to_hive <- function(csv_file, id, server, schema_table) {

  # Get Password and set csv file name
  .pwd <- .rs.askForPassword('password')

  # Build MetaData
  df <- readr::read_csv(csv_file)
  col_names <- names(df)
  col_types <- sapply(df, class)
  schema_df <- data.frame(col_names, col_types) %>%
    mutate(hive_col_types = case_when(tolower(col_types) %in% c('character', 'date') ~ 'STRING',
                                      tolower(col_types) == 'integer' ~ 'INT',
                                      tolower(col_types) == 'numeric' ~ 'FLOAT',
                                      TRUE ~ 'STRING'))
  cols_for_hive <- paste(schema_df$col_names, " ", schema_df$hive_col_types, collapse = ",\n")

  # ssh to hive
  login <- paste0(id,'@',server)
  session <- ssh_connect(login, passwd = .pwd)

  # Upload Csv file
  scp_upload(session, csv_file, to = "~/data-from-rstudio/")

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

  ssh_exec_wait(session, command = c(dplyr::sql(query)))

  # Disconnect and rm password and csv file
  ssh_disconnect(session)
  rm(.pwd)
}
