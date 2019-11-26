#!/bin/bash

timestamp=`date "+%Y%m%d-%H%M%S"`


echo "launch installprogramm"
installProgram () {
    if ! [ "$1" = "" ]; then
        #---------------------------
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
        echo "Checking for somelib: $PKG_OK"
        if [ "" == "$PKG_OK" ]; then
            echo "------------------INSTALL----------------------"
            echo "$timestamp Installing package $1 ------------ "
            echo "-------------------------------------------------"
            if [ "$1" = "docker-machine" ]; then
                base=https://github.com/docker/machine/releases/download/v0.14.0 && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && sudo install /tmp/docker-machine /usr/local/bin/docker-machine
            else
                apt-get --force-yes --yes install $1
            fi            
            if [ "" == "$PKG_OK" ]; then
                echo "-------------------------------------------------"
                echo "$timestamp package $1 installed Successfully--- "
                echo "-------------------------------------------------"    
            fi
            
        fi
        #---------------------------
        if ! which $1 > /dev/null; then
            echo "------------------INSTALL----------------------"
            echo "$timestamp Installing package $1 ------------ "
            echo "-------------------------------------------------"
            if [ "$1" = "docker-machine" ]; then
                base=https://github.com/docker/machine/releases/download/v0.14.0 && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && sudo install /tmp/docker-machine /usr/local/bin/docker-machine
            else
                apt-get install $1
            fi            
            if which $1 > /dev/null; then
                echo "-------------------------------------------------"
                echo "$timestamp package $1 installed Successfully--- "
                echo "-------------------------------------------------"    
            fi
        else
            echo "-------------------------------------------------"
            echo "$timestamp package $1 already install ---Skipped "
            echo "-------------------------------------------------"
        fi
    fi
    
}

installProgram "docker"
#installProgram "docker-compose"
#installProgram "curl"
#installProgram "wget"