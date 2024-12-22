#/bin/bash
## Install important helper tools
sudo apt-get install curl

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

## Install nvim
version="v0.10.2"
if [ ! -z $NVIM_VERSION ]; then
    version="$NVIM_VERSION"
fi

echo "neovim version: \"$version\""

# neovim btw
if [ ! -d $HOME/neovim ]; then
    git clone https://github.com/neovim/neovim.git $HOME/neovim
fi

sudo apt -y install cmake gettext lua5.1 liblua5.1-0-dev

git -C ~/neovim fetch --all
git -C ~/neovim checkout $version

make -C ~/neovim clean
make -C ~/neovim CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make -C ~/neovim install
