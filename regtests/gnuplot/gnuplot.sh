#!/bin/bash
# gnuplot 
#
#
#   Purpose:   Regression test for gnuplot 
#   Author:    Peter von Rohr (<peter.vonrohr@qualitasag.ch>) 
#
#######################################################################

#set -o errexit    # exit immediatIely, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
#set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})
WORKDIR=${SCRIPT_DIR}/demo

# Change to work dir and run all demo script
cd $WORKDIR
cat demo-all.gp | gnuplot &> demo-all.log

# Chnage to script dir and do the diff
cd $SCRIPT_DIR
echo -n "Test - gnuplot: "
if [ `diff gnuplot.out $WORKDIR/demo-all.log | wc -l` == "0" ]
then
	echo "ok"
	rm -rf $WORKDIR/demo-all.log $WORKDIR/all_demos.ps

else
	echo "not ok"
        diff gnuplot.out $WORKDIR/demo-all.log
fi
