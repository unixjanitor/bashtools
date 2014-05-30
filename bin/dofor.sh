#!/bin/bash

# dofor.sh - Do For (each host)
# Version 1.0
# command script loop for large environments
# Jeff Hudson
# jeff.hudson@gmail.com

################################## Variables ##################################

hosts="nodelist"
user="jhudson"
host_base="hostlist-"
host_root="${HOME}/hosts/${host_base}"

################################## Constants ##################################

# Set or instantiate variables that will not likely change
bold_on="\033[1m"
bold_off="\033[0m"
last_arg_count="1"
will_sleep=
sleep_sec="10"
timer="0"
my_timer=
sleep_time=
parallel=
host_list=
command=
password=
mypassword=
query=
nq_cmd_str=
q_cmd_str=
mylastarg="0"
debug=
key=
pad="2"

################################## Functions ##################################

# Get the command
get_command ()
{
    # Test to see if $command is set, if not take the last argument
    if [ ! "${command}" ]; then
        # Get the last argument
        mylastarg=$(eval echo \${$last_arg_count})
        command="${mylastarg}"
        print_debug "DEBUG:COMMAND_INFUNCTION: ${command}"
    fi

    # Add escape slashes before any semi-colons
    command=$(echo "${command}" | sed 's/\;/\\\;/g')
}

# Print debug output
print_debug ()
{
    if [ "${debug}" == "true" ]; then
        echo -e "${bold_on}${1}${bold_off}"
    fi
}

# Check for debug output
check_debug ()
{
    if [ "${debug}" == "true" ]; then
        print_debug "DEBUG:COMMAND:LASTARG:${mylastarg}:COMMAND=${command}"
        print_debug "DEBUG:ARGUMENTARRAY: ${@}"
        for arg in $(eval echo {1..${#}}); do
            print_debug "${arg}:\t $(eval echo \${$arg})"
        done
    fi
}

# Check for password requirement
check_passwd ()
{
	if [ "${password}" == "true" ]; then
		if [ "${mypassword}" == "" ]; then
			query="true"
			get_passwd
		fi
        print_debug  "DEBUG:PASSWORD: ${mypassword}"
	fi
}

# Get password
get_passwd ()
{
	# Check for query flag and get the password
	if [ "${query}" == "true" ]; then
		# Query for the password if needed
		read -s -p "Enter Password: " mypassword
		echo
	fi
}

# Get the commandline to use
get_cmdline ()
{
    cmd_str=\$\{command\}\ \$\{host\}
}

# Get Hosts function: get_hosts ${hosts}
get_hosts ()
{
    myhost_root=$(echo ${host_root} | sed 's/ /?/')
    print_debug "DEBUG:HOSTS-0:${myhost_root}${hosts}:${host_list}"
	for host in ${hosts}
	do
        print_debug  "DEBUG:HOSTS-${host}:${myhost_root}${hosts}:${host_list}"
		if [ -f "./${host_base}${host}" ]; then
			host_list="${host_list} $(cat ./${host_base}${host})"
            print_debug "DEBUG:HOSTS-1:${myhost_root}:${myhost_root}${hosts}:${host_list}"
		elif [ -f "${host_root}${host}" ]; then
			host_list="${host_list} $(cat ${myhost_root}${host})"
            print_debug "DEBUG:HOSTS-2:${host_root}:${myhost_root}${host}:${host_list}"
		else
			host_list="${host_list} ${host}"
            print_debug "DEBUG:HOSTS-3:${myhost_root}:${myhost_root}${host}:${host_list}"
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

# Interaction gate function
interact_gate ()
{
	proceed="false"
	# Wait for user input before proceding to the next host
	while [ "${proceed}" != "true" ]
	do
		read -p "Proceed?: " interact_answer
		echo
		case "${interact_answer}" in
			[yY] | [yY][eE][sS])
				proceed="true"
				;;
			[nN] | [nN][oO])
				proceed="false"
				;;
			*)
				echo -e "Please answer ${bold_on}Yes${bold_off}/${bold_on}No${bold_off}\n"
				;;
		esac
	done
}

# Command Loop function: host_loop ${command}
command_loop ()
{
	for host in ${host_list}
	do
		echo -e "## ${bold_on}${host}${bold_off} ## "
		# If running in parallel, execute on all hosts via forking
		if [ "${parallel}" == "true" ]; then
			( eval "${cmd_str}" ) &
		else
			eval "${cmd_str}"
			# If $sleep_sec is set, then set sleep cycle
			if [ "${will_sleep}" == "true" ]; then
				sleep_cycle "${sleep_sec}"
			fi
			if [ "${interact}" == "true" ]; then
				interact_gate
			fi
		fi
        count="1"
        while [ "${count}" -lt "${pad}" ]; do
            echo -e ""
            count=$(expr "${count}" + 1)
        done
	done
}

# Print Help
print_help ()
{
	echo -e "${bold_on}Usage:${bold_off}\n\t${0} [-H] [-u USER] [-h HOST|HOST_GROUP|HOST_FILE] [-s SLEEP_SEC(R for Random)] [-P] [-p [PASSWORD]] [-e ECHOPADDING] [-i] [-d] [-r] [-c] ${bold_on}COMMAND${bold_off}\n"
	echo -e "\t${bold_on}-c${bold_off}\tPass the command to execute"
	echo -e "\t${bold_on}-d${bold_off}\tSet Debug output"
    echo -e "\t${bold_on}-e${bold_off}\tNumber of lines to echo pad output"
	echo -e "\t${bold_on}-H${bold_off}\tPrint this Help"
	echo -e "\t${bold_on}-P${bold_off}\tExecute command in parallel"
	echo -e "\t${bold_on}-i${bold_off}\tWait for user interaction to continue"
}

################################### GetOpts ###################################

# Get the options
while getopts ":u:h:c:e:s:Pp:Hrid" opt
do
	case "${opt}" in
		H)
			# Help flag found, output help
			print_help
			exit 1
			;;
		u)
			# User flag found, set $user, and increment last arg count
			if [[ "${OPTARG}" != "-"* ]]; then
				user="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${opt}\nTaking using default value: ${user}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
			;;
		h)
			# Host flag found, set $hosts, and increment last arg count
			if [[ "${OPTARG}" != "-"* ]]; then
				hosts="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${opt}\nUsing default value: ${hosts}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
			;;
		c)
			# Command flag found, set $command, and increment last arg count
			if [[ "${OPTARG}" != "-"* ]]; then
				command="${OPTARG}"
				parallel="false"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${opt}\nUsing default final argument as COMMAND"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
			;;
		s)
			# Sleep flag found, set $sleep_sec, and increment last arg count
			if [[ "${OPTARG}" != "-"* ]]; then
				will_sleep="true"
				sleep_sec="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${opt}\nUsing default value: ${sleep_sec}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
			;;
		P)
			# Parallel flag found, set $parallel, and increment last arg count
			parallel="true"
			last_arg_count=$(expr ${last_arg_count} + 1)
			;;
		p)
			# Password flag found, set the passwd
			if [[ "${OPTARG}" != "-"* ]]; then
				password="true"
				mypassword="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
				print_debug "DEBUG1:PASSWORD:LASTARG ${last_arg_count}"
			else
				echo -e "Argument not found for option: ${opt}"
				last_arg_count=$(expr ${last_arg_count} + 1)
				print_debug "DEBUG2:PASSWORD:LASTARG ${last_arg_count}"
			fi
			;;
		i)
			# Interaction flag found, will wait for user input to continue, and increment last arg count
			interact="true"
			last_arg_count=$(expr ${last_arg_count} + 1)
			;;
		d)
			# Debug flag found, set debug mode, and increment last arg count
			debug="true"
			last_arg_count=$(expr ${last_arg_count} + 1)
			;;
        e)
            # Echo Pad flag found, set pad, and increment last arg count
			if [[ "${OPTARG}" != "-"* ]]; then
				pad="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${opt}\nUsing default value: ${pad}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
			;;
	esac
done

################################## Execution ##################################

# Get the command
get_command "${@}"

# Check for debug output flag
check_debug "${@}"

# Check for password requirement
check_passwd

# Get my command line
get_cmdline

# Get complete host list
get_hosts

# Loop through hosts and execute command
command_loop
