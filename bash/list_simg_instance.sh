#!/bin/bash
#' ---
#' title: List Singularity Instances
#' date:  2020-01-13 11:40:12
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Get a list of running singularity instances on a given server
#'
#' ## Description
#' For maintenance, it is important to have a list of singularity instances 
#' running on a given server.
#'
#' ## Details
#' The command works either on local servers or on remote hosts. Adding the 
#' option -t shows the top-output of every instance on the server.
#'
#' ## Example
#' ```
#' ./bash/list_simg_instance.sh -s 1-htz.quagzws.com -t
#' ```
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
  $ECHO "Usage: $SCRIPT -d <image_dir> -i <instance_name> -s <remote_server> -t "
  $ECHO "  where -d <image_dir>      --  image directory"
  $ECHO "        -i <instance_name>  --  the name of the singularity instance (sizws by default)"
  $ECHO "        -s <remote_server>  --  specific server to list instances"
  $ECHO "        -t                  --  show topoutput of instance"
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


list_simg_dir () {
  local l_HOST=$1
  log_msg 'list_simg_dir' "List singularity image dir on $l_HOST"
  if [ $l_HOST == $SERVER ]
  then
    ls -la $SIMGDIR
  else
    ssh zws@$l_HOST "ls -la $SIMGDIR"
  fi
}

#' ### Local Singularity Instance Top Output
#' Show top output in local singularity instance
#+ show-top-local-fun
show_top_local () {

  # show top output of a single instance
  singularity exec instance://"$INSTANCENAME" top -n 1 -b

}

#' ### Remote Singularity Instance Top Output
#' Show top output in remote singularity instance
#+ show-top-remote-fun
show_top_remote () {
  local l_HOST=$1
  # show top output of a single instance
  ssh zws@$l_HOST "singularity exec instance://$INSTANCENAME top -n 1 -b"

}

#' ### List Singularity Instances
#' Show a list of singularity instances
list_simg_inst () {
  local l_HOST=$1
  if [ $l_HOST == $SERVER ]
  then
    log_msg 'list_simg_inst' "List of singularity instances on server $l_HOST"
    singularity instance list
    if [ "$SHOWTOP" == "TRUE" ]
    then
      show_top_local
    fi
  else
    log_msg 'list_simg_inst' "List of singularity instances on server $l_HOST"
    ssh -t zws@$l_HOST 'singularity instance list'
    if [ "$SHOWTOP" == "TRUE" ]
    then
      show_top_remote $l_HOST
    fi
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
REMOTESERVERS=(beverin castor niesen speer)
REMOTESERVERNAME=""
SHOWTOP=""
INSTANCENAME="sizws"
SIMGDIR=/home/zws/simg/img/ubuntu1804lts
while getopts ":d:i:s:th" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    d)
      SIMGDIR=$OPTARG
      ;;
    i)
      INSTANCENAME=$OPTARG
      ;;
    s)
      REMOTESERVERNAME=$OPTARG
      ;;
    t)
      SHOWTOP="TRUE"
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


#' ## List Singularity Instances
#' List singularity instances on local or remote servers
#+ list-simg-inst
if [ "$REMOTESERVERNAME" != "" ]
then
  list_simg_dir $REMOTESERVERNAME
  list_simg_inst $REMOTESERVERNAME
else
  for s in ${REMOTESERVERS[@]}
  do
    list_simg_dir $s
    list_simg_inst $s
    sleep 2
  done
fi



#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

