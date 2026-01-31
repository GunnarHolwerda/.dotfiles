#!/usr/bin/env bash

brew install mise

# Load MISE into current context
eval "$(mise activate zsh)"

mise install node@22

mise use -g node@22

corepack enable
