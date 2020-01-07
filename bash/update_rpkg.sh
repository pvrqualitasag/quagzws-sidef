#!/bin/bash
#' ---
#' title: Update R-packages in Container
#' date:  2020-01-07 08:58:28
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' This script is the result of re-factoring out the part related to installation 
#' and updating of R-packages in a container. The updating process should run 
#' as seamless as possible over a collection of servers. 
#'
#' ## Description
#' Three types of packages are distinguished: (1) cran-packages, (2) github packages
#' and (3) local packages. For each class of packages, an input file with a list 
#' of packages of the respective class can be specified. For each of the specified 
#' packages, it is checked whether the package is already installed. If not, the 
#' package is installed from the respective source. 
#'
#' ## Bash Settings
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


SIMGROOT=/home/zws/simg
RPKGSCRIPTDEFAULT=$SIMGROOT/quagzws-sidef/R/pkg_install_simg.R
CRANPKGDEFAULT=$SIMGROOT/quagzws-sidef/inst/extdata/input/cran_pkg.txt
GHUBPKGDEFAULT=$SIMGROOT/quagzws-sidef/inst/extdata/input/ghub_pkg.txt
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
  $ECHO "Usage: $SCRIPT -c <cran_pkg_input> -g <github_pkg_input> -i <instance_name> -l <local_pkg_input> -p <pkg_install_script> -r <r_lib_dir> -s <remote_server>"
  $ECHO "  where -c <cran_pkg_input>      --  names of cran packages"
  $ECHO "        -d                       --  use defaults for input files"
  $ECHO "        -g <github_pkg_input>    --  names of github packages"
  $ECHO "        -i <instance_name>       --  instance name"
  $ECHO "        -l <local_pkg_input>     --  directories of local packages"
  $ECHO "        -p <pkg_install_script>  --  package install script"
  $ECHO "        -r <r_lib_dir>           --  R library directory"
  $ECHO "        -s <remote_server>       --  hostname of remote server"
  $ECHO ""
  exit 1
}

#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
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


#' ### R-Package Installation
#' R-Packages from a given list are installed on an as-needed basis.
#+ install-rpkg-fun, eval=FALSE
install_rpkg () {
  local l_REMOTESERVER=$1
  # run local version, if we are already on $l_REMOTESERVER
  if [ "$l_REMOTESERVER" == "$SERVER" ]
  then
    # check whether $RLIBDIR exists
    if [ ! -d "$RLIBDIR" ]
    then 
      log_msg 'install_rpkg' " ** Lib-dir $RLIBDIR not found ==> create it ..."
      mkdir -p $RLIBDIR
    fi
    # install packages
    log_msg 'install_rpkg' " ** Install R packages to $RLIBDIR ..."
    singularity exec instance://$INSTANCENAME R -e ".libPaths('$RLIBDIR');cran_pkg<-'$CRANPKG';ghub_pkg<-'$GHUBPKG';local_pkg<-'$LOCALPKG';source( '$RPKGSCRIPT' )" --vanilla --no-save
  else
    ssh zws@$l_REMOTESERVER "if [ ! -d \"$RLIBDIR\" ];then  echo \" * r-lib-dir: $RLIBDIR not found ==> create it ...\";mkdir -p $RLIBDIR;fi"
    log_msg 'install_rpkg' " ** Install R packages to $RLIBDIR on server $l_REMOTESERVER ..."
    ssh zws@$l_REMOTESERVER "singularity exec instance://$INSTANCENAME R -e \".libPaths('$RLIBDIR');cran_pkg<-'$CRANPKG';ghub_pkg<-'$GHUBPKG';local_pkg<-'$LOCALPKG';source( '$RPKGSCRIPT' )\" --vanilla --no-save"
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
REMOTESERVERS=(beverin castor niesen)
REMOTESERVERNAME=""
INSTANCENAME=""
RLIBDIR="/home/zws/lib/R/library"
SIMGROOT=/home/zws/simg
RPKGSCRIPT=$RPKGSCRIPTDEFAULT
CRANPKG=""
GHUBPKG=""
LOCALPKG=""
USEDEFAULT=""
while getopts ":c:dg:i:l:p:r:s:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    c)
      CRANPKG=$OPTARG
      ;;
    d)
      USEDEFAULT="TRUE"
      ;;
    g)  
      GHUBPKG=$OPTARG
      ;;
    i) 
      INSTANCENAME=$OPTARG
      ;;
    l)
      LOCALPKG=$OPTARG
      ;;  
    p)
      if [ -f "$OPTARG" ]
      then
        RPKGSCRIPT=$OPTARG
      else
        usage "CANNOT find $OPTARG as <r_pkg_script>"
      fi
      ;;
    r)
      RLIBDIR=$OPTARG
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
if test "$RLIBDIR" == ""; then
  usage "-r <r_lib_dir> not defined"
fi

#' Check whether default settings for input files should be used.
if [ "$USEDEFAULT" == "TRUE" ]
then
  log_msg $SCRIPT " * Using default values for input files ..."
  CRANPKG=$CRANPKGDEFAULT
  GHUBPKG=$GHUBPKGDEFAULT
  LOCALPKG=$LOCALPKGDEFAULT
fi

#' ## Install R-packages
#' if specified install R-packages
#+ install-rpack, eval=FALSE
if [ "$REMOTESERVERNAME" != "" ]
then
  install_rpkg $REMOTESERVERNAME
else
  for s in ${REMOTESERVERS[@]}
  do
    install_rpkg $s
    sleep 2
  done
fi


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

