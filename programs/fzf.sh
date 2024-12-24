#!/bin/bash

sudo apt-get install fd-find ripgrep

### Link fdfind to fd because thats how all the documentation uses it
ln -s $(which fdfind) ~/.local/bin/fd
