#!/bin/bash

# vmspawn.sh - Spawn Virtual Machine
# Version 1.0
# Script for deploying VM nodes and Chef bootstrapping
# Jeff Hudson
# jeff.hudson@gmail.com

################################## Variables ##################################

tmp_log="/tmp/vmspawn.log"

#### Dynamic Variables ####

# Role
if [[ "${1}" != "-"* ]]; then
    my_role="${1}"
else
    my_role="base"
fi

# Name
if [[ "${2}" != "-"* ]]; then
    my_name="${2}"
else
    my_name="GENERATE_NAME"
    generate_name
fi

#### Public Cloud 1 - AWS ####

# AWS Keys
aws_access_key="${AWS_SECRET_ACCESS_KEY}"
aws_secret_key="${AWS_SECRET_KEY}"
my_aws_ssh_key="oregon"
my_aws_ssh_key_loc="~/aws/oregon.pem"

# AWS Regions
my_aws_region="us-west-2"

# AWS Subnets
my_aws_subnet="subnet-f4d1aa9d"

# AWS VPC Security Group
my_aws_sec_group="sg-0a4d5166"

# AWS AMIs
#base_ami="ami-1444cc24"
base_ami="ami-0fc7573f"
web_ami="ami-4355c373"
cron_ami="ami-d36afce3"
gf_ami="ami-67168057"

# Default AMI
default_ami="${base_ami}"

# AWS Instance Types
aws_in_types=( `cat << EOF
    t1.micro
    m1.small
    m1.medium
    m1.large
    m1.xlarge
    m2.xlarge
    m2.2xlarge
    m2.4xlarge
    m3.xlarge
    m3.2xlarge
    c1.medium
    c1.xlarge
    hi1.4xlarge
    hs1.8xlarge
EOF`
)

#### Public Cloud 2 ####

#### Private Cloud 1 ####

#### Chef ####

# Chef Environments
chef_envs=( `cat << EOF
    _default
    dev
    production
EOF`
)

#### Site ####

# Roles
roles=( `cat << EOF
    base
    web
    api
    ws
    notify
    solar
    sym
    cron
    gf
    glassfish
    hadoop
    mongodb
EOF`
)

#### Environment ####

# Cloud
my_cloud="aws"

# User
my_user="root"

# Access Key
my_ssh_key="${my_aws_ssh_key_loc}"

# Image
my_image="${default_ami}"

# Instance Type
my_inst="${aws_in_types[2]}"

# Role
my_role="${roles[0]}"

# Chef Environment
my_env="${chef_envs[0]}"

# Name
my_name="GENERATE_NAME"

################################## Constants ##################################

# Set or instantiate variables that will not likely change
bold_on="\033[1m"
bold_off="\033[0m"
last_arg_count="1"
my_date=$(date -u +%Y-%m-%dT%TZ)

################################## Functions ##################################

# Print Help
print_help ()
{
	echo -e "${bold_on}Usage:${bold_off}\n\t${0} [-H] [-a IMAGE_NAME] [-i IDENTITY_KEY] [-n] [NAME] [-r] ROLE [-d]"
    echo -e "\t${bold_on}-H${bold_off}\t\tPrint this Help"
    echo -e "\t${bold_on}-d${bold_off}\t\tSet Debug output"
    echo -e "\t${bold_on}-a IMAGE${bold_off}\tSet the Image name [ ${my_image} ]"
    echo -e "\t${bold_on}-i KEY${bold_off}\t\tOptional identity key [ ${my_ssh_key} ]"
    echo -e "\t${bold_on}-I TYPE${bold_off}\t\tOptional instance type [ ${my_inst} ]"
    echo -e "\t${bold_on}-N NAME${bold_off}\t\tChef node name - Default: ${bold_on}[ ROLE+UNIX_EPOCH ]${bold_off}"
    echo -e "\t${bold_on}-r ROLE${bold_off}\t\tServer Role - Default: ${bold_on}[ ${my_role} ]${bold_off}"
}

# Print debug output
print_debug ()
{
    if [ "${debug}" == "true" ]; then
        echo -e "${bold_on}${1}${bold_off}"
    fi
}

# Generate a name based on the role
generate_name ()
{
    if [ "${my_name}" == "GENERATE_NAME" ]; then
        my_epoch=$(date +%s)
        my_name="${my_role}-${my_epoch}_${my_env}"
    fi
}

# Spawn VM and capture the output in an array
spawn_vm ()
{
    if [ "${my_cloud}" == "aws" ]; then
        echo knife ec2 server create -r "role[${my_role}]" -I "${my_image}" -f "${my_inst}" -g "${my_aws_sec_group}" -x "${my_user}" -A "${aws_access_key}" -K "${aws_secret_key}" --region "${my_aws_region}" -s "${my_aws_subnet}" -S "${my_aws_ssh_key}" -i "${my_aws_ssh_key_loc}" -N "${my_name}" >> "${tmp_log}"
        knife ec2 server create -r "role[${my_role}]" -I "${my_image}" -f "${my_inst}" -g "${my_aws_sec_group}" -x "${my_user}" -A "${aws_access_key}" -K "${aws_secret_key}" --region "${my_aws_region}" -s "${my_aws_subnet}" -S "${my_aws_ssh_key}" -i "${my_aws_ssh_key_loc}" -N "${my_name}"
    elif [ "${my_cloud}" == "public2" ]; then
        echo "Cloud ${my_cloud} not yet supported"
        exit 1
    elif [ "${my_cloud}" == "private1" ]; then
        echo "Cloud ${my_cloud} not yet supported"
        exit 1
    else
        echo "Cloud ${my_cloud} not yet supported"
        exit 1
    fi
}

################################### GetOpts ###################################

# Get the options
while getopts ":Ha:de:i:I:N:r:" opt
do
    case "${opt}" in
        H)
            # Help flag found, output help
            print_help
            exit 1
            ;;
        a)
            # AMI flag found, set my_image, increment last arg count
            if [[ "${OPTARG}" != "-"* ]]; then
				my_image="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\nUsing default value: ${bold_on}[ ${my_inst} ]${bold_off}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
            ;;
		d)
			# Debug flag found, set debug mode, and increment last arg count
			debug="true"
			last_arg_count=$(expr ${last_arg_count} + 1)
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
        i)
            # Identity Flag found, set identity
            if [[ "${OPTARG}" != "-"* ]]; then
                if [ "${OPTARG}" = "aws" ]; then
                    my_ssh_key="~/aws/oregon.pem"
                elif [[ "${OPTARG}" == "root" || "${OPTARG}" == "prod" ]]; then
                    my_ssh_key="~/prod/id_dsa"
                else
                    my_ssh_key="${OPTARG}"
                fi
				my_ssh_key="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\n"
                print_help
                exit 1
			fi
            ;;
        I)
            # Instance Flag found, set instance type
            
            if [[ "${OPTARG}" != "-"* ]]; then
				my_inst="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\nUsing default value: ${bold_on}[ ${my_inst} ]${bold_off}"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
            ;;
        N)
            # Name Flag found, set name
            if [[ "${OPTARG}" != "-"* ]]; then
				my_name="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
                my_name="GENERATE_NAME"
				echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\nName generation requested"
				last_arg_count=$(expr ${last_arg_count} + 1)
			fi
            ;;
        r)
            # Role Flag found, set role
            if [[ "${OPTARG}" != "-"* ]]; then
				my_role="${OPTARG}"
				last_arg_count=$(expr ${last_arg_count} + 2)
			else
                echo -e "Argument not found for option: ${bold_on}${opt}${bold_off}\n"
                print_help
                exit 1
			fi
            ;;
        *)
            # Anything else, output help
            print_help
            ;;
    esac
done

################################## Execution ##################################

# Check for name generation request
generate_name

# Spawn a VM in Cloud
spawn_vm

