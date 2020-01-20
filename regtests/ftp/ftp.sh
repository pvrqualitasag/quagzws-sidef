#!/bin/bash
#' ---
#' title: Ftp Client
#' date:  2020-01-20 10:59:49
#' author: Peter von Rohr
#' ---
#'
#' ## Purpose
#' Make sure that ftp client works. 
#'
#' ## Description
#' Regression test for ftp client in a container.
#'
#' ## Details
#' This tests the functionality of the ftp client with a few examples. 
#'
#' ## Example
#' ./ftp/ftp.sh 
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
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

#' ## Preparation
#' Define variables and put the current date to the file
#+ prep-step
HOST='ftp.elvadata.ch'
USER='qualitas'
PASSWD='DPiv35$!'
FILE='file.txt'
date > $FILE
cp $FILE ${FILE}.org

#' ## Main Part
#' Main part of the scripts comes here ...
#+ main-part

ftp -n $HOST > ftp.worked.tmp 2> ftp.failed.tmp <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
put $FILE
dir
get $FILE
dir
del $FILE
dir
quit
END_SCRIPT

#' ## Test Statements
#' The following statements generate the output for the tests.
#+ run-test
NRLINEWORKED=$(cat ftp.worked.tmp | grep "$FILE" | wc -l)
echo "Number of lines containing filename in worked ouput: $NRLINEWORKED"
NRLINEFAILED=$(cat ftp.failed.tmp | wc -l)
echo "Number of lines in failed ouput: $NRLINEFAILED"
NRLINEDIFFUPDOWN=$(diff "$FILE" "${FILE}.org" | wc -l)
echo "Number of differences between up- and download: $NRLINEDIFFUPDOWN"

#' ## Clean Up
#' The file uploaded and downloaded and the worked and failed ftp-output are
#' deleted.
#+ clean-up
rm -rf $FILE ${FILE}.org ftp.worked.tmp ftp.failed.tmp 

