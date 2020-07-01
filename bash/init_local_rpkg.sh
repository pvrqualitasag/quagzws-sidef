#!/bin/bash
#' ---
#' title: Init Local R-Package Directory Structure
#' date:  2020-07-01 15:30:06
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Make a deployment of local R-packages as seamless as possible.
#'
#' ## Description
#' Some R-packages exist only as source code in a given directory. From these directories the packages are installed. To be able to move the source code from a given source onto a new server this script is used to create the empty directory structure. 
#'
#' ## Details
#' The information where the source code will be stored is taken from the input file local_pkg.txt.
#'
#' ## Example
#' ./init_local_rpkg.sh -l <local_rpkg_input>
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
SERVER=`hostname --fqdn`                   # put hostname of server in variable      #


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
  $ECHO "Usage: $SCRIPT -l <local_rpkg_input>"
  $ECHO "  where -l <local_rpkg_input>  --  input file with paths to local R-packages"
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

#' ### Directory Existence
#' check whether the specified directory exists, if not create it
#+ check-exist-dir-create-fun
check_exist_dir_create () {
  local l_check_dir=$1
  if [ ! -d "$l_check_dir" ]
  then
    log_msg check_exist_dir_create "CANNOT find directory: $l_check_dir ==> create it"
    mkdir -p $l_check_dir    
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
LOCALPKG=""
while getopts ":l:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    l)
      LOCALPKG=$OPTARG
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

#' ## Use Defaults
#' If local_pkg was not specified, take the default value
#+ argument-default, eval=FALSE
if [ "$LOCALPKG" == "" ]
then
  LOCALPKG=$LOCALPKGDEFAULT
fi


#' ## Create Directory Structure
#' In a loop over all entries of local_pkg create directories
#+ create dir
cat $LOCALPKG | while read line
do
  REPODIR=$(dirname $line)
  log_msg "$SCRIPT" " * Checking repository dirctory: $REPODIR ..."
  check_exist_dir_create $REPODIR
done



#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

