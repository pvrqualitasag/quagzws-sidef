#!/bin/bash
#' ---
#' title: Update .Rprofile Configuration File
#' date:  2020-02-04 09:56:06
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Allow for a seamless update of the .Rprofile configuration file on a set of different remote machines.
#'
#' ## Description
#' Update the .Rprofile file on a remote server. 
#'
#' ## Details
#' When starting up R the statements in .Rprofile are executed. This allows for a configuration of the R-system.
#'
#' ## Example
#' ./update_rprofile -m 1-htz.quagzws.com -u zws
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
SERVER=`hostname -f`                          # put hostname of server in variable      #


#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -m <host_machine>  -u <remote_user> -q <quag_zws_dir> -r <r_lib_dir> -s <rprofile_tmpl_source> -t <rprofile_target> -f -b <branch>"
  $ECHO "  where -m <host_machine>         --  remote host machine where image is updated"
  $ECHO "        -u <remote_user>          --  remote user on host machine"
  $ECHO "        -q <quag_zws_dir>         --  quagzws source dir"
  $ECHO "        -r <r_lib_dir>            --  r library directory"
  $ECHO "        -s <rprofile_tmpl_source> --  template file for .Rprofile"
  $ECHO "        -t <rprofile_target>      --  target path to .Rprofile"
  $ECHO "        -f <force_update>         --  force update, even if .Rprofile exists"
  $ECHO "        -b <branch>               --  branch reference"
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


#' ### Updating the .Rprofile
#' Based on the template file, the R-library path is inserted and the 
#' .Rprofile is stored in the indicated target path.
#+ update-rprofile-fun
update_rprofile () {
  local l_HOST=$1
  # in case, we run this from l_HOST, the update can be done locally, 
  # otherwise, we have to run it over ssh.
  if [ "$l_HOST" == "$SERVER" ]
  then
    if [ ! -f "$RPROFILETRG" ] || [ "$FORCEUPDATE" == 'true' ]
    then
      if [ "$BRANCHREF" == '' ]
      then
        git -C $QUAGZWSDIR pull
      else
        git -C $QUAGZWSDIR pull origin $BRANCHREF
      fi
      # Rprofile
      log_msg 'copy_config' " * Copy Rprofile ..."
      rename_file_on_exist $RPROFILETRG
      # use '#' as delimiters for sed, because $RLIBDIR contains a path
      cat $RPROFILETMPL | sed -e "s#{RLIBDIR}#$RLIBDIR#" > $RPROFILETRG
    else
     log_msg 'copy_config' " * FOUND $RPROFILETRG ... use -f for forcing an update ..."
    fi
  else
    if [ "$BRANCHREF" == '' ]
    then
      ssh ${REMOTEUSER}@$l_HOST "$QUAGZWSDIR/bash/update_rprofile.sh -m $l_HOST -u $REMOTEUSER -f $FORCEUPDATE"
    else
      ssh ${REMOTEUSER}@$l_HOST "$QUAGZWSDIR/bash/update_rprofile.sh -m $l_HOST -u $REMOTEUSER -f $FORCEUPDATE -b $BRANCHREF"
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
REMOTEUSER=zws
HOSTSERVER=""
QUAGZWSDIR=/home/${REMOTEUSER}/simg/quagzws-sidef
RLIBDIR="/home/${REMOTEUSER}/lib/R/library"
RPROFILETMPL=$QUAGZWSDIR/template/Rprofile
RPROFILETRG=/home/${REMOTEUSER}/.Rprofile
FORCEUPDATE=''
BRANCHREF=''
while getopts ":b:f:m:u:q:r:s:t:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    b)
      BRANCHREF=$OPTARG
      ;;
    f)
      FORCEUPDATE=$OPTARG
      ;;
    m)
      HOSTSERVER=$OPTARG
      ;;
    u)
      REMOTEUSER=$OPTARG
      ;;
    q)
      QUAGZWSDIR=$OPTARG
      ;;
    r)
      RLIBDIR=$OPTARG
      ;;
    s)
      RPROFILETMPL=$OPTARG
      ;;
    t)
      RPROFILETRG=$OPTARG
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



#' ## Update .Rprofile
#' Depending on whether the name of a specific server was given with -m or 
#' not, the .Rprofile is updated on the one given server or on all servers.
#+ rprofile-update
if [ "$HOSTSERVER" == "" ]
then
  for s in ${REMOTESERVERS[@]}
  do
    update_rprofile $s
    sleep 2
  done  
else
  update_rprofile $HOSTSERVER
fi



#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

