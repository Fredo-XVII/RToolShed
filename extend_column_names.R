# Add text to columns as prefixes or suffixes
# But keep join columns unchanged.

#' @export

extend_column_names <- function(df, text = 'pre', join_cols = c(1), type = c('prefix','suffix')) {
  
  # Separate columns into left right
  df_col_names <- names(df) # All columns
  col_left <- df_col_names[keep_cols] # No change columns
  col_right <- df_col_names[-keep_cols] # prefix added columns
  
  # Create right column names based on prefix or suffix
  if (trimws(type[1]) == 'prefix') {
    col_right_ordered <- paste(text,col_right, sep = "_")
  } else {
    col_right_ordered <- paste(col_right,text, sep = "_")
  }
  
  # combine left and right column name lists'
  c(names(df[col_left]),col_right_ordered)
}
