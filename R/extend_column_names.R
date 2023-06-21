# Add text to columns as prefixes or suffixes
# But keep join columns unchanged.

#' @export

ext_col_names <- function(df, .text = 'pre', .join_cols = "drvr", .type = c('prefix','suffix')) {
  
  # Separate columns into left right
  df_col_names <- names(df) # All columns
  col_left <- names(df[.join_cols]) # No change columns, takes advantage of df subsetting
  col_right <- df_col_names[!(df_col_names %in% col_left)] # prefix added columns
  
  # Create right column names based on prefix or suffix
  if (trimws(.type[1]) == 'prefix') {
    col_right_ordered <- paste(.text,col_right, sep = "_")
  } else {
    col_right_ordered <- paste(col_right,.text, sep = "_")
  }
  
  # combine left and right column name lists'
  c(col_left,col_right_ordered)
}
