#' @title Dataframe to CSV
#'
#' @details This function takes a dataframe and extracts the name of the dataframe
#' as text or string.  You can then use this string to name a csv file.
#'
#' @param x dataframe or tibble
#'
#' @return Returns the name of the dataframe as a text.
#'
#' @examples
#' df <- as.data.frame(datasets::cars)
#' df_name_dot_csv(df)
#'
#' @export

df_name_dot_csv <- function(x) paste0(substitute(x),".csv")
