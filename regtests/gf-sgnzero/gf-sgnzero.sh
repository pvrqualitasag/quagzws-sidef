#!/bin/bash
#' ---
#' title: GFortran No Sign Zero
#' date:  2020-01-20 13:04:58
#' author: Peter von Rohr
#' ---
#'
#' ## Purpose
#' We want to make sure that the option to suppress signs in front of a zero. 
#'
#' ## Description
#' By default the gfortran compiler makes a difference between positive and negative zeros. We need an option to suppress the signs in front of a zero. This is given by -fno-sign-zero.
#'
#' ## Details
#' We use a small f90 test program that outputs a zero without sign.
#'
#' ## Example
#' ./gf-sgnzero/gf-sgnzero.sh
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
#' Define a few variables
#+ prep-step
F90PROG=sgnzero.f90
F90OUT=a.out

#' ## Main Part
#' Compile the program and run the executable
#+ main-part
gfortran -fno-sign-zero $F90PROG
./$F90OUT

#' ## Clean Up
#' Any cleaning up after the test is done here.
#+ clean-up
rm $F90OUT
