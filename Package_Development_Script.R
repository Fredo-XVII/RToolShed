# Package Development Script

# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

library(usethis)
library(devtools)
library(roxygen2)
library(testthat)
library(purrr)

# Create Package
#tmp <- file.path("FILEPATH", "TestContR")
usethis::use_package_doc()

# Add Functions
usethis::use_r("rm_db_name")
usethis::use_r("to_postgres")
usethis::use_r("pg_dbCreatePrimaryIndex")
usethis::use_r("ts_exposed")
usethis::use_r("nest_it")
usethis::use_r("prep_multidplyr")
usethis::use_r("write_df_to_hive")
usethis::use_r("write_csv_to_hive")


# Package Documentation
usethis::use_travis()
usethis::use_mit_license("Alfredo G Marquez")
usethis::use_readme_rmd()
usethis::use_news_md(open = interactive())
usethis::use_pkgdown()
usethis::use_package_doc()

# Import functions
usethis::use_roxygen_md()
usethis::use_pipe()
import_pkg_list <- c("RPostgres","stringr","dbplyr","dplyr","rlang","tidyr","askpass","ssh")
purrr::map2(import_pkg_list, .y = "Imports", .f = usethis::use_package)

# After adding roxygen2 params to function in R folder
devtools::document()

usethis::use_tidy_versions()
usethis::use_vignette("to_postgres") #
usethis::use_vignette("rm_db_name") #

usethis::use_namespace()
usethis::use_testthat()
