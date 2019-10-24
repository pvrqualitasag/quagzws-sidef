#' ---
#' title: Package Installation in Singularity Container
#' date:  "2019-10-16"
#' ---
#' 
#' ## Disclaimer
#' This script contains a list of packages that are considered to be useful for an initial installation in a singularity container.
#' 
#' 
#' ## Packages
#' The following chunks define the list of packages and run the installation
#+ cran-pkg-def
vec_pinst_cran <- c('devtools', 
                    'BiocManager', 
                    'doParallel', 
                    'e1071', 
                    'foreach', 
                    'gridExtra', 
                    'MASS', 
                    'plyr', 
                    'stringdist', 
                    'rmarkdown', 
                    'knitr', 
                    'tinytex', 
                    'openxlsx', 
                    'LaF', 
                    'tidyverse')
# exclude that packages already installed from the list
vec_pinst_cran <- vec_pinst_cran[!vec_pinst_cran %in% installed.packages()]

# installation
if (length(vec_pinst_cran) > 0) 
  install.packages(pkgs = vec_pinst_cran, repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)

# installation of tinytex
tinytex::install_tinytex()


# packages from gitgub
vec_repo_ghub <- c("tidyverse/multidplyr", 
                   "pvrqualitasag/qgert")
vec_pkg_ghub <- sapply(vec_repo_ghub, 
                       function(x) unlist(strsplit(x, split = '/', fixed = TRUE))[2], 
                       USE.NAMES = FALSE)
vec_repo_ghub <- vec_repo_ghub[!vec_pkg_ghub %in% installed.packages()]
if (length(vec_repo_ghub) > 0) 
  devtools::install_github(vec_repo_ghub, upgrade = 'always')


