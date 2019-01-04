# Package Development Script

library(usethis)
library(devtools)
library(roxygen2)
library(testthat)
library(purrr)

# Create Package
#tmp <- file.path("FILEPATH", "TestContR")
#create_package(tmp)

# Package Documentation
usethis::use_mit_license("Alfredo G Marquez")
usethis::use_readme_rmd()
usethis::use_news_md(open = interactive())

# Import functions
usethis::use_roxygen_md()
usethis::use_pipe()
import_pkg_list <- c("RPostgres","stringr","dbplyr","dplyr")
purrr::map2(import_pkg_list, .y = "Imports", .f = usethis::use_package)

# After adding roxygen2 params to function in R folder
devtools::document()

usethis::use_tidy_versions()
usethis::use_vignette("to_postgres") #

usethis::use_namespace()
usethis::use_testthat()
