#!/usr/bin/env bash

curl https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.0.1-0-ppa3/ghostty_1.0.1-0.ppa3_amd64_24.04.deb -L -o ghostty.deb
sudo dpkg -i ghostty.deb
rm ghostty.deb
