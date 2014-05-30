#
# Bash Profile for environments with complex directoy paths
#
# Jeff Hudson - jeff.hudson@gmail.com
#
# For sanity
export EDITOR="vi"
#
#
#### Locate Binaries

# Add commands as you find helpful

cmds=$( cat << EOF
        ln
        ls
        whoami
        ssh
        scp
        sudo
EOF
)

# List locations to search for commands followed by '\'
# Add new locations as they become known

locs=$( cat << EOF
            /bin
            /usr/bin
            /usr/local/bin
            /opt/bin
EOF
)

#
# From here to the Environment Updates should not need customization
#

# Loop through commands to find in ${cmds}
for testcmd in ${cmds}
do
    # Clear ${mycmd}
    mycmd=""

    # Unset aliases
    unalias "${testcmd}" >> /dev/null 2>&1
    
    # Execute ${testcmd} in the current ${PATH}
    "${testcmd}" >> /dev/null 2>&1
    
    # Test exit status of ${testcmd}
    if [ "${?}" -ne "127" ]; then
        # If exit status is NOT 127, set the command location
        # Since we have some sort of ${PATH}, we can try using which
        tmpcmd=$(which "${testcmd}")
        if [ "${?}" -ne "127" ]; then
            # We found which, and should have a location of ${testcmd}
            mycmd="${tmpcmd}"
        fi
    fi
    
    # Test to see if ${mycmd} is set, meaning a command was found
    if [ "${mycmd}" == "" ]; then
        # Loop through locations to look in ${locs}
        for cmdloc in ${locs}
        do
            # Attempt to execute the command with no options
            "${cmdloc}"/"${testcmd}" >> /dev/null 2>&1
            
            # Return code 127 means the file was not found
            if [ "${?}" -ne "127" ]; then
                # If the command was found, set $mycmd and break out
                mycmd="${cmdloc}"/"${testcmd}"
                break
            fi
        done

        # Test to see if ${mycmd} is set, meaning a command was found
        if [ "${mycmd}" == "" ]; then
            # If ${mycmd} was not set, look in the current ${PATH}
            "${testcmd}" >> /dev/null 2>&1
            if [ "${?}" -eq "127" ]; then
                # If exit status is 127 then the command was not found
                echo "Cannot locate '${testcmd}'. Human intevention required"
            else
                # If exit status is NOT 127, set the command location
                mycmd="${testcmd}"
            fi
        fi
    fi
    eval "my_${testcmd}"="${mycmd}" >> /dev/null 2>&1
done

#### Environment Updates 

#
# ${HOME} correction
#

# Remove spaces in ${HOME}

"${my_whoami}" | grep ' ' >> /dev/null
if [ "${?}" -eq "0" ]; then
    # Save the original ${HOME}
	export ORIG_HOME="${HOME}"
	export HOME=$(echo "${HOME}" | sed 's/ //g')
    
	if [ ! -h "${HOME}" ]; then
		echo "Creating simple home link..."
		name=$("${my_whoami}" | sed 's/ //g')
        # Requires sudo
		${my_sudo} ${my_ln} -s "${ORIG_HOME}" "${HOME}"
	fi
	cd ${HOME}
fi

#
# ${PATH} Additions
#

# Path update for local scripts
export PATH="${PATH}:~/bin:/usr/local/Cellar/mtr/0.82/sbin"

# Environment additions

# AWS Command Line Support
export EC2_HOME="${HOME}/.ec2"
export AWS_ELB_HOME="${HOME}/.elb"
export PATH="${PATH}:${EC2_HOME}/bin:${AWS_ELB_HOME}/bin"
export AWS_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXX"
export AWS_SECRET_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export AWS_CREDENTIAL_FILE="${AWS_ELB_HOME}/aws_elb_credential_file"
export EC2_URL="https://ec2.us-west-2.amazonaws.com"
export AWS_ELB_URL="https://elasticloadbalancing.us-west-2.amazonaws.com"
export JAVA_HOME="/usr/java/jdk1.7.0"

# Cloudmanager
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_KEY}"
export CM_KNIFE="~/.chef/knife.rb"

#### Aliases
alias ll="${my_ls}"' -l'
alias gti="${my_git}"

# Personal login/transfer
alias jssh="${my_ssh}"' -o USER=janitor'
alias jscp="${my_scp}"' -o USER=janitor'
alias gohome="${my_ssh}"' -o USER=janitor home'

# Windows login/transfer
alias wssh="${my_ssh}"' -o USER=administrator'
alias wscp="${myscp}"' -o USER=administrator'

# Work login/transfer
alias ssh="${my_ssh}"' -o USER=jhudson'
alias scp="${my_scp}"' -o USER=jhudson'
alias rssh="${my_ssh}"' -i ~/prod/id_dsa -o USER=root'
alias rscp="${my_scp}"' -i ~/prod/id_dsa -o USER=root'
alias ossh="${my_ssh}"' -o USER=oracle'
alias oscp="${my_scp}"' -o USER=oracle'

# AWS
alias assh="${my_ssh}"' -i ~/aws/oregon.pem -o USER=root'
alias ascp="${my_scp}"' -i ~/aws/oregon.pem -o USER=root'
alias clssh='cat ~/.ssh/known_hosts | sed "/10.36/d" > ~/.ssh/tmp_known_hosts;mv ~/.ssh/tmp_known_hosts ~/.ssh/known_hosts'

#####
# Functions

norcal ()
{
# AWS Command Line Support
    export EC2_HOME="${HOME}/.ec2"
    export AWS_ELB_HOME="${HOME}/.elb"
    export PATH="${PATH}:${EC2_HOME}/bin:${AWS_ELB_HOME}/bin"
    export AWS_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXX"
    export AWS_SECRET_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    export AWS_CREDENTIAL_FILE="${AWS_ELB_HOME}/aws_elb_credential_file"
    export EC2_URL="https://ec2.us-west-1.amazonaws.com"
    export AWS_ELB_URL="https://elasticloadbalancing.us-west-1.amazonaws.com"
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.7.0_21.jdk/Contents/Home"
    alias assh="${my_ssh}"' -i ~/aws/norcal.pem -o USER=root'
    alias ascp="${my_scp}"' -i ~/aws/norcal.pem -o USER=root'
    alias clssh='cat ~/.ssh/known_hosts | sed "/10.46/d" > ~/.ssh/tmp_known_hosts;cat ~/.ssh/tmp_known_hosts | sed "/-dr1/d" > ~/.ssh/tmp2_known_hosts;mv ~/.ssh/tmp2_known_hosts ~/.ssh/known_hosts'
}

oregon ()
{
# AWS Command Line Support
    export EC2_HOME="${HOME}/.ec2"
    export AWS_ELB_HOME="${HOME}/.elb"
    export PATH="${PATH}:${EC2_HOME}/bin:${AWS_ELB_HOME}/bin"
    export AWS_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXX"
    export AWS_SECRET_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    export AWS_CREDENTIAL_FILE="${AWS_ELB_HOME}/aws_elb_credential_file"
    export EC2_URL="https://ec2.us-west-2.amazonaws.com"
    export AWS_ELB_URL="https://elasticloadbalancing.us-west-2.amazonaws.com"
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.7.0_21.jdk/Contents/Home"
    alias assh="${my_ssh}"' -i ~/aws/oregon.pem -o USER=root'
    alias ascp="${my_scp}"' -i ~/aws/oregon.pem -o USER=root'
    alias clssh='cat ~/.ssh/known_hosts | sed "/10.36/d" > ~/.ssh/tmp_known_hosts;cat ~/.ssh/tmp_known_hosts | sed "/-dr1/d" > ~/.ssh/tmp2_known_hosts;mv ~/.ssh/tmp2_known_hosts ~/.ssh/known_hosts'
}

awsdin ()
{
    if [[ "${1}" != "i-"* ]]; then
        aws ec2 describe-instances --instance-ids i-"${1}"
    else
        aws ec2 describe-instances --instance-ids "${1}"
    fi
}

####
# Chef

esl ()
{
	if [ "${1}" ]; then
		knife ec2 server list | grep "${1}"
	else
		knife ec2 server list
	fi
}

cookup ()
{
    knife cookbook upload "${1}"
}

cookdown ()
{
    knife cookbook download -N -d ~/chef_backup "${1}"
}


# Privilege
alias root="${my_sudo} ${my_su}"' su - root'

# Cloudmanager
cm ()
{
	cd ~/github/cloudmanager >> /dev/null 2>&1
	if [ -n "${3}" ]; then
        	RUBYLIB=lib ~/github/cloudmanager/bin/cloudmanager -y ~/github/ops-misc/cloudmanager-config/"${1}".yaml -d "${2}" "${3}"
	else
        	RUBYLIB=lib ~/github/cloudmanager/bin/cloudmanager -y ~/github/ops-misc/cloudmanager-config/"${1}".yaml -d "${2}"
	fi
	cd - >> /dev/null 2>&1
}

#### Prompt
PS1='\u@\h:\w> '
