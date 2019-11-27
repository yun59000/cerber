#!/bin/bash

timestamp=`date "+%Y%m%d-%H%M%S"`


(echo "$timestamp launch installprogramm" 2>&1) >> "log.txt"
tail -1 "log.txt"
#retreive the user name who launch the sudo
if [ $SUDO_USER ]; then 
    user=$SUDO_USER
else 
    user=`whoami`
fi

installProgram () {
    if ! [ "$1" = "" ]; then
        #---------------------------
        if [ "$1" = "docker-machine" ]; then
            PKG_OK=$($1 -v)
            (echo "$timestamp Checking for somelib: x$PKG_OK x" 2>&1) >> "log.txt"
            tail -1 "log.txt"
        else
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
            (echo "$timestamp Checking for somelib: $PKG_OK" 2>&1) >> "log.txt"
            tail -1 "log.txt"
        fi
        
        if [ "" == "$PKG_OK" ]; then
            (echo "------------------INSTALL----------------------" 2>&1) >> "log.txt"
            (echo "$timestamp Installing package $1 ------------ " 2>&1) >> "log.txt"
            (echo "-------------------------------------------------" 2>&1) >> "log.txt"
            tail -3 "log.txt"
            if [ "$1" = "docker-machine" ] && ! [ "$PKG_OK" = "" ]; then
                base=https://github.com/docker/machine/releases/download/v0.14.0 && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && sudo install /tmp/docker-machine /usr/local/bin/docker-machine
            else
                apt-get --force-yes --yes install $1
            fi            
            if [ "" == "$PKG_OK" ]; then
                (echo "---------------------INSTALLED----------------------------" 2>&1) >> "log.txt"
                (echo "$timestamp package $1 installed Successfully--- " 2>&1) >> "log.txt"
                (echo "----------------------------------------------------------" 2>&1) >> "log.txt"
                tail -3 "log.txt"
            fi
        else
            (echo "----------------------------SKIPPED-----------------------" 2>&1) >> "log.txt"
            (echo "$timestamp package $1 already install ---Skipped " 2>&1) >> "log.txt"
            (echo "----------------------------------------------------------" 2>&1) >> "log.txt" 
            tail -3 "log.txt"
        fi
       
    fi
    
}

installProgram "docker"
installProgram "docker-compose"
installProgram "curl"
installProgram "wget"
installProgram "docker-machine"

#ajouter l'utilisateur courant au groupe docker
    #recuperer l'utilisateur courant pas le root

(echo "$timestamp user is : $user"  2>&1) >> "log.txt"
#check if docker group exist:
dockerInGroup=$(cat /etc/group |grep "docker")
userInDockerGroup=$(cat /etc/group |grep "docker" |grep "$user")
if [ "$dockerInGroup" = "" ]; then
    (echo "$timestamp the docker group does not exist"  2>&1) >> "log.txt"
    (echo "$timestamp docker group creation !"  2>&1) >> "log.txt"
    tail -2 "log.txt"
    groupadd docker
else
    (echo "$timestamp the docker group exist, no need to create" 2>&1) >> "log.txt"
    tail -1 "log.txt"
fi
if ! [ "$dockerInGroup" = "" ] && [ "$userInDockerGroup" = "" ]; then
    #check if user belong to docker group
    (echo "$timestamp the user $user does not belong to the docker group"  2>&1) >> "log.txt"
    (echo "$timestamp adding the user $user to the docker group"  2>&1) >> "log.txt"
    tail -2 "log.txt"
    usermod -aG docker $user
    (echo "$timestamp test after usermod docker" 2>&1) >> "log.txt"
    #adduser "$user" docker
    #refreshing the group file
    newgrp "docker" >> EOS
    (echo "$timestamp test after newgrp" 2>&1) >> "log.txt"
    EOS
    
else
    if [ "$(cat /etc/group |grep docker |grep $user )" ]; then
        (echo "$timestamp the user already belong to the docker group")
    else
        (echo "$timestamp an err occured in group affectation")
    fi
    
fi

#creation of a cerberus folder on the desktop
defaultIsDownloaded=false
pathToYML="/home/$user/cerberus/"
if ! [ -d "$pathToYML" ]; then
    mkdir "$pathToYML"
    cd "$pathToYML"

    wget https://raw.githubusercontent.com/cerberustesting/cerberus-source/master/docker/compositions/cerberus-glassfish-mysql/default-with-selenium.yml
    defaultIsDownloaded=true
else
    cd "$pathToYML"
    if ! [ -f "default-with-selenium.yml" ];then
        wget https://raw.githubusercontent.com/cerberustesting/cerberus-source/master/docker/compositions/cerberus-glassfish-mysql/default-with-selenium.yml
    defaultIsDownloaded=true
    fi    
fi

if [ "$defaultIsDownloaded" ];then
    echo "on est $(pwd)"
    if ! [ -f "docker-compose.yml" ];then
        mv default-with-selenium.yml docker-compose.yml
        (echo "$timestamp on créer le docker-compose a partir du default-selenium" 2>&1) >> "log.txt"
        tail -1 "log.txt"
    else
        (echo "$timestamp what to do ?"  2>&1) >> "log.txt"
        tail -1 "log.txt"
    fi
fi

(echo "$timestamp ready for launch"  2>&1) >> "log.txt"
(echo "ready ?" 2>&1) >> "log.txt"
tail -2 "log.txt"
read
if [ "$REPLY" = "y" ]; then
    (echo "$timestamp docker compose up" 2>&1) >> "log.txt"
    tail -1 "log.txt"
    docker-compose up
    # curl our verifier si le site est up
else
    (echo "$timestamp see ya !"  2>&1) >> "log.txt"
    tail -1 "log.txt"
fi