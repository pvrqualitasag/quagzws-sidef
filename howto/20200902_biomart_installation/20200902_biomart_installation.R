#' ---
#' title: "Installation of biomaRt"
#' date:  "2020-09-02"
#' ---
#' 
#' ## Disclaimer
#' The following problem was reported by Mirjam
#' 
#' ```
#' Frage zum Installieren von packages in R:
#'   Ich habe heute versucht auf den einzelnen Rechnern “biomaRt” zu installieren. Zunächst mal bin ich nicht so ganz sicher ob meine Vorgehensweise da generell die richtige ist: Ich öffne R und installiere das Paket in dem Fall so:
#'   if (!requireNamespace("BiocManager", quietly = TRUE))
#'     install.packages("BiocManager")
#' BiocManager::install("biomaRt")
#' dann hat es einiges gemacht und an einem Punkt fragt es dann wegen dem Update der anderen Pakete (all/some/none); da wir ja hier mal ein Problem mit einem zu früh upgedateten dplyr hatten, habe ich jeweils non gesagt.
#' Dann kam folgende Meldung:
#'   In install.packages(...) :
#'   installation of package ‘biomaRt’ had non-zero exit status
#' Entsprechend scheint das Paket auch nicht installiert zu sein. Auf beverin habe ich das gleiche vor 1-2 Wochen gemacht und dort hat es geklappt.
#' Meine Fragen:
#'   Ist das überhaupt das richtige Vorgehen zum Installieren von R packages im Container?
#'   Wie bekomme ich biomaRt zum Laufen?
#' ```
#' 
#' ## Tests
#' Server: dom
if (! require(BiocManager)) 
  install.packages('BiocManager', dependencies = TRUE, repos = 'https://cran.rstudio.com')

if (! require(XML))
  install.packages("XML", repos = "http://www.omegahat.net/R")

if (! require(biomaRt))
  BiocManager::install("biomaRt", update = FALSE, dependencies = TRUE)

library("biomaRt")

#' Other servers
#for s in beverin castor dom niesen speer
for s in castor
do
  echo " * Running on server $s"
  ssh zws@$s 'singularity exec instance://sizws R -e "if (! require(BiocManager)) install.packages(\"BiocManager\", dependencies = TRUE, repos = \"https://cran.rstudio.com\")"'
  ssh zws@$s 'singularity exec instance://sizws R -e "if (! require(XML)) install.packages(\"XML\", repos = \"http://www.omegahat.net/R\")"'
  ssh zws@$s 'singularity exec instance://sizws R -e "if (! require(biomaRt)) BiocManager::install(\"biomaRt\", update = FALSE, dependencies = TRUE);library(biomaRt);listMarts()"'
  sleep 2
done
