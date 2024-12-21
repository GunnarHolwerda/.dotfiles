#!/bin/bash

echo -e

sudo apt update

## Install important helper tools
#### Status bar for i3
sudo apt-get install i3 i3status
#### Install brightnessctl for intel brightness ctrl (may need xbacklight instead if a different computer?)
sudo apt-get install brightnessctl

# NVIM 
## Fonts
mkdir ~/.fonts
wget -P ~/.fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/0xProto.zip 
unzip ~/.fonts/0xProto
rm -rf ~/.fonts/0xProto.zip
#### Manually rebuild the font cache
fc-cache -fc

## LuaRocks for LazyVim
sudo apt-get install luarocks
sudo apt-get install ripgrep fd-find


# Configuration
## Add user to video group so we can use brightnessctl without needing sudo everytime
sudo usermod -aG video $USER

## Install ZSH and Plugins
sudo apt install zsh -y
chsh -s $(which zsh)

## OhmyZSH
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

## Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Please reboot the computer to continue setting up"

