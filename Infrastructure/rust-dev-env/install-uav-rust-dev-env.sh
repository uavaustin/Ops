#!/bin/bash

###############################################################################
# Installs and configures the UAV Austin Rust Dev Environment locally. 
# 
# Essentially, pulls a docker image from Docker Hub, ties it to a container
# with the appropriate mounts and devices, and adds some helpful aliases.
############################################################################### 

# All or nothing:
set -e

# Configuration Variables #
IMAGE_NAME="uavaustin/rust-dev-env:latest"

output="true"

# Colours #
BOLD='\033[0;1m' #(OR USE 31)
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Functions:

function print
{
    if [[ "$output" != "true" ]]; then return; fi

    N=0
    n="-e"

    if [[ "$*" == *" -n"* ]]; then
        N=1
        n="-ne"
    fi

    if [ "$#" -eq $((1 + $N)) ]; then
        echo $n $1
    elif [ "$#" -eq $((2 + $N)) ]; then
        printf ${2} && echo $n $1 && printf ${NC}
    else
        #printf ${RED} && echo "Error in print. Received: $*" && printf ${NC}
        printf ${RED} && echo "Received: $*" && printf ${NC}
    fi
}

function helpText
{

cat << EOF
usage: ./install-uav-rust-dev-env.sh [-i <image name>] [-p <project dir>] [-t <container tag>] [-a <alias file>| -A] [-D] [-q]
 
    -i <image name>     Image Name: Specific docker image to use for the container (default is uavaustin/rust-dev-env:latest)
    -p <project dir>    Shared Dir: Folder to mount into the Docker Container (default is ~/Documents/UAVA/)
    -t <container tag>  Custom Tag: Custom tag to use for the Docker Container (default is uava-dev)
    -a <alias file>     Alias File: Add aliases to a specified file (default is ~/.bash_aliases)             
    -A                  No Aliases: Skip adding aliases
    -D                  Debug Mode: Internally runs set -x (prints out all commands run, line by line)
    -q                  Quiet Mode: Supresses all feedback from the script (but not from other executables)
    -h                  Print Help: Prints this
EOF

exit $1

}

function badEnv
{
    print "Go to http://uavaustin.org/camp/rust/0 for instructions on how to configure your environment." $BOLD
    exit $1
}

function processArguments
{
    return 0
}

function checkOS
{
    #Creds to SO: http://bit.ly/1pHeRRa
    if [ "$(uname)" == "Darwin" ]; then
        print "Hey there macOS user!" $CYAN
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if grep -q Microsoft /proc/version; then
          echo "Ubuntu on Windows"
        else
            echo "native Linux"
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        print "Sorry, Cygwin/MinGW are not supported at this time." $RED
        print "If you're on Windows 10, you can install Bash On Windows to"
        print "continue."
        badEnv 1
    fi


}

function checkDependencies
{
    dependencies=("docker cat grep expr whoami")

    exitC=0

    for d in ${dependencies[@]}; do
        if ! hash ${d} 2>/dev/null; then
            print "Error: ${d} is not installed." $RED
            exitC=1
        fi
    done

    # Check if we're in the docker group:
    if ! groups $(whoami) | grep &>/dev/null '\bdocker\b'; then
        print "Error: You are not in the docker group!"
        exitC=1
    fi

    return ${exitC}
}

function emergencyExit
{
    stty echo
    print "\nInstall incomplete; Are you sure you wish to exit? (enter option #)" $RED
    
    select yn in "Yes" "No"; do
        case $yn in
            Yes )  break;;
            No  )  return;;
        esac
    done

    # Failsafe exit actions go here:
    stty echo

    exit 1
}

trap emergencyExit SIGINT SIGTERM

{
    checkDependencies && \
    print "You're all set up! Adieu!" $CYAN
} || badEnv 1

# Check that docker is installed
# Process Args (all optional)
#   -i <custom image name>
#   -p <custom project dir>
#   -t <custom container tag>
#   -a <custom alias file>
#   -A (don't add aliases)
#   -q (quiet)
# Make the project directory if it doesn't exist
# Run docker run with specified/default image
# Install Aliases
# Bid them Adieu!



##########################
# AUTHOR:  Rahul Butani  #
# DATE:    Sept 03, 2017 #
# VERSION: 0.0.0         #
##########################