#!/bin/bash

if ((${EUID:-0} || "$(id -u)")); then
  (echo "You must have root priviledge to launch this script" 2>&1) >> "log.txt"
  tail -1 "log.txt"
else
  (echo "-------------Cerberus-INSTALL------------------" 2>&1) >> "log.txt" 
  tail -1 "log.txt"
  bash installprogram.sh
fi