############
#
# Set Server Property Online/Offline
# BladeLogic
# Frank Lamprea 2007
#
###
# 
# Requirements:
#     * NSH installed on source
#
###
#
# This script sets a property (IS_ONLINE by default) to true or false.
#

###
# Some variables used in the script
###
PROPERTY_NAME=IS_ONLINE
PROPERTY_VAL=$2
SERVER=$1

###
# Output usage information
###
print_usage() {
	echo "Usage:"
	echo "server-status.nsh <server name> true|false"
}


###
# If host platform is a Window machine, emulate /dev/null
###
HOST_OS=$(uname -s)

if [ "$HOST_OS" = "WindowsNT" ]
then
	DEV_NULL="dev_null.tmp"
else
	DEV_NULL="/dev/null"
fi


###
# Check arguments
###
if [ $# -ne 2 ]
then
	echo "Incorrect number of arguments."
	print_usage
	exit 1
fi

###
# Make sure property is defined. Otherwise create it.
###
PROPERTY_EXISTS=`blcli Property propertyExists $PROPERTY_NAME`
if [ "$PROPERTY_EXISTS" = "false" ]
then
    echo "$PROPERTY_NAME does not exist."
    exit 1
fi


echo "Checking server: $SERVER"

###
# Make sure the server is in RBAC. If it isn't there, add it.
###
SERVER_EXISTS=`blcli Server serverExists $SERVER`
if [ "$SERVER_EXISTS" = "false" ]
then
	echo "Server $SERVER doesn't exist in RBAC. Adding it."
	SERVER_ID=`blcli Server addServer $SERVER`
	RESULT=`echo $SERVER_ID | grep failed`

	if [ -n "$RESULT" ] 
	then
		echo "Failed to add server: $RESULT"
		exit 1
	else
		echo "Server $SERVER was added successfully."
	fi
else
	SERVER_ID=`blcli Server getServerIdByName $SERVER`
fi

###
# Now set the property value on the server.
###
RESULT=`blcli Server setPropertyValueByName $SERVER $PROPERTY_NAME $PROPERTY_VAL`
RESULT=`echo $RESULT | grep com.bladelogic.model.server.ServerImpl@`
if [ -n "$RESULT" ]
then
	echo "$PROPERTY_NAME set to $PROPERTY_VAL on $SERVER"
else
	echo "Failed to set $PROPERTY_NAME to $PROPERTY_VAL on $SERVER. Result was: $RESULT"
fi


exit 0
