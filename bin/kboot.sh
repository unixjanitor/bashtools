#!/bin/bash

# kboot.sh - Bootstrap a Chef node with Knife
# Version 1.0
# Shortcut for bootstrapping Chef nodes
# Jeff Hudson
# jeff.hudson@gmail.com

################################## Variables ##################################

my_fqdn="${1}"
my_key="~/aws/oregon.pem"
orig_my_key="${my_key}"
my_name="${2}"
my_user="root"
my_env="_default"

################################## Constants ##################################

# Set or instantiate variables that will not likely change
bold_on="\033[1m"
bold_off="\033[0m"
last_arg_count="1"

################################## Functions ##################################

# Print Help
print_help ()
{
	echo -e "${bold_on}Usage:${bold_off}\n\t${0} [-H] -h NODE_IP [-i IDENTITY_KEY] -n HOST_NAME"
    echo -e "\t${bold_on}-H${bold_off}\t\tPrint this Help"
    echo -e "\t${bold_on}-h IP${bold_off}\t\tRequired host FQDN or IP Address"
    echo -e "\t${bold_on}-i KEY${bold_off}\t\tOptional identity key [ ${orig_my_key} ]"
    echo -e "\t${bold_on}-n NAME${bold_off}\t\tRequired Chef node name"
}

################################### GetOpts ###################################

# Get the options
while getopts ":He:h:i:n:" opt
do
    case "${opt}" in
        H)
            # Help flag found, output help
            print_help
            exit 1
            ;;
        e)
            # Environment Flag found, set ${my_env}
            if [[ "${OPTARG}" != "-"* ]]; then
				my_env="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\nUsing default value: ${bold_on}[ ${my_env} ]${bold_off}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
            ;;
        h)
            # Host flag found, set ${my_fqdn}
            if [[ "${OPTARG}" != "-"* ]]; then
				my_ip="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\nUsing default value: ${bold_on}[ ${my_fqdn} ]${bold_off}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
            ;;
        i)
            # Identity Flag found, set ${my_key}
            if [[ "${OPTARG}" != "-"* ]]; then
                if [ "${OPTARG}" = "aws" ]; then
                    my_key="~/aws/oregon.pem"
                elif [[ "${OPTARG}" == "root" || "${OPTARG}" == "prod" ]]; then
                    my_key="~/prod/id_dsa"
                else
                    my_key="${OPTARG}"
                fi
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\nUsing default value: ${bold_on}[ ${my_key} ]${bold_off}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
            ;;
        n)
            # Name Flag found, set ${my_name}
            if [[ "${OPTARG}" != "-"* ]]; then
				my_name="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\nUsing default value: ${bold_on}[ ${my_name} ]${bold_off}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
            ;;
        *)
            # Anything else, output help
            print_help
            ;;
    esac
done

################################## CheckVars ##################################

if [ "${my_fqdn}" == "" ]; then
    print_help
    exit 1
fi

################################## Execution ##################################

if [ "${my_name}" == "" ]; then
    knife bootstrap "${my_ip}" -x root -i "${my_key}"
    #knife bootstrap "${my_fqdn}" -x "${my_user}" -i "${my_key}"
else
    knife bootstrap "${my_ip}" -x root -i "${my_key}" -N "${my_name}"
    #knife bootstrap "${my_fqdn}" -x "${my_user}" -i "${my_key}" -N "${my_name}"
fi

exit "${?}"
