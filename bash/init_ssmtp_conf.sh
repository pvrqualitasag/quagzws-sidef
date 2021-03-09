#!/bin/bash
#' ---
#' title: Initialise ssmtp Configuration
#' date:  2020-08-24 13:36:02
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Seamless initialisation of ssmtp. 
#'
#' ## Description
#' Initialise the configuration for ssmtp.
#'
#' ## Details
#' This can also be done with pull_post_simg.sh. 
#'
#' ## Example
#' ./init_ssmtp_conf.sh -s <source_template> -t <target_path> 
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
  $ECHO "Usage: $SCRIPT -a <a_example> -b <b_example> -c"
  $ECHO "  where -a <a_example> ..."
  $ECHO "        -b <b_example> (optional) ..."
  $ECHO "        -c (optional) ..."
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

#' ### Helper File Rename
#' If the file exists the existing file is renamed
#+ rename-file-on-exist-fun
rename_file_on_exist () {
  local l_fpath=$1
  # if $l_fpath exists, it is renamed
  if [ -f "$l_fpath" ]
  then
    log_msg 'rename_file_on_exist' " * Rename existing file: $l_fpath"
    mv $l_fpath $l_fpath.`date +"%Y%m%d%H%M%S"`
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
SIMGROOT=/home/zws/simg
SSMTPCONFTMPL=$SIMGROOT/quagzws-sidef/template/ssmtp.conf
SSMTPCONFTRG=/home/zws/.ssmtp
while getopts ":s:t:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    s)
      SSMTPCONFTMPL=$OPTARG
      ;;
    t)
      SSMTPCONFTRG=$OPTARG
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


#' ## Copy Template To Config Path
#' Template is taken and copied to conf
#+ ssmtp, $SSMTPCONFTRG is a directory
log_msg 'copy_config' " * Copy ssmtp.conf ..."
if [ ! -d "$SSMTPCONFTRG" ]
then
  mkdir -p $SSMTPCONFTRG
fi
SSMTPCONFPATH=$SSMTPCONFTRG/`basename $SSMTPCONFTMPL`
rename_file_on_exist $SSMTPCONFPATH
cat $SSMTPCONFTMPL | sed -e "s/{hostname}/$SERVER/" > $SSMTPCONFPATH
  

#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

