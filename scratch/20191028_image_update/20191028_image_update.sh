#' ---
#' title: Protocol of Singularity Image Update
#' date:  2019-10-28
#' ---
#' 
#' ## Disclaimer
#' Singularity Images are to be updated on all servers.
#' 
#' 
#' ## Test
#' We start with a test on `beverin`
#'
#+ test-cmd
../quagzws-sidef/bash/pull_post_simg.sh -b /qualstore03,/qualstorzws01,/qualstorora01,/qualstororatest01 \
  -i sidev -n 20191028_quagzws.simg -s shub://pvrqualitasag/quagzws-sidef

#' ## Update 
#+ update-cmd
../quagzws-sidef/bash/pull_post_simg.sh -b /qualstore03,/qualstorzws01,/qualstorora01,/qualstororatest01 \
  -i sizws -n 20191028_quagzws.simg -s shub://pvrqualitasag/quagzws-sidef
  
  
  
#' ## Functionality tests
#+ func-test
cd /qualstorzws01/data_zws/fbk
./prog/create_comp_plot_report_fbk.sh -c 1912 -p 1908


#' ## Package Update on beverin

ERROR: dependencies ‘pkgbuild’, ‘pkgload’, ‘rcmdcheck’, ‘roxygen2’ are not available for package ‘devtools’


‘pkgbuild’, ‘pkgload’, ‘rcmdcheck’, ‘roxygen2’
‘devtools’

install.packages(pkgs = 'pingr', repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)
install.packages(pkgs = 'ps', repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)
install.packages(pkgs = 'pkgbuild', repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)

install.packages(pkgs = 'pkgload', repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)

install.packages(pkgs = 'rcmdcheck', repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)

install.packages(pkgs = 'roxygen2', repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)


scales for ggplot2
install.packages(pkgs = 'scales', repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)


> warnings()
Warnmeldungen:
1: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘pingr’ hatte Exit-Status ungleich 0
2: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘cyclocomp’ hatte Exit-Status ungleich 0
3: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘pkgbuild’ hatte Exit-Status ungleich 0
4: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘egg’ hatte Exit-Status ungleich 0
5: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘pkgload’ hatte Exit-Status ungleich 0
6: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘rcmdcheck’ hatte Exit-Status ungleich 0
7: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘roxygen2’ hatte Exit-Status ungleich 0
8: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘lintr’ hatte Exit-Status ungleich 0
9: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘rhub’ hatte Exit-Status ungleich 0
10: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘caret’ hatte Exit-Status ungleich 0
11: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘tidyverse’ hatte Exit-Status ungleich 0
12: In install.packages(pkgs = vec_pinst_cran, repos = "https://stat.ethz.ch/CRAN/",  ... :
  Installation des Pakets ‘devtools’ hatte Exit-Status ungleich 0
