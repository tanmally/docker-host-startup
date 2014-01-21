docker-host-startup
===================

The list of files to start in docker host to init the docker correctly to discover service inside docker containers

Command to run with domain name as example.com

    ./docker-init.sh example.com
    
Command to run with default domain bbytes.com

    ./docker-init.sh


This script starts docker on bridge0 with specific ip address. This ip address is added to skydns server and the skydock service - container service discovery code is started .

The container can be accessed using the domain pattern 

    <service>.docker.example.com
    <service>.docker.bbytes.com
    
The service value is decided from docker image name for eg it will be 'tomcat' for image bbytes/tomcat or 'base' for image base     

    tomcat.docker.example.com
