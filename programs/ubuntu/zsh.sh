#!/bin/bash

sudo apt-get install -y zsh zsh-autosuggestions zsh-syntax-highlighting
chsh -s $(which zsh)

mkdir -p ~/.local/bin
