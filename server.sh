#!/bin/bash
echo $#
echo $@

# Check if ifconfig command exists
if which ifconfig &> /dev/null
then
    # ifconfig is available, use it
    ip=$(ifconfig en0 | grep -e inet | grep -v inet6 | awk '{print $2}')
else
    # ifconfig is not available, use ip
    ip=$(ip addr show dev eth0 | grep inet | grep -v inet6 | awk '{print $2}' | awk -F'/' '{print $1}')
fi
echo $ip

# Start hugo
hugo server -D --bind $ip --baseURL http://$ip:1313