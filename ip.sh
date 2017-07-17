#!/bin/bash

# ------------------------------------------------------------------
#  Author: Matthew Remmel (matt.remmel@gmail.com)
#  Title: IP
#
#  Description: IP is a command line util to display the primary
#               internal IP address, as well as the external IP
#               address. The script uses 'curl' and 'ipecho.net'
#               to retrieve the external IP address. The output
#               is formatted and echoed to standard out.
#
#  Return:      A 1 is returned if the external IP address cannot
#               be retreived. A 0 is returned otherwise.
#
#  Dependency:  curl, wget
# ------------------------------------------------------------------

# --- Version and Usage ---
DESCRIPTION="Description: Displays internal and external ip addresses"
VERSION=0.2.2
USAGE="Usage: ip [OPTION]

Options:
-h, --help       Show help and usage information
-v, --version    Show version information
-i, --internal   Show internal ip address only
-e, --external   Show external ip address only"

# --- Dependecy Check ---
command -v curl >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'curl' not installed. Exiting."; exit 1; }
command -v grep >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'grep' not installed. Exiting."; exit 1; }

# --- Arguments ---
INTERNALONLY=1
EXTERNALONLY=1

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
	-h|--help)
	    echo "$DESCRIPTION"
	    echo
	    echo "$USAGE"
	    echo
	    exit 0
	    ;;
	-v|--version)
	    echo "Version: $VERSION"
	    exit 0
	    ;;
	-i|--internal)
	    INTERNALONLY=0
	    ;;
	-e|--external)
	    EXTERNALONLY=0
	    ;;
	*)
	    echo "Unknown argument: $key"
	    exit 1
	    ;;
    esac

    shift
done

# --- Main Body ---
EXITCODE=0

# Get internal IP address
LOCALIP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# Get external IP address if available
IPECHO=$(curl -m 5 http://ipecho.net/plain 2>/dev/null)

if [ $? -eq 0 ]; then
    EXTERNALIP=$IPECHO
else
    EXTERNALIP="Could not retreive external IP address. Check connection."
    EXITCODE=1
fi

# Print IP address information
if [ $INTERNALONLY -eq 0 ]; then
    echo $LOCALIP
elif [ $EXTERNALONLY -eq 0 ]; then
    echo $EXTERNALIP
else
    for ADDR in $LOCALIP; do
	echo "Internal: $ADDR"
    done

    echo "External: $EXTERNALIP"
fi

exit $EXITCODE
