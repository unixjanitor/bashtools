#!/bin/bash

# bw.sh - Bash Watch
# Version 1.0
# Command loop script for large environments
# Jeff Hudson
# jeff.hudson@gmail.com

################ Var Config - Set variables that may change ###################
sleep_sec="10"
clear="false"
###############################################################################

# Set or instantiate variables that will not likely change
bold_on="\033[1m"
bold_off="\033[0m"
command="${1}"
timer="0"
sleep_time="0"

# Sleep Cycle function: sleep_cycle ${sleep_sec}
sleep_cycle ()
{
    my_timer="${timer}"
    sleep_time="${1}"
    echo -en "Sleeping for ${bold_on}${sleep_time}${bold_off} seconds"
    while [ "${my_timer}" -lt "${sleep_time}" ];
    do
        echo -en "${bold_on}.${bold_off}"
        my_timer=`expr ${my_timer} + 1`
        sleep 1
    done
    echo
}

while getopts "Hc:s:C" opt
do
    case ${opt} in
        H)
            # Help flag found, output help
            echo -e "${bold_on}Usage:${bold_off}\n\t${0} ${bold_on}-s SLEEP_SEC -c COMMAND${bold_off} [-C]\n"
            exit 1
            ;;
        c)
            command="${OPTARG}"
            ;;
        s)
            # Sleep flag found, setting sleep cycle, default is a random number out of 180
            sleep_sec="${OPTARG}"
            ;;
        C)
            # Clear flag found
            clear="true"
            ;;
    esac
done

while [ true ]; do
    if [ "${sleep_sec}" == "R" ]; then
        sleep_time=`expr $RANDOM % 180`
        sleep_time=`expr ${sleep_time} + 120`
    else
        sleep_time="${sleep_sec}"
    fi
    if [ "${clear}" == "true" ]; then
        clear
    fi
	${command}
    sleep_cycle "${sleep_time}"
done
