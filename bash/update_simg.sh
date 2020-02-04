#!/bin/bash
#' ---
#' title: Update Singularity Image Files
#' date:  2020-01-09 16:05:28
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Update singularity image files on remote servers by a `singularity pull` from 
#' the singularity hub.
#'
#' ## Description
#' Singularity images must be updated from time to time. To do this on multiple 
#' servers automatically, this script runs the script `pull_post_simg.sh` on 
#' the specified servers.
#'
#' ## Details
#' The only command-line option is the image_path specified after -n. When running 
#' the script w/out -m, then it is run on all the servers from a list specified in 
#' the script. Hence use the example below for testing. 
#'
#' ## Example
#' The following example runs the default pull-script and saves the image file under 
#' the path given after -n for the server 1-htz.quagzws.com.
#'
#' ```
#' ./quagzws-sidef/bash/update_simg.sh -n /home/zws/simg/img/ubuntu1804lts/`date +"%Y%m%d"`_quagzws.simg \
#'                                     -m 1-htz.quagzws.com
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
  $ECHO "Usage: $SCRIPT -n <image_path> -m <host_machine> -p <quagzws-pull-script> -q <quagzws-dir> -s <shub_uri> "
  $ECHO "  where -n <image_path>           --  path to image file where it should be saved"
  $ECHO "        -m <host_machine>         --  remote host machine where image is updated"
  $ECHO "        -p <quagzws-pull-script>  --  pull script for image file"
  $ECHO "        -q <quagzws-dir>          --  directory where this repository is locally"
  $ECHO "        -s <shub_uri>             --  URI on shub from where image is pulled"
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

#' ### Update Singularity Image
#' This function runs the updated on a given server
#+ update-simg-fun
update_simg () {
  local l_HOST=$1
  # in case, we run this from l_HOST, the script pull_post_simg.sh can just be executed 
  # otherwise, we have to run it over ssh.
  if [ "$l_HOST" == "$SERVER" ]
  then
    git -C $QUAGZWSDIR pull
    $PULLSCRIPT -n $IMAGEPATH -s $SHUBURI
  else
    ssh zws@$l_HOST "git -C $QUAGZWSDIR pull;$PULLSCRIPT -n $IMAGEPATH -s $SHUBURI"
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
HOSTSERVER=""
IMAGEPATH=""
SHUBURI="shub://pvrqualitasag/quagzws-sidef"
QUAGZWSDIR=/home/zws/simg/quagzws-sidef
PULLSCRIPT=$QUAGZWSDIR/bash/pull_post_simg.sh
while getopts ":n:m:q:s:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    n)
      IMAGEPATH=$OPTARG
      ;;
    m)
      HOSTSERVER=$OPTARG
      ;;
    p)
      PULLSCRIPT=$OPTARG
      ;;
    q)
      QUAGZWSDIR=$OPTARG
      ;;
    s)
      SHUBURI=$OPTARG
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
if test "$IMAGEPATH" == ""; then
  usage "-n <image_file_path> variable not defined"
fi
if test "$SHUBURI" == ""; then
  usage "-s <shub_uri> variable not defined"
fi



#' ## Image Updates
#' Depending on whether the name of a specific server was given with -m or 
#' not, the image file is updated on the one given server or on all servers.
#+ img-update
if [ "$HOSTSERVER" == "" ]
then
  for s in ${REMOTESERVERS[@]}
  do
    update_simg $s
    sleep 2
  done  
else
  update_simg $HOSTSERVER
fi



#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

