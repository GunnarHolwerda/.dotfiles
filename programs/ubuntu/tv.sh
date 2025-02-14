#!/usr/bin/env bash

VER=`curl -s "https://api.github.com/repos/alexpasmantier/television/releases/latest" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/'`

pushd /tmp
curl -LO https://github.com/alexpasmantier/television/releases/download/$VER/tv-$VER-linux-x86_64.tar.gz
curl -LO https://github.com/alexpasmantier/television/releases/download/$VER/tv-$VER-linux-x86_64.sha256
tar -xzvf tv-$VER-linux-x86_64.tar.gz
cp tv $HOME/.local/bin/
popd
