#!/bin/nsh
###########
#
# Racemi Remove Server Script
# BladeLogic
#
############
# 
# Parameters:
#     * Name of server to be removed
############
clear

###
# Some variables used in the script
###
SERVER_NAME=$1
if [ "$SERVER_NAME" = "" ]
then
    echo Server name undefined.
    ERROR=true
else 
    echo Server name : $SERVER_NAME
fi

if [ "$ERROR" = "true" ]
then
    echo "Usage: remove-server.nsh <Server_Name>"
    exit 1
fi

###
# Make sure the server is in OM. If it is, remove it.
###
SERVER_EXISTS=`blcli Server serverExists $SERVER_NAME`
if [ "$SERVER_EXISTS" = "true" ]
then
    echo Decommissioning server $SERVER_NAME
    SERVER_ID=`blcli Server decommissionServer $SERVER_NAME`
    RESULT=`echo $SERVER_ID | grep failed`
    if [ -n "$RESULT" ] 
    then
       echo Failed to decommission server: $RESULT
       exit 1
    else
       echo Server was decommissioned successfully
    fi
else
    echo Server not Enrolled.
fi

exit 0
