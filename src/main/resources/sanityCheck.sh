#!/bin/bash
if [ ! ${RUNNABLEASUSER} ] && [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo ! ";
    exit;
fi
if [ -n ${REL_HOSTNAME} ];
    then
        echo "Hostname not set, setting to $(hostname -s)";
        REL_HOSTNAME=`hostname -s`;
fi;
if ! [ -d ${REL_HOSTNAME} ];
   then
        echo "No valid environment dir found, exiting";
        exit;
fi;
if ! [ -e ${REL_HOSTNAME}/shell/envSetup.sh ];
   then
        echo "No valid envSetup.sh script found (searched in ${REL_HOSTNAME}/shell";
        exit;
fi;
source ${RELHOSTNAME}/shell/envSetup.sh;
# Don't hesitate to add special required variable in this check
if [ -z ${GFHOME} ] || [ -z ${SQL_USER} ] || [ -z ${DOMAIN_NAME} ] || [ -z ${SQL_HOST} ] || [ -z ${GF_USER} ];
    then
    echo "Variables not set, exiting. Please source the correct envSetup.sh for your environment !";
    exit;
fi;
