#!/bin/nsh
###########
#
# Racemi Add Server Script
# BladeLogic
#
############
# 
# Parameters:
#     * Name of server to be added
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
    echo "Usage: add-server.nsh <Server_Name>"
    exit 1
fi

###
# Make sure the server is in OM. If it isn't, add it.
###
SERVER_EXISTS=`blcli Server serverExists $SERVER_NAME`
if [ "$SERVER_EXISTS" = "false" ]
then
    echo Adding server $SERVER_NAME
    SERVER_ID=`blcli Server addServer $SERVER_NAME`
    RESULT=`echo $SERVER_ID | grep failed`
    if [ -n "$RESULT" ] 
    then
       echo Failed to add server: $RESULT
       exit 1
    else
       echo Server was added successfully
    fi
else
    echo Server Already exists.
fi

exit 0
