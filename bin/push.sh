#!/bin/bash

# push.sh - Push files to hosts
# Version 1.1
# File push script for large environments
# Jeff Hudson
# jeff.hudson@gmail.com

################ Var Config - Set variables that may change ###################
hosts="nodelist"
user="jhudson"
host_base="hostlist-"
host_root="${HOME}/hosts/${host_base}"
file="${1}"
tdest="~/"
my_key="~/.ssh/id_rsa"
###############################################################################

# Set or instantiate variables that will not likely change
bold_on="\033[1m"
bold_off="\033[0m"
dir=
sleep_sec=
timer="0"
parallel=
host_list=
host_list_type=

# Get Hosts function: get_hosts ${hosts}
get_hosts ()
{
    myhost_root=$(echo ${host_root} | sed 's/ /?/')
    for host in ${hosts}
    do
        if [ -f "./${host_base}${host}" ]; then
            host_list="${host_list} $(cat ./${host_base}${host})"
        elif [ -f "${host_root}${host}" ]; then
            host_list="${host_list} $(cat ${myhost_root}${host})"
        else
            host_list="${host_list} ${host}"
        fi
    done
}

# Sleep Cycle function: sleep_cycle ${sleep_sec}
sleep_cycle ()
{
    my_timer="${timer}"
    if [ "${1}" == "R" ]; then
        sleep_time=$(expr $RANDOM % 300)
    else
        sleep_time="${1}"
    fi
    echo -en "Sleeping for ${bold_on}${sleep_time}${bold_off} seconds"
    while [ "${my_timer}" -lt "${sleep_time}" ];
    do
        echo -en "${bold_on}.${bold_off}"
        my_timer=$(expr ${my_timer} + 1)
        sleep 1
    done
    echo
}

while getopts "Hu:h:f:d:t:s:k:P" opt
do
    case ${opt} in
        H)
            # Help flag found, output help
            echo -e "${bold_on}Usage:${bold_off}\n\t${0} [-H] [-u USER] [-h HOST|HOST_GROUP] [-f] ${bold_on}FILE${bold_off} [-d Directory] [-t TARGET_DESTINATION] [-s SLEEP_SEC(R for Random)] [-P]\n"
            echo -e "\t${bold_on}-H${bold_off}\tPrint this Help"
            echo -e "\t${bold_on}-k${bold_off}\tIdentity Key file to use for ssh"

            echo -e "\t${bold_on}-P${bold_off}\tExecute command in parallel on hosts"
            exit 1
            ;;
        u)
            # User flag found, set $user
            user="${OPTARG}"
            ;;
        h)
            # Host flag found, set $hosts
            hosts="${OPTARG}"
            ;;
        f)
            # File flag found, set file
            file="${OPTARG}"
            ;;
        k)
            # Key flag found, set ssh key, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]; then
				my_key="${OPTARG}"
			else
				echo -e "Argument not found for option: ${opt}\nUsing default value: ${my_key}"
			fi
			;;

        d)
            # Directory flag found, set file and dir
            file="${OPTARG}"
            dir="true"
            ;;
        t)
            # Target destination flag found, set $tdest
            tdest="${OPTARG}"
            ;;
        s)
            # Sleep flag found, set $sleep_sec
            sleep_sec="${OPTARG}"
            ;;
        P)
            # Parallel flag found, set $parallel
            parallel="true"
            ;;
    esac
done

# Get complete host list
get_hosts "${hosts}"

for h in ${host_list}
do
    echo -e "########"
    echo -e "## ${bold_on}${h}${bold_off}"
    echo -e "\n# Transferring ${file} to ${h}:${tdest}"
    if [ "${dir}" ]; then
        if [ "${parallel}" ]; then
            ( scp -r -o USER="${user}" -o IdentityFile="${my_key}" "${file}" "${h}":"${tdest}" ) &
        else
            scp -r -o USER="${user}" -o IdentityFile="${my_key}" "${file}" "${h}":"${tdest}"
        fi
    else
        if [ "${parallel}" ]; then
            ( scp -o USER="${user}" -o IdentityFile="${my_key}" "${file}" "${h}":"${tdest}" ) &
        else
            scp -o USER="${user}" -o IdentityFile="${my_key}" "${file}" "${h}":"${tdest}"
        fi
    fi
    if [ "${sleep_sec}" ]; then
        sleep_cycle "${sleep_sec}"
    fi
done

