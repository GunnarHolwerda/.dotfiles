#!/usr/bin/env bash

brew install nvm

## Load NVM into current context
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

nvm install --lts
nvm alias default node

corepack enable pnpm
