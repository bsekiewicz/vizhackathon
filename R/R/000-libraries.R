# load libraries and install them if required -----------------------------

# packages || specify packages to be loaded during analysis
packages <- c(
  "magrittr", "dplyr", "stringi",       # pipes + data munging
  "jsonlite", "readr",                  # reading data
  "ggplot2"                             # plots
)

# to_install || verify which packages needs to be additionally installed
to_install <- packages[!(packages %in% rownames(installed.packages()))]

## install packages
invisible(sapply(to_install, install.packages))

## load packages
invisible(sapply(packages, library, character.only = TRUE))

## clean up
rm(packages); rm(to_install)