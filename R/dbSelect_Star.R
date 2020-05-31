#' @title Select Star
#'
#' This functions selects stars from a table given a connection.
#'
#' @param con A connection object
#' @param db_tbl string - name of table, in schema.table format.s
#'
#' @return a dataframe/tibble with the results of the query.
#'
#' @importFrom glue glue
#'
#' @examples
#' \dontrun{
#'
#' db_con <- RPostgres::dbConnect()
#' df <- dbSelect_Star(db_con, "schema.table")
#' }
#'
#' @export

dbSelect_Star <- function(con, db_tbl) {
  RODBC::sqlQuery(con,
                  glue::glue("
      select *
      from { db_tbl }
      ")
  )
}
