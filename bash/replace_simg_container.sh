#!/bin/bash
#' ---
#' title: Replace Instance of Singularity Container
#' date:  2020-01-13 08:55:26
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Replace a running instance of a container with an instance started from a 
#' different image. The replacement is done whenever a container image is 
#' updated. The script can either be run on a local or on a remote server  
#' indicated by the option -s <remote_server>. When -s is missing a list of 
#' pre-defined servers is used.
#'
#' ## Description
#' The image running with the name given by -i <image_name> is stopped on the 
#' specified server. In case there exists a link given by -l <link_name>, 
#' then it is first deleted and then re-created to point to the new image file 
#' specified via -n <image_path>. In the last step an instance of running 
#' the new image is started.
#'
#' ## Example
#' ```
#' ./bash/replace_simg_container.sh -i sizws \
#'                                  -l /home/zws/simg/quagzws.simg \
#'                                  -n /home/zws/simg/img/ubuntu1804lts/20200113084254_quagzws.simg \
#'                                  -s 1-htz.quagzws.com
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
  $ECHO "Usage: $SCRIPT -b <bind_path> -i <instance_name> -l <link_path> -n <image_path> -s <remote_server_name>"
  $ECHO "  where -b <bind_path>           --  bind-path for new instance (optional)"
  $ECHO "        -i <instance_name>       --  name of the instance to be replaced"
  $ECHO "        -l <link_path>           --  name of the link to the singularity image"
  $ECHO "        -n <image_path>          --  path to the new image file"
  $ECHO "        -s <remote_server_name>  --  name of remote server where instance runs"
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

#' ### Local Instance replacement
#' Instance replacement on local server
#+ replace-instance-local-fun
replace_instance_local () {
  # stop the running instance
  singularity instance stop $INSTANCENAME
  # if specified, remove old link
  if [ "$LINKPATH" != "" ]
  then
    if [ -e "$LINKPATH" ];then rm $LINKPATH;fi
    ln -s $IMAGEPATH $LINKPATH
  fi
  # start new image
  singularity instance start --bind $BINDPATH $IMAGEPATH $INSTANCENAME
}

#' ### Remote Instance replacement
#' Instance replacement on remote server
#+ replace-instance-remote-fun
replace_instance_remote () {
  local l_HOST=$1
  ssh -t zws@$l_HOST "singularity instance stop $INSTANCENAME;
if [ $LINKPATH != '' ];then if [ -e $LINKPATH ];then rm $LINKPATH;fi;
ln -s $IMAGEPATH $LINKPATH;fi;
singularity instance start --bind $BINDPATH $IMAGEPATH $INSTANCENAME"
}

#' ### Generic Instance replacement
#' The function below replaces a running instance with a new one.
#+ replace-instance-fun
replace_instance () {
  local l_HOST=$1
  if [ "$l_HOST" == "$SERVER" ]
  then
    replace_instance_local
  else
    replace_instance_remote $l_HOST
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
BINDPATH="/qualstore03,/qualstorzws01,/qualstorora01,/qualstororatest01"
INSTANCENAME=""
LINKPATH="/home/zws/simg/quagzws.simg"
IMAGEPATH=""
REMOTESERVERNAME=""
REMOTESERVERS=(beverin castor niesen speer)
while getopts ":b:i:l:n:s:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    b)
      BINDPATH=$OPTARG
      ;;
    i)
      INSTANCENAME=$OPTARG
      ;;
    l)
      LINKPATH=$OPTARG
      ;;
    n)
      IMAGEPATH=$OPTARG
      ;;
    s)
      REMOTESERVERNAME=$OPTARG
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
if test "$INSTANCENAME" == ""; then
  usage "-i <instance_name> not defined"
fi
if [ "$IMAGEPATH" == "" ]
then
  usage "-n <image_path> not defined"
fi


#' ## Instance Replacement
#' Replace instance on either one given server or a list of servers
#+ instance-replace
if [ "$REMOTESERVERNAME" == "" ]
then
  for s in ${REMOTESERVERS[@]}
  do
    replace_instance $s
    sleep 2
  done
else
  replace_instance $REMOTESERVERNAME
fi



#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

