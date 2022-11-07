#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please make sure you're running this script as root, or with sudo"
  exit
fi

git clone https://github.com/duncanthrax/scream.git
cd scream
cd Recievers
cd unix
mkdir build && cd build
cmake ..
make
cd ..
cd ..
cd ..
cd ..
rm -rf scream
