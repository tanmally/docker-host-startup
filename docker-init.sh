#!/bin/bash
echo "Setting up docker with bridge0 so that the ip pattern of docker images start from 172.30.1.2"
service docker stop
ip link delete bridge0
ip link add bridge0 type bridge
ip addr add 172.30.1.1/24 dev bridge0
ip link set bridge0 up
cp -f docker.conf /etc/init/
echo "Docker container dns 172.30.1.1"
echo "Starting Docker"
service docker start
