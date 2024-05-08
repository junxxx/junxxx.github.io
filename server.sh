#!/bin/bash

# Ip of localhost
ip=192.168.0.121

# Start hugo
hugo server -D --bind $ip --baseURL http://$ip:1313