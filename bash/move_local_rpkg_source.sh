#!/bin/bash
#' ---
#' title: Move Local R-Packages
#' date:  2020-07-01 15:59:10
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Local R-packages should be deployed via copying the sources to remote servers.
#'
#' ## Description
#' Local R-packages built from sources that are available from local sources are deployed by moving the sources to remote servers.
#'
#' ## Details
#' The deployment is done by copying the sources via scp.
#'
#' ## Example
#' ./move_local_rpkg_source.sh -l <local_rpkg> 
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

#' ### Defaults
#' Default values for variables
#+ default-values
SIMGROOT=/home/zws/simg
LOCALPKGDEFAULT=$SIMGROOT/quagzws-sidef/inst/extdata/input/local_pkg.txt



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -l <local_rpkg_input> -s <remote_server> -u <remote_user>"
  $ECHO "  where -l <local_rpkg_input>  --  input file with paths to local R-packages"
  $ECHO "        -s <remote_server>     --  remote server"
  $ECHO "        -u <remote_user>       --  user on remote server"
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


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
LOCALPKG=""
REMOTESERVER=""
REMOTEUSER="zws"
while getopts ":l:s:u:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    l)
      LOCALPKG=$OPTARG
      ;;
    s)
      REMOTESERVER=$OPTARG
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

#' ## Checks for Command Line Arguments
#' The following statements are used to check whether required arguments
#' have been assigned with a non-empty value
#+ argument-test, eval=FALSE
if test "$REMOTESERVER" == ""; then
  usage "-s <remote_server> not defined"
fi
if test "$REMOTEUSER" == ""; then
  usage "-u <remote_user> not defined"
fi

#' ## Default Replacements
#' Check whether default values must be used
#+ default-replacements
if [ "$LOCALPKG" == "" ]
then
  LOCALPKG=$LOCALPKGDEFAULT
fi



#' ## Move Local R-pkg Source 
#' In a loop over the entries in local_rpkg, copy the directories
#+ move-local-rpkg
cat $LOCALPKG | while read line
do
  REPODIR=$(dirname $line)
  log_msg "$SCRIPT" " * Moving repository sources from: $line to ${REMOTEUSER}@${REMOTESERVER}:${REPODIR} ..."
  scp -r $line ${REMOTEUSER}@${REMOTESERVER}:${REPODIR}
done




#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

