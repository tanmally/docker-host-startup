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
docker run -d -v /var/run/docker.sock:/docker.sock -name skydock -link skydns:skydns crosbymichael/skydock -ttl 30 -environment docker -s /docker.sock -domain $domain
domainname="<service>.$domain"
echo "Docker service dicovery domain : *.$domain " 
else
docker run -d -p 172.30.1.1:53:53/udp -name skydns crosbymichael/skydns -nameserver 8.8.8.8:53 -domain bbytes.com
docker run -d -v /var/run/docker.sock:/docker.sock -name skydock -link skydns:skydns crosbymichael/skydock -ttl 30 -environment docker -s /docker.sock -domain bbytes.com
domainname="<service>.docker.bbytes.com"
echo "Docker service dicovery domain : *.docker.bbytes.com " 
fi


echo "Docker dns and service dicovery service started "

echo 'nameserver 172.30.1.1' >> /etc/resolvconf/resolv.conf.d/head
sudo ifdown --exclude=lo -a && sudo ifup --exclude=lo -a
echo 'Docker host machine dns name server is updated to dicover service based on domain address'
echo "try pinging the $domainname"
echo "the value of <service> is the second part of image name for eg: it is 'tomcat' for image with name 'bbytes/tomcat'"






