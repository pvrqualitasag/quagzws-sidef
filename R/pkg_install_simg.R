#' ---
#' title: Package Installation in Singularity Container
#' date:  "2019-10-16"
#' ---
#' 
#' ## Disclaimer
#' This script contains a list of packages that are considered to be useful for an initial installation in a singularity container.
#' 
#' 
#' ## Options
#' Check whether packages must be force updated
if (!exists("force_update")) force_update <- FALSE


#' ## Packages
#' ### CRAN
#' The following chunk reads the list of cran packages to be installed, if any and installs the packages.
#+ cran-pkg-def
if (exists("cran_pkg") && file.exists(cran_pkg)){
  vec_pinst_cran <- readLines(con = file(cran_pkg))
  # exclude that packages already installed from the list, if update is not forced
  if (!force_update)
    vec_pinst_cran <- vec_pinst_cran[!vec_pinst_cran %in% installed.packages()]
  
  # installation
  if (length(vec_pinst_cran) > 0) 
    install.packages(pkgs = vec_pinst_cran, repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)
  
  # installation of tinytex
  if ('tinytex' %in% vec_pinst_cran){
    tinytex::install_tinytex()
  }
  
}


#' ### Github
#' Packages from gitgub are read from a file and are installed
#+ ghub-pkg-def
if (exists("ghub_pkg") && file.exists(ghub_pkg)){
  vec_repo_ghub <- readLines(con = file(ghub_pkg))
  vec_pkg_ghub <- basename(vec_repo_ghub)
  # check whether update is forced
  if (!force_update)
    vec_repo_ghub <- vec_repo_ghub[!vec_pkg_ghub %in% installed.packages()]
  if (length(vec_repo_ghub) > 0) 
    remotes::install_github(vec_repo_ghub, upgrade = 'always')
}


#' ### Local
#' Local packages are read from a file and installed
#+ local-pkg
if (exists("local_pkg") && file.exists(local_pkg)){
  vec_repo_local <- readLines(con = file(local_pkg))
  vec_pkg_local <- basename(vec_repo_local)
  # check whether update is forced
  if (!force_update)
    vec_repo_local <- vec_repo_local[!vec_pkg_local %in% installed.packages()]
  # loop over local packages
  for (p in seq_along(vec_repo_local)){
    pkg <- vec_repo_local[p]
    remotes::install_local(path = pkg, build_vignettes = FALSE)
  }
}
  

