#!/bin/bash

# mongodb_ebs_backup.sh - Mongodb AWS EC2 EBS Snapshot script
# Version 1.1.1
#
# For taking EC2 snapshots of the volumes on the local system
# Requires: XFS filesystems and AWS Commandline
#
# Author: Jeff Hudson
# jeff.hudson@gmail.com
#
# Change log:
# 1.1.0     Added commandline mount point support
# 1.1.1     Added error checking for XFS freeze/unfreeze and logging of
#               Master detected status
#
################################## Variables ##################################
#
# Default variable settings, over-ridable via command line options
mount_point="/data"
logfile="/var/log/ebssnapshot.log"
description="`hostname` backup"
tmp_description="${description} ${mount_point}"
snap_cmd="/usr/bin/aws ec2 create-snapshot --volume-id"
mongo_is_master="false"
mongo_host=`hostname`
mongo_dbport="27017"
mongo_username="mongouser"
mongo_password="mongopass"
debug="false"

################################## Constants ##################################
#
# Counters
counter="1"
date="$(date)"
total="0"
last_arg_count="1"
mylastarg="0"

# Fomating
bold_on="\033[1m"
bold_off="\033[0m"

################################## Functions ##################################
#
# Get the command
get_vols ()
{
    # Test to see if $command is set, if not take the last argument
    if [ ! "${vols}" ]
    then
        # Get the last arguments
        mylastarg=$(eval echo \${$last_arg_count})
        vols="${mylastarg}"
        for vol in ${vols}
        do
            total=$(expr ${total} + 1)
        done
    fi
}

# Backup volumes listed
backup_vols ()
{
    # For each volume defined in ${vols[@]}, initiate snapshot
    for vol in ${vols[@]}
    do
        if [[ "${vol}" =~ vol-* ]]
       then
           description_full="${tmp_description} - ${date} - ${counter}/${total}"
           if [ "${debug}" == "false" ]
           then
                ${snap_cmd} ${vol} --description "${description_full}" >> ${logfile} 2>&1 &
           else
                echo "${snap_cmd} ${vol} --description ${description_full} >> ${logfile}"
           fi
           pids[counter]="${!}"
           let counter+="1"
       else
           print_help
       fi
    done
}

# Wait for snapshot processes to finish initiating snapshot
wait_on_pids ()
{
    for pid in ${pids[@]}
    do
        wait ${pid}
    done
}

# Test for master
test_mongo_master ()
{
    if [ "${debug}" == "false" ]
    then
        mongo_is_master=`mongo -quiet ${mongo_host}:${mongo_dbport}/admin --username ${mongo_username} --password ${mongo_password} -eval "db.isMaster().ismaster"`
    elif [ "${debug}" == "true" ]
    then
        echo "mongo -quiet ${mongo_host}:${mongo_dbport}/admin --username ${mongo_username} --password ${mongo_password}"
    fi

    if [ ${mongo_is_master} == "true" ]
    then
        echo "MongoDB cluster Master detected, aborting snapshot" >> "${logfile}"
        exit 1;
    fi
}

# Freeze XFS Filesystem
freeze_xfs ()
{
    if [ "${debug}" == "false" ]
    then
        xfs_freeze -f ${mount_point}
        if [ "${?}" -ne "0" ]
        then
            echo "Failed to freeze XFS File System" >> "${logfile}"
        fi
    fi
}

# Unfreeze XFS Filesystem
unfreeze_xfs ()
{
    if [ "${debug}" == "false" ]
    then
        xfs_freeze -u ${mount_point}
        if [ "${?}" -ne "0" ]
        then
            echo "Failed to unfreeze XFS File System" >> "${logfile}"
        fi
    fi
}

# Print Help
print_help ()
{
	echo -e "${bold_on}Usage:${bold_off}\n\t${0} [-H] [-m MOUNT_POINT] [-h MONGODB_HOST]\n\t\t[-p MONGODB_PORT] [-U MONGODB_USERNAME] [-P MONGODB_PASSWORD]\n\t\t[-l LOGFILE] [-d DESCRIPTION] [-D] \"VOL1 [VOL2] [VOL3]...\"\n"
    echo -e "\t${bold_on}-H${bold_off}\tPrint this Help"
    echo -e "\t${bold_on}-m${bold_off}\tFile system mount point"
    echo -e "\t${bold_on}-h${bold_off}\tMongoDB hostname"
    echo -e "\t${bold_on}-p${bold_off}\tMongoDB port number"
    echo -e "\t${bold_on}-U${bold_off}\tMongoDB username"
    echo -e "\t${bold_on}-P${bold_off}\tMongoDB password"
    echo -e "\t${bold_on}-l${bold_off}\tLog file name and location"
    echo -e "\t${bold_on}-d${bold_off}\tSnapshot description"
    echo -e "\t${bold_on}-D${bold_off}\tDebug execution"
    echo
}


################################### GetOpts ###################################
#
# Example GetOps
#
# Get the options
while getopts ":Hm:h:p:U:P:l:d:D" opt
do
    case "${opt}" in
        H)
            # Help flag found, output help
            print_help
            exit 1
            ;;
        m)
            # Mount point flag found, set $mount_point, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]
            then
                mount_point="${OPTARG}"
                tmp_description="${description} ${mount_point}"
                last_arg_count=$(expr ${last_arg_count} + 2)
            else
                echo -e "Argument not found for option: ${opt}\nTaking using default value: ${mount_point}"
                last_arg_count=$(expr ${last_arg_count} + 1)
            fi
                ;;
        h)
            # Mongo Host flag found, set $mongo_host, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]
            then
                mongo_host="${OPTARG}"
                last_arg_count=$(expr ${last_arg_count} + 2)
            else
                echo -e "Argument not found for option: ${opt}\nUsing default value: ${mongo_host}"
                last_arg_count=$(expr ${last_arg_count} + 1)
            fi
            ;;
        p)
            # Mongo DBport flag found, set $mongo_dbport, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]
            then
                mongo_dbport="${OPTARG}"
                last_arg_count=$(expr ${last_arg_count} + 2)
            else
                echo -e "Argument not found for option: ${opt}\nUsing default value: ${mongo_dbport}"
                last_arg_count=$(expr ${last_arg_count} + 1)
            fi
            ;;
        U)
            # Username flag found, set $mongo_username, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]
            then
                mongo_username="${OPTARG}"
                last_arg_count=$(expr ${last_arg_count} + 2)
            else
                echo -e "Argument not found for option: ${opt}\nUsing default value: ${mongo_username}"
                last_arg_count=$(expr ${last_arg_count} + 1)
            fi
            ;;
        P)
            # Password flag found, set $mongo_password, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]
            then
                mongo_password="${OPTARG}"
                last_arg_count=$(expr ${last_arg_count} + 2)
            else
                echo -e "Argument not found for option: ${opt}\nUsing default value: ${mongo_password}"
                last_arg_count=$(expr ${last_arg_count} + 1)
            fi
            ;;
        l)
            # Log File flag found, set $logfile, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]
            then
                logfile="${OPTARG}"
                last_arg_count=$(expr ${last_arg_count} + 2)
            else
                echo -e "Argument not found for option: ${opt}\nUsing default value: ${logfile}"
                last_arg_count=$(expr ${last_arg_count} + 1)
            fi
            ;;
        d)
            # Description flag found, set $description, and increment last arg count
            if [[ "${OPTARG}" != "-"* ]]
            then
                tmp_description="${OPTARG} ${mount_point}"
                last_arg_count=$(expr ${last_arg_count} + 2)
            else
                echo -e "Argument not found for option: ${opt}\nUsing default value: ${description}"
                last_arg_count=$(expr ${last_arg_count} + 1)
            fi
            ;;
        D)
            # Debug flag found, set debug mode, and increment last arg count
            debug="true"
            last_arg_count=$(expr ${last_arg_count} + 1)
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done


################################## Execution ##################################
#
# Get volumes
get_vols "${@}"

# Test for Master
test_mongo_master


# Freeze the filesystem
freeze_xfs

# Flush FS cache
sync

# Backup volumes
backup_vols

# Wait for processes to finish
wait_on_pids

# Unfreeze the filesystem
unfreeze_xfs
