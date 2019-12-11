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

#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -n <run_compare>"
  $ECHO "  where -n <run_compare>  --  indicates whether to run comparisons to existing results"
  $ECHO ""
  exit 1
}


#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
RUNCOMPARE="TRUE"
while getopts ":n:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    n)
      RUNCOMPARE=$OPTARG
      ;;
    :)
      usage "-$OPTARG requires an argument"
      ;;
    ?)
      usage "Invalid command line argument (-$OPTARG) found"
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.


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
if [ "$RUNCOMPARE" == "TRUE" ]
then
  for f in ${G2F90OUTFILES[@]}
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
fi

#' ## Clean Up
#' Remove binary solution file
#+ rm-bin-sol
rm $G2F90BINSOL

#' Go back to original wd
#+ cd-back
cd $cur_wd

