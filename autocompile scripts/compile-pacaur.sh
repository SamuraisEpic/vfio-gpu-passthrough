#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please make sure you're running this script as root, or with sudo"
  exit
fi

git clone https://aur.archlinux.org/pacaur.git
cd pacaur
makepkg -si
cd ..
rm -rf pacaur