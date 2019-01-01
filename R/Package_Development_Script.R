# Package Development Script

library(usethis)
library(devtools)
library(roxygen2)
library(testthat)

# Create Package
#tmp <- file.path("FILEPATH", "TestContR")
#create_package(tmp)

usethis::use_mit_license("Alfredo G Marquez")
usethis::use_readme_rmd()
use_news_md(open = interactive())

pckg_list <- c("tidyverse","reshape2","dplyr","RPostgres")
use_package( "tidyverse", type = "Import")
use_package( "reshape2", type = "Import")

# After adding roxygen2 params to function in R folder
devtools::document()

usethis::use_tidy_versions()
usethis::use_vignette("to_postgres") #

usethis::use_namespace()
use_testthat()
