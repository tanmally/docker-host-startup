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
echo "Waiting for Docker to start.."
sleep 5s
echo "Docker started.."

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

if [ ! -z "$domain" ]
then
docker run -d -p  172.30.1.1:53:53/udp -name skydns crosbymichael/skydns -nameserver 8.8.8.8:53 -domain $domain
docker run -i -v /var/run/docker.sock:/docker.sock -name skydock -link skydns:skydns crosbymichael/skydock -ttl 30 -environment prod -s /docker.sock -domain $domain
echo "Docker service dicovery domain : *.$domain " 
else
docker run -d -p 172.30.1.1:53:53/udp -name skydns crosbymichael/skydns -nameserver 8.8.8.8:53 -domain docker.bbytes.com
docker run -i -v /var/run/docker.sock:/docker.sock -name skydock -link skydns:skydns crosbymichael/skydock -ttl 30 -environment prod -s /docker.sock -domain docker.bbytes.com
echo "Docker service dicovery domain : *.docker.bbytes.com " 
fi


echo "Docker dns and service dicovery service started "



