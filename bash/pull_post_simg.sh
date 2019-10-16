#!/bin/bash
#' ---
#' title: Singularity Pull and Post Installation
#' date:  "2019-10-15"
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' This script can be used to pull a given singularity container image from 
#' singularity hub (shub) and to run all post-installation steps. The post-installation 
#' steps consist of 
#'
#' * starting an instance, if it has not yet been started
#' * installing a number of R-packages, if they have not yet been installed
#' * adapting or creating the file .bash_aliases
#' * adapting or creating the file .Rprofile
#'
#' The prerequisites for this script to run is to do a git clone of the `quagzws-sidef`
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
BASHALIASTMPL=/home/zws/simg/quagzws-sidef/template/bash_aliases
BASHALIASTRG=/home/zws/.bash_aliases
RPROFILETMPL=/home/zws/simg/quagzws-sidef/template/Rprofile
RPROFILETRG=/home/zws/.Rprofile
SSMTPCONFTMPL=/home/zws/simg/quagzws-sidef/template/ssmtp.conf
SSMTPCONFTRG=/home/zws/.ssmtp
RPKGSCRIPT=/home/zws/simg/quagzws-sidef/R/pkg_install_simg.R


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
  $ECHO "Usage: $SCRIPT -b <bind_path> -i <instance_name> -n <image_name> -s <shub_uri>"
  $ECHO "  where    <bind_path>       --   paths to be bound when starting an instance"
  $ECHO "           <instance_name>   --   name of the instance started from the image"
  $ECHO "           <image_name>      --   name of the image given after pulling it from shub"
  $ECHO "           <shub_uri>        --   URI of image on SHUB"
  $ECHO ""
  exit 1
}

#' produce a start message
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' produce an end message
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' functions related to logging
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' function to start an instance
#+ start-instance-fun, eval=FALSE
start_instance () {
  log_msg start_instance " * Starting instance $INSTANCENAME ..."
  if [ "$BINDPATH" != "" ]
  then
    log_msg start_instance " ** Added bind paths: $BINDPATH ..."
    singularity instance start --bind $BINDPATH $IMAGENAME $INSTANCENAME
  else
    singularity instance start $IMAGENAME $INSTANCENAME
  fi
  # check whether instance is running
  log_msg start_instance " ** Check whether instance $INSTANCENAME is running ..."
  if [ `singularity instance list | grep $INSTANCENAME | wc -l` == "0" ]
  then
    log_msg start_instance " ==> $INSTANCENAME is not running ==> stop here"
    exit 1
  else
    log_msg start_instance " ==> $INSTANCENAME is running"
  fi
}

#' ### R-Package Installation
#' R-Packages from a given list are installed on an as-needed basis.
#+ install-rpkg-fun, eval=FALSE
install_rpkg () {
  # check whether RLIBDIR is an existing directory, if not create it
  if [ !-d "$RLIBDIR" ]
  then
    mkdir -p 
    log_msg install_rpkg " ** Created directory $RLIBDIR ..."
  fi
  # install packages
  log_msg install_rpkg " ** Install R packages to $RLIBDIR ..."
  singularity exec instance://$INSTANCENAME R -e "source $RPKGSCRIPT" --no-save
}


#' ### Helper File Rename
#' If the file exists the existing file is renamed
rename_file_on_exist () {
  local l_fpath=$1
  # if $l_fpath exists, it is renamed
  if [ -f "$l_fpath" ]
  then
    log_msg 'rename_file_on_exist' " * Rename existing file: $l_fpath"
    mv $l_fpath $l_fpath.`date +"%Y%m%d%H%M%S"`
  fi
}


#' ### Helper File Copy 
#' The source file is copied from source to target, if the 
#' the file already exists at the target, the original is 
#' kept and the new file is prepended with the current data-time
#'
#' * param: l_src local source file
#' * param: l_trg local target
#+ cp-file-keep-on-exist, eval=FALSE
copy_file_keep_on_exist () {
  local l_src=$1
  local l_trg=$2
  # if target is a directory do ordinary copying
  if [ -d "$l_trg" ]
  then
    cp $l_src $l_trg
  else
    # check whether target file already exists, then rename
    rename_file_on_exist $l_trg
    # copy the source to the target
    cp $l_src $l_trg
  fi
}


#' ### Copy Configuration Files
#' Configuration files for certain applications are copied from template directory
#+ cp-config, eval=FALSE
copy_config () {
  # bash_aliases
  log_msg 'copy_config' " * Copy bash_aliases ..."
  copy_file_keep_on_exist $BASHALIASTMPL $BASHALIASTRG
  
  # Rprofile
  log_msg 'copy_config' " * Copy Rprofile ..."
  rename_file_on_exist $RPROFILETRG
  cat $RPROFILETMPL | sed -e "s/{RLIBDIR}/$RLIBDIR/" > $RPROFILETRG
  
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

#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
BINDPATH=""
INSTANCENAME=""
IMAGENAME=""
RLIBDIR="/home/zws/lib/R/library"
SHUBURI=""
while getopts ":b:i:n:r:s:h" FLAG; do
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
    n)
      IMAGENAME=$OPTARG
      ;;
    r)
      RLIBDIR=$OPTARG
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
if test "$IMAGENAME" == ""; then
  usage "variable image_name not defined"
fi
if test "$SHUBURI" == ""; then
  usage "variable shub_uri not defined"
fi
if test "$INSTANCENAME" == ""
then
  usage "variable instance_name not defined"
fi


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
  log_msg $SCRIPT " * Pulling img from shub ..."
  singularity pull --name $IMAGENAME $SHUBURI
fi


#' ## Configuration Files
#' Certain applications in the container need some configuration 
#' files. These files are taken from the template directory of 
#' this repository. 
copy_config

#' ## Instance Start
#' Start an instance of the pulled image, if instance name specified
#+ instance-start, eval=FALSE
INSTANCERUNNING=$(singularity instance list | grep "$INSTANCENAME" | wc -l)
log_msg $SCRIPT " * Running status of instance: $INSTANCENAME: $INSTANCERUNNING"
if [ "$INSTANCERUNNING" == "0" ] 
then
  start_instance
fi


#' ## Install R-packages
#' if specified install R-packages
#+ install-rpack, eval=FALSE
if [ "$RLIBDIR" != "" ]
then
  install_rpkg
fi


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg


