#!/bin/bash
###
###
###
###   Purpose:   Automatic testing of container
###   started:   2019-02-26 12:44:27 (pvr)
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
# ======================================== # ======================================= #



### # ====================================================================== #
### # functions
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -t <example_test_dir>"
  $ECHO "  where -t <example_test_dir> example test directory"
  $ECHO ""
  exit 1
}

### # produce a start message
start_msg () {
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
}

### # produce an end message
end_msg () {
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
}



### # ====================================================================== #
### # Use getopts for commandline argument parsing ###
### # If an option should be followed by an argument, it should be followed by a ":".
### # Notice there is no ":" after "h". The leading ":" suppresses error messages from
### # getopts. This is required to get my unrecognized option code to work.
TESTDIR=""
while getopts ":t:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    t)
      TESTDIR=$OPTARG
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


### # ====================================================================== #
### # Main part of the script starts here ...
start_msg

### # if TESTDIR was not specified run all tests
if [ "$TESTDIR" == "" ];then
  find . -type d | while read d
    do
      echo 'run'
    done

else
  echo -n "Test: "`head -3 $TESTDIR/$TESTDIR.sh | tail -1 | cut -d ':' -f2`
  $TESTDIR/$TESTDIR.sh > $TESTDIR/$TESTDIR.tmp
  if [ `diff $TESTDIR/$TESTDIR.out $TESTDIR/$TESTDIR.tmp | wc -l` -ne "0" ]; then
    diff $TESTDIR/$TESTDIR.out $TESTDIR/$TESTDIR.tmp | less
  else
    echo ' ==> OK'
    rm $TESTDIR/$TESTDIR.tmp
  fi  
fi	




### # ====================================================================== #
### # Script ends here
end_msg



### # ====================================================================== #
### # What comes below is documentation that can be used with perldoc

: <<=cut
=pod

=head1 NAME

   run-tests - run-tests

=head1 SYNOPSIS


=head1 DESCRIPTION

Run all tests scripts in subdirectories


=head2 Requirements

Container is running


=head1 LICENSE

Artistic License 2.0 http://opensource.org/licenses/artistic-license-2.0


=head1 AUTHOR

Peter von Rohr <peter.vonrohr@qualitasag.ch>


=head1 DATE

2019-02-26 12:44:27

=cut
