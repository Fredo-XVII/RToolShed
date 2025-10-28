#' @title Setup Credentials
#' @description Initializes the credentials process for the data retrieval or processing.
#' @details This will add user credentials to disk.
#' @param overwrite Logical. Default = FALSE.  If TRUE, forces credentials setup.
#' @return This function does not return a value; it is used for its side effects.
#' @export
setup_credentials <- function(overwrite = FALSE) {
  renviron_path <- file.path("/home/rstudio", ".Renviron")
  readRenviron(renviron_path)

  if (Sys.getenv("PASSWORD") == "" || Sys.getenv("USER") == "" || overwrite) {
    USER <- rstudioapi::showPrompt("Setup", "Enter your USER:")
    pwd <- askpass::askpass("Enter your password:")
    write(paste0("USER=", USER), file = renviron_path, append = TRUE)
    write(paste0("PASSWORD=", pwd), file = renviron_path, append = TRUE)

    message(
      "Credentials written to: ", renviron_path
    )
  } else {
    message(
      "Credentials already set up. Run setup(overwrite = TRUE) to overwrite.",
      "\n",
      "Loading credentials from: ", renviron_path
    )
  }
  readRenviron(renviron_path)
}
