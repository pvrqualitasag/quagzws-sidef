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
# set -o errexit    # exit immediately, if single command exits with non-zero status
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
G2F90OUTFILES=(fort.99 gibbs_samples last_solutions)
G2F90BINSOL=binary_final_solutions


#' ## Preparation
#' The current working directory is stored away to be able to go back at the end.
#+ save-cwd
cur_wd=`pwd`
cd $SCRIPT_DIR


#' ## Test
#' Run the gibbs2f90 program
#+ run-g2f
(echo $G2F90PAR;echo '5000 1000';echo 10) | $G2F90PATH/$G2F90PROG


#' ## Comparison
#' Compare output of current test with stored output
for f in ${G2F90OUTFILES[@]}
#ls -1 *.out | while read f
do
  echo " * Comparing result file $f ..."
  if [ `diff $f.out $f | wc -l` == "0" ]
  then
    echo " ... ok -- clean-up"
    rm -rf $f
  else
    diff $f.out $f > $f.diff
  fi
  sleep 2
done


#' ## Clean Up
#' Remove binary solution file
#+ rm-bin-sol
rm $G2F90BINSOL

#' Go back to original wd
#+ cd-back
cd $cur_wd

