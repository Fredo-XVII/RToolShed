#' @title Helper functions for common SQL Statements
#'
#' @details The table name needs to include the schema in the Postgres server.
#' The list of primary keys can simply be "var1,var2,var3" because this will be
#' inserted into an SQL statement that will be sent to the server.
#'
#' @param schema_tbl character Schema.table name.
#' @param index_cols character expects a vector of column names...c('col1','col2','col3')
#'
#' @return These functions return common SQL statements that can be combined to
#' to build a complete pipeline of commands such as drop, create, create index.
#'
#' @name SQL_HELPER_FUNCTIONS
#'
#' @importFrom glue glue


#' @export
#' @rdname SQL_HELPER_FUNCTIONS
select_star <- function(schema_tbl) {sprintf('select * from %s',schema_tbl)}

#' @export
#' @rdname SQL_HELPER_FUNCTIONS
drop_if_exists <- function(schema_tbl) {sprintf('drop table if exists %s;',schema_tbl)}

#' @export
#' @rdname SQL_HELPER_FUNCTIONS
add_verbose <- function(schema_tbl) {sprintf('analyse verbose %s;',schema_tbl)}

#' @export
#' @rdname SQL_HELPER_FUNCTIONS
create_index <- function(schema_tbl, index_cols) {
  index_string <- paste(index_cols,collapse = ",")
  glue::glue('create index { `schema_tbl` }_index on { `schema_tbl` }({ `index_string` });');
}
