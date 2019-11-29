#!/bin/bash


timestamp=`date "+%Y%m%d-%H%M%S"`
currentPath="$(pwd)"

if ((${EUID:-0} || "$(id -u)")); then
  (echo "${timestamp} You must have root priviledge to launch this script" 2>&1) >> "${currentPath}/log.txt"
  tail -1 "${currentPath}/log.txt"
else
  (echo "-------------------------Cerberus-INSTALL------------------" 2>&1) >> "${currentPath}/log.txt" 
  tail -1 "${currentPath}/log.txt"
  bash installprogram.sh
fi