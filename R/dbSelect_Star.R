## Function to get data
dbSelect_Star <- function(con, db_tbl) {
  RODBC::sqlQuery(con,
                  glue::glue("
      select *
      from { db_tbl }
      ")
  )
}
