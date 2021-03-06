#!/bin/bash
# Testing sshpass
#
#
#   Purpose:   Test sshpass
#   Author:    Peter von Rohr <peter.vonrohr@qualitasag.ch>
#
#######################################################################

set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})
PWDFILE=$SCRIPT_DIR/.tmp.pwd

# Continue to put your code here
read -s -p "Password for 1-htz: " password
echo
echo $password > $PWDFILE
sshpass -f $PWDFILE  ssh zws@1-htz.quagzws.com hostname
rm $PWDFILE

