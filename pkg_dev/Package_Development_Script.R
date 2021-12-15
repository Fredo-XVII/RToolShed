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

# Create Package, versioning, and documentation
#tmp <- file.path("FILEPATH", "RToolShed")
usethis::create_package(path = "C:\\Users\\marqu\\OneDrive\\Documents\\GitHub\\RToolShed")
usethis::use_travis()
usethis::use_appveyor()

## Package Documentation and Vignettes
usethis::use_tidy_description() # add `Roxygen: list(markdown = TRUE)` to use markdown in Roxygen comments
usethis::use_tidy_versions() # adds versions to Description file - cool
usethis::use_package_doc()
usethis::use_mit_license("Alfredo G Marquez")
#usethis::use_cc0_license("Alfredo G Marquez")
usethis::use_readme_rmd()
usethis::use_news_md(open = interactive())
usethis::use_pkgdown()
usethis::use_package_doc()
usethis::use_vignette("to_postgres") #
usethis::use_vignette("rm_db_name") #
usethis::use_namespace()

# Add Functions
usethis::use_r("rm_db_name")
usethis::use_r("to_postgres")
usethis::use_r("pg_dbCreatePrimaryIndex")
usethis::use_r("ts_exposed")
usethis::use_r("nest_it")
usethis::use_r("prep_multidplyr")
usethis::use_r("write_df_to_hive")
usethis::use_r("write_csv_to_hive")
usethis::use_r("lag_vars")
usethis::use_r("diff_vars")
usethis::use_r("sql_helper_functions")
usethis::use_r("hql_helper_functions")
usethis::use_r("pgCreateTempTable")
usethis::use_r("Holiday_Data")

# Add Packages

## Import functions
usethis::use_roxygen_md()
usethis::use_pipe()
import_pkg_list <- c("RPostgres","stringr","dbplyr","dplyr","rlang","tidyr","askpass","ssh",
                     "glue", "purrr")
purrr::map2(import_pkg_list, .y = "Imports", .f = usethis::use_package)

## Suggests

### remotes for appveyor build
suggests_pkg_list <- c("roxygen2","kableExtra","remotes","knitr","rmarkdown","testthat","covr")

purrr::map2(suggests_pkg_list, .y = "Suggests", .f = usethis::use_package)

# After adding roxygen2 params to function in R folder
roxygen2::roxygenise()
devtools::document()
devtools::load_all()

# Build Tests

usethis::use_testthat()

# Update Version
usethis::use_version()

# Build Pkgdown
pkgdown::build_site()


# Buildignore: Add directory
usethis::use_build_ignore("docs")
usethis::use_build_ignore(".Rhistory")
usethis::use_build_ignore("pkg_dev")


# Spell Check

usethis::use_spell_check()


# Functions Roxygen format
#' @title
#'
#' @description
#'
#' @details
#'
#' @param
#'
#' @return
#'
#' @examples
#'
#' @export
