#!/bin/bash
#' ---
#' title: Regression Test For gibbs2f90
#' date:  2019-12-10
#' author: Peter von Rohr
#' ---
#'
#' ## Purpose
#'
#' ## Description
#'
#'
#+ env-set
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

#' ## Global Constants
#' In this section, global constants for the test are defined
#+ global-const-def
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})
G2F90PATH=/qualstorzws01/data_projekte/projekte/gibbs
G2F90PROG=gibbs2f90
G2F90PAR=gibbs1.txt

#' ## Preparation
#' The current working directory is stored away to be able to go back at the end.
#+ save-cwd
cur_wd=`pwd`
cd $SCRIPT_DIR
# Run the gibbs2f90 program
(echo $G2F90PAR;echo '5000 1000';echo 10) | $G2F90PATH/$G2F90PROG


#' ## Clean Up
#' Go back to original wd
#+ cd-back
cd $cur_wd

