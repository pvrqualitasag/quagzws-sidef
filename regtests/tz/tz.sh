#!/bin/bash
# Timezone Setting
#
#
#   Purpose:   Test Timezone Setting
#   Author:    Peter von Rohr <peter.vonrohr@qualitasag.ch>
#
#######################################################################

set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})

# Continue to put your code here
# use date command
date +"%Z"
# check content of TZ
echo $TZ
# get content of /etc/timezone
cat /etc/timezone

