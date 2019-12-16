#/bin/bash
##############################################################################
# $Id: INSTALL,v 1.25 2018/06/11 08:01:31 heli Exp $
# Installation script for TheSNPpit
# sollten wir vielleicht trennen nach Software Installation und Konfiguration.
# Letzteres ist bei den Linuxen wohl eher ähnlich.
# und dann eine eingebaute Liste der zu installierenden SW ausgeben.
##############################################################################

### Copyright #############################################################{{{
# Copyright 2011-2016 Cong V.C. Truong, Helmut Lichtenberg, Eildert Groeneveld
#
# This file is part of the software package TheSNPpit.
#
# TheSNPpit is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 2 of the License, or (at your option) any later
# version.
#
# TheSNPpit is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# TheSNPpit.  If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Cong V.C. Truong    (cong.chi@fli.bund.de) Helmut Lichtenberg
# (helmut.lichtenberg@fli.bund.de) Eildert Groeneveld
# (eildert.groeneveld@fli.bund.de)
###########################################################################}}}

### Configure start ##########################################################
# BASE_DIR=/usr/local
CURR_VERSION=$(cat etc/VERSION)
ADMINUSER=snpadmin
ADMINGROUP=snp
DB_ENCODING=utf8
DB_NAME=TheSNPpit
### Configure end ############################################################

##############################################################################
### Functions start ##########################################################
##############################################################################
# print errors in red on STDERR and exit
err_exit () {
    if [[ -t 2 ]] ; then
        printf '\E[31m'; echo "ERROR: $@"; printf '\E[0m'
    else
        echo "$@"
    fi >&2
    exit 1
}

##############################################################################
# print errors in red on STDERR
error () {
    if [[ -t 2 ]] ; then
        printf '\E[31m'; echo "ERROR: $@"; printf '\E[0m'
    else
        echo "$@"
    fi >&2
}
##############################################################################
ok () {
    if [[ -t 2 ]] ; then
        printf '\E[32m'; echo "OK:    $@"; printf '\E[0m'
    else
        echo "$@"
    fi
}
##############################################################################
info () {
    if [[ -t 2 ]] ; then
        printf "\E[34mINFO:  %s\E[0m \n" "$@"
    else
        echo "INFO: $@"
    fi >&2
}
##############################################################################
check_for_root() {
    if [ ! $( id -u ) -eq 0 ]; then
        err_exit "Must be run as root"
    fi
}
##############################################################################
get_base_dir () {
    BASE_DIR=$(pwd -P)
    BASE_DIR=$(echo $BASE_DIR |sed -e "s/TheSNPpit-$CURR_VERSION//")

    echo -n "Installing TheSNPpit in $BASE_DIR (Terminate with Ctrl-C): " && read 
    if [ ! -d $BASE_DIR ]; then
        mkdir -p $BASE_DIR
        info "$BASE_DIR created"
    fi
    info "Installing TheSNPpit in $BASE_DIR"
}

##############################################################################
# SNPpit braucht mindestens postgresql-9.3
# the version numbering has changed as of 10 with no subversion
# 
# In der Anpassung gehen wir hiervon aus:
# 1. VERSION  entweder 9
# 2. SUBVERSION :  3
#
#
install_postgresql () {
#   PACKET=$(apt-cache search postgresql-9 |grep -i server |egrep 'postgresql-9.[3-9] ' |awk '{print $1}' |head -1)
  PACKET=$(apt-cache search postgresql- |grep -i 'object-relational SQL' |egrep 'postgresql-[10-99]' |awk '{print $1}' |head -1)
#   PACKET=postgresql-10
    apt-get --yes install $PACKET
}
##############################################################################
is_pg_superuser () {
    # echo "select usesuper from pg_user where usename = 'snpadmin'" |su -l -s /bin/bash -c "psql --tuples-only --quiet --no-align" postgres
    echo "not yet implemented"
}
##############################################################################
# can we access the database?:
has_pg_access () {
    psql -l >/dev/null 2>&1
    return $?
}
##############################################################################
get_pg_access_for_root () {
    su -l -s /bin/bash -c "createuser --superuser root" postgres
}
##############################################################################
check_hba_conf () {
    # save old pg_hba.conf and prepend a line:
    grep -q "^host  *all  *snpadmin .*trust$" $ETC_DIR/pg_hba.conf >/dev/null
    if [ $? -eq 0 ]; then
        ok "$ETC_DIR/pg_hba.conf already configured"
    else
        NOW=$(date +"%Y-%m-%d_%H:%M:%S")
        mv $ETC_DIR/pg_hba.conf $ETC_DIR/pg_hba.conf-saved-$NOW
        echo "# next line added by TheSNPpit installation routine ($NOW)" >$ETC_DIR/pg_hba.conf
        echo "# only these two lines are required, that standard configuration"
        echo "# as usually (2019) can be found the end can stay as is"
        # IPV4:
        echo "host  all   snpadmin   127.0.0.1/32   trust" >>$ETC_DIR/pg_hba.conf
        # IPV6:
        echo "host  all   snpadmin   ::1/128        trust" >>$ETC_DIR/pg_hba.conf
        cat $ETC_DIR/pg_hba.conf-saved-$NOW >>$ETC_DIR/pg_hba.conf
        info "Note: $ETC_DIR/pg_hba.conf saved to $ETC_DIR/pg_hba.conf-saved-$NOW and adapted"
        su -s /bin/bash -c "$PG_CTL -D $DATA_DIR reload" postgres >/dev/null
    fi
}
##############################################################################
multiple_pg_installations () {
    info "checking for multiple postgresql versions"
    COUNT=$(dpkg -l postgresql* | egrep 'ii ' |egrep "object-relational SQL database, version" |wc -l)
    if [ $COUNT -gt 1 ]; then
        error "You have several installations of the PostgreSQL server"
        dpkg -l postgresql* | egrep 'ii ' |egrep "object-relational SQL database, version"
        info "Only one postgresq installation is allowed"
        info "BEWARE: you need a postgresql version >=9.3"
        err_exit "deinstall unwanted postgresql, Sorry!"
    fi
}
##############################################################################
get_pg_version () {
    info "collecting PG_version information"
    # we get here only after we have tested that there is only one
    # version of postgresql installed.
    # need PG_ALLVERSION  like 9.4 or 10
    # need PG_SUBVERSION  like 4
    # need PG_VERSION     like 9
    # need PG_PACKET      like postgresql_11
    PG_PACKET=$(dpkg -l postgresql*    | egrep 'ii ' |egrep "SQL database, version" |awk '{print $2}')

    if [ -n "$PG_PACKET"  ]; then
       if [[ $PG_PACKET = *9.* ]]; then
# subv wird packet bei 10 11 etc
          PG_SUBVERSION=$(dpkg -l postgresql*| egrep 'ii ' |egrep "SQL database, version" |awk '{print $2}'|sed -e 's/postgresql-9.//')
       else
          PG_SUBVERSION=' '
          echo no subversion
       fi
    fi

    PG_ALLVERSION=$(dpkg -l postgresql*| egrep 'ii ' |egrep "SQL database, version" |awk '{print $2}'|sed -e 's/postgresql-//')
    PG_VERSION=$(echo $PG_ALLVERSION |  cut -d. -f1)
    echo packet_____:$PG_PACKET
    echo version____:$PG_VERSION
    echo subversion_:$PG_SUBVERSION
    echo allversion_:$PG_ALLVERSION
}
if [[ $var = *pattern1* ]]
then
    echo "Do something"
fi
##############################################################################
configure_postgresql () {
    # create snpadmin with superuser privilege
    # info "Running configure_postgresql ..."
    # as of version 10 no subversion: postgresql-10: use the 10
    # VERSION is now version.subversion as used in ETC_DIR
    PG_CTL="/usr/lib/postgresql/${PG_ALLVERSION}/bin/pg_ctl"
    ETC_DIR="/etc/postgresql/${PG_ALLVERSION}/main"
    if [ ! -d $ETC_DIR ]; then
        err_exit "ETC_DIR $ETC_DIR doesn't exist"
    fi

    has_pg_access
    if [ $? -ne 0 ]; then
        error "You have no right to access postgresql, wait ..."
        get_pg_access_for_root
        if [ $? -ne 0 ]; then
            err_exit "Can't create root a postgresql superuser"
        fi
        ok "Access rights to root granted"
    fi

    DATA_DIR=$(echo "show data_directory" |su -l -s /bin/bash -c "psql --tuples-only --quiet --no-align" postgres)
    if [ ! -d $DATA_DIR ]; then
        err_exit "DATA_DIR $DATA_DIR doesn't exist"
    fi

    echo "select usename from pg_user where usename = '$ADMINUSER'" |psql postgres --tuples-only --quiet --no-align |grep -q $ADMINUSER >/dev/null
    if [ $? -eq 0 ]; then
        ok "PostgreSQL ADMINUSER $ADMINUSER exists"
    else
        su -l -s /bin/bash -c "createuser --superuser $ADMINUSER" postgres
        su -s /bin/bash -c "$PG_CTL -D $DATA_DIR reload" postgres >/dev/null
        ok "PostgreSQL ADMINUSER $ADMINUSER created"
    fi

    # save old pg_hba.conf and prepend a line:
    check_hba_conf
}
##############################################################################
install_thesnppit_db () {
    # does database exist?:
    psql -l --tuples-only --quiet --no-align --field-separator=' '|awk '{print $1}' |grep "^${DB_NAME}$" >/dev/null
    if [ $? -eq 0 ]; then
        ok "TheSNPpit Database exists"
    else
        info "Creating TheSNPpit Database ..."
        createdb --encoding=$DB_ENCODING --owner=$ADMINUSER --no-password $DB_NAME

        # check again:
        psql -l --tuples-only --quiet --no-align --field-separator=' '|awk '{print $1}' |grep "^${DB_NAME}$" >/dev/null
        if [ $? -eq 0 ]; then
            ok "TheSNPpit Database exists"
        fi

        # fill the newly created database with the structure:
        su -s /bin/bash -c "psql -q -f ${SNP_LIB}/TheSNPpit.sql $DB_NAME -U $ADMINUSER" $ADMINUSER
        if [ $? -eq 0 ]; then
            ok "TheSNPpit Database structure created"
        fi
    fi

    # "host    TheSNPpit       snpadmin        127.0.0.1/32            trust"
    # /etc/postgresql/9.4/main/pg_hba.conf

}
##############################################################################

### Functions end ############################################################
##############################################################################

# some preliminary check:
if [ -z "$CURR_VERSION" ]; then
    error    "This is not a distribution of TheSNPpit for installation"
    error    "or you are in the wrong directory."
    err_exit "Unknown version. Can't read etc/VERSION"
else
    ok "TheSNPpit Version $CURR_VERSION"
fi

check_for_root
get_base_dir
SNP_HOME=${BASE_DIR}/TheSNPpit_current
SNP_LIB=${SNP_HOME}/lib

# link latest version to TheSNPpit_current:
ln -snf ${BASE_DIR}/TheSNPpit-$CURR_VERSION $SNP_HOME

# create binary snppit:
cat >/usr/local/bin/snppit <<EndOfSNPpitsh
#!/bin/bash
SNP_HOME=$SNP_HOME
exec ${SNP_HOME}/bin/TheSNPpit "\$@"

EndOfSNPpitsh

# Does group snp exist:
getent group $ADMINGROUP >/dev/null
if [ $? -eq 0 ]; then
    ok "ADMINGROUP $ADMINGROUP exists"
else
    info "ADMINGROUP $ADMINGROUP does not exist, creating ..."
    addgroup --system $ADMINGROUP
fi

# Does user snpadmin exist:
getent passwd $ADMINUSER >/dev/null
if [ $? -eq 0 ]; then
    ok "ADMINUSER $ADMINUSER exists"
else
    info "ADMINUSER $ADMINUSER does not exist, creating ..."
    getent group $ADMINGROUP >/dev/null
    HAS_GROUP=$?
    if [ $HAS_GROUP -ne 0 ]; then
        addgroup --system $ADMINGROUP
    fi
    adduser --system --home /tmp --shell /bin/bash --no-create-home \
            --ingroup $ADMINGROUP --disabled-password --disabled-login \
            --gecos "TheSNPpit admin user" $ADMINUSER
fi

# do we have admin user now?
getent passwd $ADMINUSER >/dev/null
if [ $? -ne 0 ]; then
    err_exit "Problems creating ADMINUSER $ADMINUSER, see errors above"
fi

# set permissions:
find -L ${SNP_HOME}/ -type d -print0 |xargs -0 chmod 750
find -L ${SNP_HOME}/ -type f -print0 |xargs -0 chmod 640
chmod 750 ${SNP_HOME}/bin/*
chmod 750 ${SNP_HOME}/contrib/bin/*
mkdir -p ${SNP_HOME}/regression/tmp
chmod 770 ${SNP_HOME}/regression/tmp
chown -R -L ${ADMINUSER}:$ADMINGROUP $SNP_HOME
chown ${ADMINUSER}:$ADMINGROUP /usr/local/bin/snppit
chmod 750 /usr/local/bin/snppit

# Installation of new packages:
apt-get update

# Does Perl exist:
perl -v >/dev/null
if [ $? -eq 0 ]; then
    ok "Perl already installed"
else
    error "Perl is not installed!"
    info "Installing Perl with dependencies ..."
    apt-get --yes install perl
fi
#################################################################
# deal with postgresql now:
#
# check Postgresql existence and version:
multiple_pg_installations

get_pg_version

# operational version installed? if PG_PACKET set: may be more than 1!!
if [ -n "$PG_PACKET" ]; then
   if [ ${PG_VERSION} -eq 9 ] && [ ${PG_SUBVERSION} -le 3 ] ; then
       error "you need to have postgresql version > 9.3, sorry"
   fi
   ok "operational version of postgresql installed:" $PG_PACKET
   configure_postgresql
else
   install_postgresql
   get_pg_version
   configure_postgresql
fi

# install more required packages:
info "Installing more required packages ..."
${SNP_HOME}/bin/install_debian_packages
if [ $? -eq 0 ]; then
    ok "Installation of required packages done"
else
    error "Installation of required packages failed"
fi

# install required Perl packages:
info "Installing required Perl packages ..."
${SNP_HOME}/bin/install_perlmd -q --debian --install
if [ $? -eq 0 ]; then
    ok "Installation of required Perl packages done"
else
    error "Installation of required Perl packages failed"
fi

# let's see, if snppit runs:
snppit --help >/dev/null
if [ $? -eq 0 ]; then
    ok "snppit now seems to run ok"
else
    err_exit "There seems to be a problem running snppit"
fi

# install TheSNPpit database:
install_thesnppit_db

# run basic tests:
info "===> Installation mainly done now. Running some basic tests now ..."
$SNP_HOME/bin/install_testdb
if [ $? -eq 0 ]; then
   ok "===> Basic tests ok. Installation of TheSNPpit complete"
else
   error "Basic tests failed."
fi

### ToDo: create normal user with limited privileges

# vim: foldenable:foldmethod=marker
