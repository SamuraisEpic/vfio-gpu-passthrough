#!/bin/bash

git clone https://github.com/duncanthrax/scream.git
cd scream
cd Receivers
cd unix
mkdir build && cd build
cmake ..
make
echo "please enter the sudo password to copy scream to /bin to allow to to be executed from anywhere."
sudo cp scream /bin/
cd ..
cd ..
cd ..
cd ..
rm -rf scream
