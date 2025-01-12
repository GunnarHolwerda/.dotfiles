#!/usr/bin/env bash

sudo apt-get install -y bat

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
