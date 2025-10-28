#' Consistent installation of pkgs packages for Development
#'
#' @param pkgs.packages character Vector of character names of pkgs packages.
#' @param path.to.pkgs character Path to directory of pkgs packages source files.
#' @param .lib_loc character Path to where the pkgs package library is located.
#' @param .cran_pkgs logical defaults to FALSE. If TRUE, then will pull the packages
#' from the pkgs CRAN repo in Artifactory.
#'
#' @return pkgs packages re-installed and message that packages have been installed.
#' @export
#'
#' @examples
#' \dontrun{
#' # For all pkgs packages
#' install_pkgs_pkgs() 
#' # For a specific pkgs package
#' install_pkgs_pkgs('pkgs')
#' # Install from the pkgs CRAN repo in artifactory
#' install_pkgs_pkgs('pkgs', .cran_pkgs = TRUE)
#' }

install_pkgs_pkgs <- function( pkgs.packages = NULL, path.to.pkgs = "/h/pkgs_folder", .lib_loc = NULL, .cran_pkgs = FALSE) {
  
  # Set default paths, library location, and packages
  if (is.null(pkgs.packages)) {
    pkgs.packages <- c("pkgs", "pkgsr", "pkgstool", "pkgsmodel", "pkgspipeline")
  } else {
    pkgs.packages <- c(pkgs.packages)
  }

  # Defaults to the /pkgslibs in the container  
  if (is.null(.lib_loc)) {
    .lib_loc = .libPaths()[[2]]
  }
  
  # Install pkgs* packages inside the custom library paths
  if (.cran_pkgs) {
    message('Looking for pkgs packages in this path: ', getOption('repos')[['pkgs_REPO']],'.')
    easypkgs::remove_loaded_pkgs(pkgs = pkgs.packages)
    install.packages(pkgs.packages, 
                     lib = .libPaths()[[2]], 
                     repos = getOption('repos')[['pkgs_REPO']], type = 'source',
                     INSTALL_opts = '--no-html',
                     Ncpus = parallel::detectCores())
  } else {
    message('Looking for pkgs packages in this path: ', path.to.pkgs,  ' If this is incorrect, please set the path.to.pkgs argument.')
    for (pkg in pkgs.packages) {
      install.packages(pkgs = file.path(path.to.pkgs, pkg), 
                       lib = .lib_loc,
                       repos = NULL, type = "source", 
                       INSTALL_opts = "--no-html",
                       Ncpus = parallel::detectCores())
    }
  }
  
  message("\n",
          "pkgs packages rebuilt.\n",
          "Restarting R")

  restart.R()
}


#' Restart R
#'
#' @return R Starts are and unloads packages
#' @export
#'
#' @examples
#' \dontrun{
#' restart.R()
#' }

restart.R <- function() {
  # Get loaded packages
  pkgs <- loaded_pkgs()
  # Remove loaded packages
  remove_loaded_pkgs(pkgs)
  # Restart from RStudio
  rstudioapi::restartSession()
}


#' Get loaded packages
#'
#' @return Provides a character vector of the loaded packages.
#' @export
#'
#' @examples
#' \dontrun{
#' pkgs <- loaded_pkgs() 
#' }

loaded_pkgs <- function () {
  row.names(as.matrix(sessionInfo()$otherPkgs))
}


#' Detaches and Unloads a vector of packages
#'
#' @param pkgs character A character vector from the `loaded_pkgs()` function.
#'
#' @return A message, with side effects of packages unloading.
#' @export
#'
#' @examples
#' \dontrun{
#' pkgs <- loaded_pkgs()
#' remove_loaded_pkgs(pkgs)
#' }

remove_loaded_pkgs <- function(pkgs){
  # Find packages in search() by index
  pkgs_vector <- paste0("package:",pkgs)
  find_pkgs <- search() %in% pkgs_vector
  # Detach packages
  for (pkg_name in search()[find_pkgs]) {
    detach(name = pkg_name, character.only = TRUE, unload = TRUE, force = TRUE)
    message('Package detached: ', pkg_name)
  }
  message("Done unloading packages.")
}
