#!/bin/nsh
###########
#
# Reboot Server Script
# BladeLogic
#
###
# 
###
# 
###
#
# This script reboots a server in the BladeLogic environment and waits for the server
# to return to service,  
# Several  variables determine the maximum shutdown time and wait time.
#
############


###
# Some variables used in the script
###
# Allow the server 10 minutes to shut down
MAX_SHUTDOWN_TIME=600
# Runs a check every 30 seconds until the system system is down.
SHUTDOWN_INTERVAL=30
# Allow the server up to 30 minutes to come back up
MAX_REBOOT_TIME=1800
# Runs a check every 30 seconds until the system is back up.
REBOOT_INTERVAL=30

if [ $# -ge 1 ]
        then
        echo "Accepting boot Arguments for Solaris"
            BOOT_ARGS=$@
        echo "Boot Args: $BOOT_ARGS"
fi

OS=`uname -s`
HOSTNAME=$NSH_RUNCMD_HOST
# The NSH_RUNCMD_HOST envar retuns the FQDN which is what we want
 
if [ "$OS" = "WindowsNT" ]
then
    DEVNULL=NUL
else
    DEVNULL=/dev/null
fi
 
if test -z "$HOSTNAME"
then
    echo Usage $0 hostname
    exit 1
fi
 
pwd | egrep -q ^//
 
if [ $? -ne 0 ] 
then
            print "ERROR: You must run this script using the \"runscript\" option." 1>&2
            exit 1
fi
 
# Have to be local so the uname -D command works properly
cd //@/
 
agent_up ()
{
#    uname -D //$1/ > $DEVNULL 2> $DEVNULL
    echo uname -D //$1/
    uname -D //$1/
    return $?
}
 
if agent_up $HOSTNAME
then
 
    echo Rebooting server $HOSTNAME ...
 
    case "$OS" in
        SunOS)
                        if [ -z $BOOT_ARGS ] 
                                    then
                                    nexec $HOSTNAME shutdown -i6 -y -g 0 &
                        else
                                    nexec $HOSTNAME reboot -- $BOOT_ARGS &
                        fi
            ;;
 
        Linux)
            nexec $HOSTNAME shutdown -r now &
            ;;
 
        AIX)
            nexec $HOSTNAME shutdown -r +5&
            ;;
 
 
        WindowsNT)
            nexec $HOSTNAME reboot
            ;;
 
        *)
            echo "Unknown platform \"$OS\""
            exit 1
            ;;
    esac
 
    if test $? -ne 0
    then
        echo '***** Warning - Error in sending reboot request'
    fi
 
    #
    # Give the server a certain amount of time to kill the
    # agent and reboo
    #
    count=$SHUTDOWN_INTERVAL
    sleep $SHUTDOWN_INTERVAL
 
    while agent_up $HOSTNAME
    do
        echo `date` Agent still running ...
        count=`expr $count + $SHUTDOWN_INTERVAL`
 
        if test $count -gt $MAX_SHUTDOWN_TIME
        then
            echo "Reboot command sent but server not coming down"
           # Cleanup any background jobs which did not exit.
            kill %1; kill %2; kill %3
            exit 1
        fi
 
        sleep $SHUTDOWN_INTERVAL
    done
 
    #
    # Now we know the agent is down and we are waiting for the
    # system to reboot. Allow time to come back up.
    #
    count=$REBOOT_INTERVAL
    sleep $REBOOT_INTERVAL
 
    while ! agent_up $HOSTNAME
    do
        echo `date` Agent still not up ...
        count=`expr $count + $REBOOT_INTERVAL`
        sleep $REBOOT_INTERVAL
 
        if test $count -gt $MAX_REBOOT_TIME
        then
            echo "Reboot has not yet come up after more than $count seconds ..."
            # Cleanup any background jobs which did not exit.
            kill %1; kill %2; kill %3
            exit 1
        fi
    done
 
    echo Server $HOSTNAME back up and running
       # Cleanup any background jobs which did not exit.     
        kill %1; kill %2; kill %3
else
    echo Agent currently not running
    # Cleanup any background jobs which did not exit.     
    kill %1; kill %2; kill %3
    exit 1
fi
exit 0
