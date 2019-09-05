#' ---
#' title: Package Installation Protocol
#' date:  "`r Sys.Date()`"
#' ---
#' 
#' 
#' ## Disclaimer
#' Different experiments and approaches to install R packages locally are documented.
#' 
#' 
#' ## Background
#' For certain reasons, the installation of local packages fails with packages being already installed not being found.


#' New approach for installing packages using the commandline argument `--vanilla` to prevent loading any
#' settings from .Rprofile or possibly other sources.
#' 
#+ rvanillastart, eval=FALSE
system("R --vanilla")

#' Setting local library directory with the `.libPaths()` function
#+ setlocallibpath, eval=FALSE
.libPaths('/home/zws/lib/R/libdev');.libPaths()
install.packages('stringi', lib = .libPaths()[1], repo = 'https://cran.rstudio.com')

#' Try installation of dependent package ==> worked
#+ installdeppkg, eval=FALSE 
install.packages('stringr', lib=.libPaths()[1], repo='https://cran.rstudio.com')

#' With the following statement, we try to get a big package installed from the shell
#+ pkginstallfromshell, eval=FALSE
system("R --vanilla -e \".libPaths('/home/zws/lib/R/libdev');install.packages('Rcpp', lib = .libPaths()[1], repo = 'https://cran.rstudio.com', dependencies = TRUE)\"")


