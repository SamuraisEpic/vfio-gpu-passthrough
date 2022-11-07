#!/bin/bash

git clone https://aur.archlinux.org/pacaur.git
cd pacaur
makepkg -si
cd ..
rm -rf pacaur