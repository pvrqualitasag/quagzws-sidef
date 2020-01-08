#!/bin/bash
#' ---
#' title: Singularity Pull and Post Installation
#' date:  "2019-10-15"
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' This script pulls a given singularity container image from 
#' singularity hub (shub). Once the image is downloaed, post-installation steps
#' can be run. The post-installation steps consist of 
#'
#' * starting an instance, if it has not yet been started
#' * adapting or creating the file .bash_aliases
#' * adapting or creating the file .Rprofile
#' * creating a link to the singularity image file
#'
#' The prerequisites for this script is to do a `git clone` of the `quagzws-sidef`
#' repository from github into the directory /home/zws/simg. This also clones 
#' this script which then can be run directly from where it was cloned to.
#' 
#' ## Description
#' In a first step, the script checks whether the container image has already been 
#' pulled. That is done by checking whether the indicated image file already 
#' exists. As soon as the container image file is available on the server, 
#' the configuration files can be copied from the template directory to where 
#' they are supposed to be for the container instance.
#' 
#' ## Example
#' The following call does just a pull of a new container image
#' 
#' ```
#' $ SIMGDIR=/home/zws/simg/img
#' $ if [ ! -d "$SIMGDIR" ]; then mkdir -p $SIMGDIR;fi
#' $ cd $SIMGDIR 
#' $ git clone https://github.com/pvrqualitasag/quagzws-sidef.git  
#' $  ./quagzws-sidef/bash/pull_post_simg.sh -i sidev \
#'                                           -n `date +"%Y%m%d"`_quagzws.simg \
#'                                           -s shub://pvrqualitasag/quagzws-sidef \
#'                                           -w $SIMGDIR/ubuntu19084lts \
#'                                           -c -l -t
#' ```
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
#set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails

#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #

#' ### Directories
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #

#' ### Hostname of the server
#+ server-hostname, eval=FALSE
SERVER=`hostname`                          # put hostname of server in variable      #

#' ### Configuration Files and Templates
#+ conf-file-templ, eval=FALSE
SIMGROOT=/home/zws/simg
BASHALIASTMPL=$SIMGROOT/quagzws-sidef/template/bash_aliases
BASHALIASTRG=/home/zws/.bash_aliases
RPROFILETMPL=$SIMGROOT/quagzws-sidef/template/Rprofile
RPROFILETRG=/home/zws/.Rprofile
SSMTPCONFTMPL=$SIMGROOT/quagzws-sidef/template/ssmtp.conf
SSMTPCONFTRG=/home/zws/.ssmtp
RPKGSCRIPT=$SIMGROOT/quagzws-sidef/R/pkg_install_simg.R
IMGDIR=$SIMGROOT/img
SIMGLINK=$SIMGROOT/quagzws.simg


#' ## Functions
#' In this section user-defined functions that are specific for this script are 
#' defined in this section.
#'
#' * title: Show usage message
#' * param: message that is shown
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -b <bind_path> -i <instance_name> -n <image_file_name> -s <shub_uri>"
  $ECHO "  where    -b <bind_path>        --   paths to be bound when starting an instance"
  $ECHO "           -i <instance_name>    --   name of the instance started from the image"
  $ECHO "           -n <image_file_name>  --   name of the image given after pulling it from shub"
  $ECHO "           -s <shub_uri>         --   URI of image on SHUB"
  $ECHO "  additional option parameters are"
  $ECHO "           -c                    --   Switch to copy config from templates"
  $ECHO "           -l                    --   Switch to indicate whether link to simg file should be added"
  $ECHO "           -t                    --   Start the instance from the pulled image"
  $ECHO "           -w <image_dir>        --   Specify alternative directory where image is stored"
  $ECHO ""
  exit 1
}

#' ### Start Message
#' produce a start message
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ### End Message
#' produce an end message
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ### Logging Function
#' functions related to logging
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' ### Starting Instance 
#' function to start an instance from the downloaded image file
#+ start-instance-fun, eval=FALSE
start_instance () {
  log_msg 'start_instance' " * Starting instance $INSTANCENAME ..."
  if [ "$BINDPATH" != "" ]
  then
    log_msg 'start_instance' " ** Added bind paths: $BINDPATH ..."
    singularity instance start --bind $BINDPATH $IMAGENAME $INSTANCENAME
  else
    singularity instance start $IMAGENAME $INSTANCENAME
  fi
  # check whether instance is running
  log_msg 'start_instance' " ** Check whether instance $INSTANCENAME is running ..."
  if [ `singularity instance list | grep $INSTANCENAME | wc -l` == "0" ]
  then
    log_msg 'start_instance' " ==> $INSTANCENAME is not running ==> stop here"
    exit 1
  else
    log_msg 'start_instance' " ==> $INSTANCENAME is running"
  fi
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


#' ### Copy Configuration Files
#' Configuration files for certain applications are copied from template directory
#+ cp-config, eval=FALSE
copy_config () {
  # bash_aliases
  log_msg 'copy_config' " * Copy bash_aliases ..."
  rename_file_on_exist $BASHALIASTRG
  # use '#' as delimiters for sed, because $SIMGLINK contains a path
  cat $BASHALIASTMPL | sed -e "s#{SIMGLINK}#$SIMGLINK#" | sed -e "s#{BINDPATH}#$BINDPATH#" > $BASHALIASTRG

  # Rprofile
  log_msg 'copy_config' " * Copy Rprofile ..."
  rename_file_on_exist $RPROFILETRG
  # use '#' as delimiters for sed, because $RLIBDIR contains a path
  cat $RPROFILETMPL | sed -e "s#{RLIBDIR}#$RLIBDIR#" > $RPROFILETRG
  
  # ssmtp, $SSMTPCONFTRG is a directory
  log_msg 'copy_config' " * Copy ssmtp.conf ..."
  if [ ! -d "$SSMTPCONFTRG" ]
  then
    mkdir -p $SSMTPCONFTRG
  fi
  SSMTPCONFPATH=$SSMTPCONFTRG/`basename $SSMTPCONFTMPL`
  rename_file_on_exist $SSMTPCONFPATH
  cat $SSMTPCONFTMPL | sed -e "s/{hostname}/$SERVER/" > $SSMTPCONFPATH
}


#' ### Link Image File
#' Insert a link from the top image directory to the image file
#+ link-simg-fun
link_simg () {
  # link name cannot be empty here
  if [ "$SIMGLINK" == "" ]
  then
    usage 'copy_config' "ERROR: cannot link image file, because link variable is empty."
  fi
  # if link exists, it is removed
  if [ -e "$SIMGLINK" ]
  then
    log_msg 'link_simg' " * Removed existing link $SIMGLINK ..."
    rm -rf $SIMGLINK
  fi
  log_msg 'link_simg' " * Create link $SIMGLINK to $IMGDIR/$IMAGENAME ..."
  ln -s $IMGDIR/$IMAGENAME $SIMGLINK
}

#' ### Pull Image from SHUB
#' An image file is pulled from the singularity hub.
#+ simg-pull-fun
simg_pull () {
  if [ "$SHUBURI" == "" ]
  then
    log_msg 'simg_pull' " * -s <shub_uri> not specified, hence cannot pull ..."
  else
    log_msg 'simg_pull' " * Pulling img from shub ..."
    singularity pull --name $IMAGENAME $SHUBURI
  fi    
}


#' ## Main Body of Script
#' The main body of the script starts here. This script runs the following tasks
#' 
#' 1. Commandline arguments to specify the input and determine what should be done by the script are parsed.
#' 2. The singularity comtainer image is pull from the singularity hub
#' 3. If specified, a link is created to the image file
#' 4. Configuration files for the container are taken from templates
#' 5. Container instance is started, if specified.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
BINDPATH=""
INSTANCENAME=""
STARTINSTANCE="FALSE"
IMAGENAME=""
RLIBDIR="/home/zws/lib/R/library"
SHUBURI=""
COPYCONFIG="FALSE"
UPDATERPGK="FALSE"
LINKSIMG="FALSE"
while getopts ":b:ci:ln:s:w:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    b)
      BINDPATH=$OPTARG
      ;;
    c)
      COPYCONFIG="TRUE"
      ;;
    i) 
      INSTANCENAME=$OPTARG
      ;;
    l)
      LINKSIMG="TRUE"
      ;;
    n)
      IMAGENAME=$OPTARG
      ;;
    s)
      SHUBURI=$OPTARG
      ;;
    t)
      STARTINSTANCE="TRUE"
      ;;
    w) 
      if [ -d "$OPTARG" ];then
        IMGDIR=$OPTARG
      else
        usage "-w <image_dir> does not seam to be a valid image directory"
      fi
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
if test "$IMAGENAME" == ""; then
  usage "variable image_file_name not defined"
fi
if test "$INSTANCENAME" == ""
then
  usage "variable instance_name not defined"
fi

#' ## Change Working Directory
#' Do everything from where image file is stored
#+ cd-wd, eval=FALSE
cd $IMGDIR


#' ## Image Pull From SHUB
#' Start by pulling the image from SHUB where the repository is specified 
#' by $SHUBURI. The image file will be stored in the file called $IMAGENAME
#' At some point, we had difficulties when $IMAGENAME contained also a path.
#' Most likely it is safer to just give an name of the image file. 
#+ image-pull, eval=FALSE
if [ -f "$IMAGENAME" ]
then
  log_msg $SCRIPT " * Found image: $IMAGENAME ..."
else
  simg_pull
fi


#' ## Link to Image File
#'' insert link to image used in .bash_alias
#+ link-simg
if [ "$LINKSIMG" == "TRUE" ]
then
  log_msg $SCRIPT " * Link to simg ..."
  link_simg
fi
  

#' ## Configuration Files
#' Certain applications in the container need some configuration 
#' files. These files are taken from the template directory of 
#' this repository. 
#+ copy-config, eval=FALSE
if [ "$COPYCONFIG" == "TRUE" ]
then
  log_msg $SCRIPT " * Copy configuration ..."
  copy_config
fi

#' ## Instance Start
#' Start an instance of the pulled image, if instance name specified
#+ instance-start, eval=FALSE
log_msg $SCRIPT " * Instance start ..."
INSTANCERUNNING=`singularity instance list | grep "$INSTANCENAME" | wc -l`
echo "Instance name: $INSTANCENAME"
log_msg $SCRIPT " * Running status of instance: $INSTANCENAME: $INSTANCERUNNING"
if [ "$INSTANCERUNNING" == "0" ] && [ "$STARTINSTANCE" == "TRUE" ]
then
  start_instance
fi


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg


