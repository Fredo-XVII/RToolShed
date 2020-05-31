# Write df to csv with df_name_dot_csv
write_df_to_csv <- function(df,folder = "./",df_name) {
  readr::write_csv(df, path = file.path(folder,df_name))
}
