#!/bin/bash

# Netwatch
# Version 1.0
# Run netstat in a loop
# Jeff Hudson
# jeff.hudson@gmail.com

while [ 1 = 1 ];
do
	clear
	netstat -a -n -p tcp | grep -v \*\.\*
	sleep 5
done
