#!/bin/bash

if ((${EUID:-0} || "$(id -u)")); then
  echo "You must have root priviledge to launch this script"
else
  echo "Hello, root."
  bash installprogram.sh
fi