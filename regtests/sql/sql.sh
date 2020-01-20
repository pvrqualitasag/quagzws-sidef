#!/bin/bash
#' ---
#' title: SQL Commandline Client 
#' date:  2020-01-20 16:07:01
#' author: Peter von Rohr
#' ---
#'
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})

# Continue to put your code here
### # run the test statements
sql gestho/gestho@//same.braunvieh.ch:1521/AR01.braunvieh.ch @"$SCRIPT_DIR/test-stmt.sql"
