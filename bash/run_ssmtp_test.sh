#!/bin/bash
#' ---
#' title: Run SSMTP Tests
#' date:  2021-03-09 16:54:21
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Seamless tests of sending e-mails
#'
#' ## Description
#' Running regression test script for ssmtp
#'
#' ## Details
#' This uses the bash script under regtest/ssmtp to send a number of e-mails
#'
#' ## Example
#' ./run_ssmtp_test.sh -s dom
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails


#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
MKDIR=/bin/mkdir                           # PATH to mkdir                           #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #

#' ### Directories
#' Installation directory of this script
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#' This section stores the name of this script and the
#' hostname in a variable. Both variables are important for logfiles to be able to
#' trace back which output was produced by which script and on which server.
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -a -i <singularity_instance> -s <server_name> -u <user_name>"
  $ECHO "  where -a                         --  (optional) run tests on all servers ..."
  $ECHO "        -i <singularity_instance>  --  (optional) specify name of singularity instance ..."
  $ECHO "        -s <server_name>           --  (optional) run test on specific server ..."
  $ECHO "        -u <user_name>             --  (optional) remote user name ..."
  $ECHO ""
  exit 1
}

#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ### End Message
#' This function produces a message denoting the end of the script including
#' the time when the script ended. This is important to check whether a script
#' did run successfully to its end.
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ### Log Message
#' Log messages formatted similarly to log4r are produced.
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' ### SSMTP Test On Local Server
#' Run the SSMTP test on a local server, inside or outside of singularity
#+ run-local-ssmtp-test-fun
run_local_ssmtp_test () {
  local l_SRV=$1
  # check whether we run inside of singularity
  if [ $(env | grep SINGULARITY | wc -l) -eq 0 ]
  then
    singularity exec instance://${SIMGNAME} /home/zws/simg/quagzws-sidef/regtests/ssmtp/test_ssmtp.sh
  else
    /home/zws/simg/quagzws-sidef/regtests/ssmtp/test_ssmtp.sh
  fi
}

#' ### SSMTP Test From Remote
#' Run SSMTP test on remote server
#+ run-remote-ssmtp-test-fun
run_remote_ssmtp_test () {
  local l_SRV=$1
  ssh ${REMOTEUSER}@${l_SRV} singularity exec instance://${SIMGNAME} /home/zws/simg/quagzws-sidef/regtests/ssmtp/test_ssmtp.sh
}

#' ### Run SSMTP Test
#' Run the test on a given server
#+ run-ssmtp-test-fun
run_ssmtp_test () {
  local l_SRV=$1
  # if the test is run from current server, run local version
  if [ "$SERVER" == "$l_SRV" ]
  then
    run_local_ssmtp_test $l_SRV
  else
    run_remote_ssmtp_test $l_SRV
  fi
}


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
SERVERS=(beverin castor dom niesen speer)
REMOTEUSER=zws
SERVERNAME=''
SIMGNAME='sizws'
ALLSERVERS='false'
while getopts ":ai:s:u:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    a)
      ALLSERVERS='TRUE'
      ;;
    i)
      SIMGNAME=$OPTARG
      ;;
    s)
      SERVERNAME=$OPTARG
      ;;
    u)
      REMOTEUSER=$OPTARG
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



#' ## Your Code
#' Continue to put your code here
#+ your-code-here
if [ "$SERVERNAME" != "" ]
then
  run_ssmtp_test $SERVERNAME
else
  if [ "$ALLSERVERS" == 'TRUE' ]
  then
    for s in ${SERVERS[@]}
    do
      run_ssmtp_test $s
      sleep 2
    done
  else
    log_msg "$SCRIPT" ' * No server name is given and option -a was not specified, hence do nothing ...'
  fi  
fi


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

