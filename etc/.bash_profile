#
# Bash Profile for environments using Chef and AWS
#
# Jeff Hudson - jeff.hudson@gmail.com
#
# For sanity
export EDITOR="vi"
#
# Removed old dust bunnies
#
# ${PATH} Additions
#

# Path update for local scripts
export PATH="${PATH}:~/bin:/usr/local/Cellar/mtr/0.82/sbin"

# Environment additions

# Default AWS Command Line Support
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
alias ll='ls -l'
alias gti='git'

# Personal login/transfer
alias jssh='ssh -o USER=janitor'
alias jscp='scp -o USER=janitor'
alias gohome='ssh -o USER=janitor home'

# Windows login/transfer
alias wssh='ssh -o USER=administrator'
alias wscp='scp -o USER=administrator'

# Work login/transfer
alias ssh='ssh -o USER=jhudson'
alias scp='scp -o USER=jhudson'
alias rssh='ssh -i ~/prod/id_dsa -o USER=root'
alias rscp='scp -i ~/prod/id_dsa -o USER=root'
alias ossh='ssh -o USER=oracle'
alias oscp='scp -o USER=oracle'

# AWS
alias assh='ssh -i ~/aws/oregon.pem -o USER=root'
alias ascp='scp -i ~/aws/oregon.pem -o USER=root'
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
    alias assh="ssh"' -i ~/aws/norcal.pem -o USER=root'
    alias ascp="scp"' -i ~/aws/norcal.pem -o USER=root'
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
    alias assh="ssh"' -i ~/aws/oregon.pem -o USER=root'
    alias ascp="scp"' -i ~/aws/oregon.pem -o USER=root'
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
alias root='sudo su - root'

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
