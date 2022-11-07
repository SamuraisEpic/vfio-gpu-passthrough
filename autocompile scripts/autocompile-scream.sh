#!/bin/bash

git clone https://github.com/duncanthrax/scream.git
cd scream
cd Receivers
cd unix
mkdir build && cd build
cmake ..
make
cd ..
cd ..
cd ..
cd ..
rm -rf scream
