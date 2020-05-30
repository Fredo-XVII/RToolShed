#' Install Packages into R_LIBS_USER
#'
#' This function will install into the folder listed under the environmental
#' variable R_LIBS_USER. The user can specify this in the systems environmental
#' variables or in the .Renviron file.
#'
#' @details
#' Installs packages into the folder referenced by the R_LIBS_USER environmental
#' variable.
#'
#' @examples
#' \dontrun{
#'   pkgs <- c("RODBC","RJDBC")
#'   install.pkgs.user_lib(pkgs = pkgs, dependencies = TRUE)
#' }
#'
#' @param pkgs string character vector list of packages
#' @param ... any other arguments passed to install.packages()
#'
#' @importFrom utils install.packages

#' @export

install.pkgs.user_lib <- function(pkgs,...){
  #purrr::map(pkgs,install.packages(.,lib = Sys.getenv("R_LIBS_USER"),...))
  for (pkg in pkgs){
    install.packages(pkg,lib = Sys.getenv("R_LIBS_USER"),...)
  }
}
