#!/bin/bash
###
###
###
###   Purpose:   Pull singularity image and run post-installation tasks.
###   started:   2019-08-14 15:22:17 (pvr)
###
### ###################################################################### ###

set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails

# ======================================== # ======================================= #
# global constants                         #                                         #
# ---------------------------------------- # --------------------------------------- #
# prog paths                               #                                         #  
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #
# ---------------------------------------- # --------------------------------------- #
# directories                              #                                         #
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #
# ---------------------------------------- # --------------------------------------- #
# files                                    #                                         #
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
# ---------------------------------------- # --------------------------------------- #
# server name                              #                                         #
SERVER=`hostname`                          # put hostname of server in variable      #  
# ======================================== # ======================================= #



### # ====================================================================== #
# Function definitions local to this script
#==========================================
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

### # produce a start message
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

### # produce an end message
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

### # functions related to logging
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

### # function to start instance
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

### # function to install r-packages
install_rpkg () {
  local l_imgtag=`basename $IMAGENAME | sed -e "s/.simg//"`
  local l_rlibdir=$RLIBDIR
  # check whether RLIBDIR was specified as a valid directory
  if [ -d "$l_rlibdir" ]
  then
    # if directory l_rlibdir exist, it must be empty
    if [ `ls -1 $l_rlibdir | wc -l` != "0" ]
    then
      log_msg install_rpkg " ** ERROR RLIBDIR $l_rlibdir is not empty, use other directory or delete all content ==> exit"
      exit 1
    fi
  else
    local l_rlibdir=$RLIBROOT/$l_imgtag
  fi
  # check whether $l_rlibdir exists
  if [ -d "$l_rlibdir" ]
  then
    log_msg install_rpkg " ** ERROR RLIBDIR $l_rlibdir already exists, delete directory or use a different RLIBDIR ==> exit"
    exit 1
  fi
  # create R lib dir
  log_msg install_rpkg " ** Create R lib dir: $l_rlibdir ..."
  mkdir -p $l_rlibdir
  # install packages
  log_msg install_rpkg " ** Install R packages to $l_rlibdir ..."
  singularity exec instance://$INSTANCENAME R --vanilla -e ".libPaths('$l_rlibdir');install.packages(c('devtools', 'BiocManager', 'doParallel', 'e1071', 'foreach', 'gridExtra', 'MASS', 'plyr', 'stringdist', 'rmarkdown', 'knitr', 'tinytex', 'openxlsx', 'LaF', 'tidyverse'), lib='$l_rlibdir', repos='https://cloud.r-project.org', dependencies=TRUE)"
}


### # ====================================================================== #
### # Main part of the script starts here ...
start_msg

### # ====================================================================== #
### # Use getopts for commandline argument parsing ###
### # If an option should be followed by an argument, it should be followed by a ":".
### # Notice there is no ":" after "h". The leading ":" suppresses error messages from
### # getopts. This is required to get my unrecognized option code to work.
BINDPATH=""
INSTANCENAME=""
IMAGENAME=""
RLIBDIR=""
RLIBROOT=/home/zws/lib/R
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

# Check whether required arguments have been defined
if test "$IMAGENAME" == ""; then
  usage "variable image_name not defined"
fi
if test "$SHUBURI" == ""; then
  usage "variable shub_uri not defined"
fi


# start by pulling the image
log_msg $SCRIPT " * Pulling img from shub ..."
singularity pull --name $IMAGENAME $SHUBURI

# start an instance of the pulled image, if instance name specified
if [ "$INSTANCENAME" != "" ] 
then
  start_instance
fi

# if specified install R-packages
if [ "$RLIBDIR" != "" ]
then
  install_rpkg
fi




### # ====================================================================== #
### # Script ends here
end_msg



### # ====================================================================== #
### # What comes below is documentation that can be used with perldoc

: <<=cut
=pod

=head1 NAME

    - 

=head1 SYNOPSIS


=head1 DESCRIPTION

Pull singularity image from singularity hub (SHUB) and run post-installation tasks.


=head2 Requirements



=head1 LICENSE

Artistic License 2.0 http://opensource.org/licenses/artistic-license-2.0


=head1 AUTHOR

Peter von Rohr <peter.vonrohr@qualitasag.ch>


=head1 DATE

2019-08-14 15:22:17

=cut
