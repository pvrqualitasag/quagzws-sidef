#!/bin/bash
#' ---
#' title: R Qualitas Packages
#' date:  2020-01-20 16:07:01
#' author: Peter von Rohr
#' ---
#'
#' ## Purpose
#' When setting up a new container image, it is useful to test the installation of our own R-packages. 
#'
#' ## Description
#' Running different R-scripts as regression tests. These scripts mainly use the own-developed packages.
#'
#' ## Details
#' Several features of the own-developed R-packages are tested using regression tests to check whether they work in a certain container environment.
#'
#' ## Example
#' ./R/R.sh
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
#+ env-set
# set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

#' ## Global Constants
#' In this section, global constants for the test are defined
#+ global-const-def
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})
CUR_WD=`pwd`

#' ## Preparation
#' Preparatory steps, if any, are added here ...
#+ prep-step
PREVDIR=./prevgel
CURDIR=./curgel
TEMPLATE=./templates/compare_plots.Rmd.template
GEPLOTREPORT=ge_plot_report
GEPLOTREPORTRMD=$GEPLOTREPORT.Rmd
GEPLOTREPORTLOG=$GEPLOTREPORT.log
GEPLOTREPORTPDF=$GEPLOTREPORT.pdf

#' ## Main Part
#' Main part of the scripts comes here ...
#+ main-part
cd $SCRIPT_DIR
R -e "qgert::create_ge_plot_report(ps_gedir='$CURDIR', \
ps_archdir='$PREVDIR', \
ps_trgdir='prev_comp', \
ps_templ='$TEMPLATE', \
ps_report_text = '## Comparison Of Plots\nPlots compare estimates ...', \
ps_rmd_report  = '$GEPLOTREPORTRMD', \
pb_keep_src    = TRUE)" &> $GEPLOTREPORTLOG

#' ## Comparison
#' Compare original report with generated version.
#+ comp-rep
NRLINESDIFF=$(diff $GEPLOTREPORTRMD $CURDIR/$GEPLOTREPORTRMD | wc -l)
echo "Number of differences in comparison plot report: $NRLINESDIFF"

#' ## Clean Up
#' Any cleaning up after the test is done here.
#+ clean-up
if [ "$NRLINESDIFF" == "0" ]
then
  rm -rf $GEPLOTREPORTRMD $GEPLOTREPORTLOG $GEPLOTREPORTPDF
fi

cd $CUR_WD