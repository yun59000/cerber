#!/bin/bash

timestamp=`date "+%Y%m%d-%H%M%S"`
currentPath="$(pwd)"

(echo "${timestamp} launch installprogramm" 2>&1) >> "$currentPath/log.txt"
tail -1 "$currentPath/log.txt"
#retreive the user name who launch the sudo
if [ ${SUDO_USER} ]; then 
    user=${SUDO_USER}
else 
    user=`whoami`
fi

installProgram () {
    if ! [ "$1" = "" ]; then
        #---------------------------
        # if [ "$1" = "docker-machine" ]; then
        #     PKG_OK=$($1 -v)
        #     (echo "-----------CHECK--INSTALL---- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        #     (echo "${timestamp} Checking for somelib: x${PKG_OK} x" 2>&1) >> "$currentPath/log.txt"
        #     tail -2 "$currentPath/log.txt"
        # else
        #     PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
        #     (echo "-----------CHECK--INSTALL---- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        #     (echo "${timestamp} Checking for somelib: ${PKG_OK}" 2>&1) >> "$currentPath/log.txt"
        #     tail -2 "$currentPath/log.txt"
        # fi
        
        if [ "" == "${PKG_OK}" ]; then
            (echo "------------------INSTALL----------------------" 2>&1) >> "$currentPath/log.txt"
            (echo "${timestamp} Installing package $1 ------------ " 2>&1) >> "$currentPath/log.txt"
            (echo "------------------INSTALL----------------------" 2>&1) >> "$currentPath/log.txt"
            tail -3 "$currentPath/log.txt"
            if [ "$1" = "docker-machine" ] && ! [ "${PKG_OK}" = "" ]; then
                base=https://github.com/docker/machine/releases/download/v0.14.0 && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && sudo install /tmp/docker-machine /usr/local/bin/docker-machine
            else
                apt-get install -y $1
            fi            
            if [ "" == "${PKG_OK}" ]; then
                (echo "---------------------INSTALLED----------------------------" 2>&1) >> "$currentPath/log.txt"
                (echo "${timestamp} package $1 installed Successfully--- " 2>&1) >> "$currentPath/log.txt"
                (echo "---------------------INSTALLED----------------------------" 2>&1) >> "$currentPath/log.txt"
                tail -3 "$currentPath/log.txt"
            fi
        else
            (echo "----------------------------SKIPPED-----------------------" 2>&1) >> "$currentPath/log.txt"
            (echo "${timestamp} package $1 already install ---Skipped " 2>&1) >> "$currentPath/log.txt"
            (echo "----------------------------SKIPPED-----------------------" 2>&1) >> "$currentPath/log.txt" 
            tail -3 "$currentPath/log.txt"
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

(echo "${timestamp} user is : $user"  2>&1) >> "$currentPath/log.txt"
#check if docker group exist:
dockerInGroup=$(cat /etc/group |grep "docker")
userInDockerGroup=$(cat /etc/group |grep "docker" |grep "$user")
if [ "$dockerInGroup" = "" ]; then
    (echo "----------DOCKER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    (echo "${timestamp} the docker group does not exist"  2>&1) >> "$currentPath/log.txt"
    (echo "${timestamp} docker group creation !"  2>&1) >> "$currentPath/log.txt"
    (echo "----------DOCKER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    tail -4 "$currentPath/log.txt"
    groupadd docker
else
    (echo "----------DOCKER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    (echo "${timestamp} the docker group exist, no need to create" 2>&1) >> "$currentPath/log.txt"
    (echo "----------DOCKER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    tail -3 "$currentPath/log.txt"
fi
if ! [ "$dockerInGroup" = "" ] && [ "$userInDockerGroup" = "" ]; then
    #check if user belong to docker group
    (echo "----------USER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    (echo "${timestamp} the user $user does not belong to the docker group"  2>&1) >> "$currentPath/log.txt"
    (echo "${timestamp} adding the user $user to the docker group"  2>&1) >> "$currentPath/log.txt"
    (echo "----------USER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    tail -4 "$currentPath/log.txt"
    usermod -aG docker $user
    # (echo "${timestamp} test after usermod docker" 2>&1) >> "$currentPath/log.txt"
    #adduser "$user" docker
    #refreshing the group file
    newgrp "docker" >> EOS        
        (echo "----------REFRESH-GROUP-LIST CHECK--------------------" 2>&1) >> "$currentPath/log.txt"
    EOS
    
else
    if [ "$(cat /etc/group |grep docker |grep $user )" ]; then
        (echo "----------USER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} the user already belong to the docker group" 2>&1) >> "$currentPath/log.txt"
        (echo "----------USER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        tail -3 "$currentPath/log.txt"
    else
        (echo "----------USER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} an err occured in group affectation" 2>&1) >> "$currentPath/log.txt"
        (echo "----------USER-GROUP CHECK------ $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        tail -3 "$currentPath/log.txt"
    fi
    
fi

#creation of a cerberus folder on the desktop
defaultIsDownloaded=false
pathToYML="/home/$user/cerberus/"
if ! [ -d "$pathToYML" ]; then
    echo "test path OUT: $currentPath "
    mkdir "$pathToYML"
    cd "$pathToYML"
    
    (echo "----------Cerberus Folder Creation--- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    (echo "${timestamp} Cerberus Folder doesn't exist-- " 2>&1) >> "$currentPath/log.txt"
    (echo "${timestamp} --FOLDER CREATION--" 2>&1) >> "$currentPath/log.txt"
    (echo "----------Cerberus Folder Creation--- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
    tail -4 "$currentPath/log.txt"

    wget https://raw.githubusercontent.com/cerberustesting/cerberus-source/master/docker/compositions/cerberus-tomcat-mysql/docker-compose-with-selenium.yml
    defaultIsDownloaded=true
else
    echo "test path IN: $currentPath "
    cd "$pathToYML"
    if ! [ -f "docker-compose-with-selenium.yml" ];then
        (echo "----------default-with-selenium Download--- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} default-with-selenium.yml doesn't exist-- " 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} --we download it--" 2>&1) >> "$currentPath/log.txt"
        (echo "----------default-with-selenium Download--- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        tail -4 "$currentPath/log.txt"
        # docker/compositions/cerberus-tomcat-mysql/docker-compose-with-selenium.yml
        # wget https://raw.githubusercontent.com/cerberustesting/cerberus-source/master/docker/compositions/cerberus-tomcat-mysql/docker-compose.yml
        wget https://raw.githubusercontent.com/cerberustesting/cerberus-source/master/docker/compositions/cerberus-tomcat-mysql/docker-compose-with-selenium.yml
    defaultIsDownloaded=true
    else
        (echo "----------default-with-selenium Download--- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} default-with-selenium.yml already exist-- " 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} --no  needs to download it--" 2>&1) >> "$currentPath/log.txt"
        (echo "----------default-with-selenium Download--- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        tail -4 "$currentPath/log.txt"
        defaultIsDownloaded=true
    fi    
fi

if [ "$defaultIsDownloaded" ];then
    # echo "on est $(pwd)"
    if ! [ -f "docker-compose.yml" ];then
            (echo "----------docker-compose.yml-CHECK-- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
            (echo "${timestamp} docker-compose.yml doesn't exist-- " 2>&1) >> "$currentPath/log.txt"
            (echo "${timestamp} --Creating docker-compose.yml--" 2>&1) >> "$currentPath/log.txt"            
            tail -3 "$currentPath/log.txt"
        mv docker-compose-with-selenium.yml docker-compose.yml
        (echo "${timestamp} on créer le docker-compose a partir du default-selenium" 2>&1) >> "$currentPath/log.txt"
        (echo "----------docker-compose.yml-CHECK-- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        tail -2 "$currentPath/log.txt"
    else
        (echo "----------docker-compose.yml-CHECK-- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} docker-compose already exist-- " 2>&1) >> "$currentPath/log.txt"
        (echo "${timestamp} --no need to create--" 2>&1) >> "$currentPath/log.txt"
        (echo "----------docker-compose.yml-CHECK-- $1 ------------------" 2>&1) >> "$currentPath/log.txt"
        tail -4 "$currentPath/log.txt"        
    fi
fi

#add a control for launch
(echo "${timestamp} ready for launch"  2>&1) >> "$currentPath/log.txt"
(echo "ready ?" 2>&1) >> "$currentPath/log.txt"
tail -2 "$currentPath/log.txt"
read
if [ "$REPLY" = "y" ]; then
    (echo "${timestamp} docker compose up" 2>&1) >> "$currentPath/log.txt"
    tail -1 "$currentPath/log.txt"
    
    # &>/dev/null sets the command’s stdout and stderr to /dev/null instead of inheriting them from the parent process.
    # & makes the shell run the command in the background.
    # disown removes the “current” job, last one stopped or put in the background, from under the shell’s job control.

    docker-compose up & 
    disown -h

    # curl our verifier si le site est up
    nb_try=0
    while [ "$nb_try" -lt 30 ]
    do
       access=$(curl -sL -w "%{http_code}\\n" "http://127.0.0.1:8080" -o /dev/null)
            # -s = Silent cURL's output
            # -L = Follow redirects
            # -w = Custom output format
            # -o = Redirects the HTML output to /dev/null
       if [ "$access" = "200" ]
       then
            (echo "${timestamp} --------Cerberus is Up and Runnin---------" 2>&1 ) >> "$currentPath/log.txt"
            tail -1 "$currentPath/log.txt"
            nb_try=30
        else
            (echo "${timestamp} --------access $(( $nb_try * 10 )) sec -----average is 3min : 180 sec--please wait" 2>&1 ) >> "$currentPath/log.txt"
            tail -1 "$currentPath/log.txt"
            nb_try=$(( $nb_try + 1))
        fi
        sleep 10
    done
else
    (echo "${timestamp} see ya !"  2>&1) >> "$currentPath/log.txt"
    tail -1 "$currentPath/log.txt"
fi