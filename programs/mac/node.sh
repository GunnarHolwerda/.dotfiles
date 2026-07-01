#!/usr/bin/env bash

brew install mise

# Load MISE into current context
eval "$(mise activate zsh)"

mise install node@24

mise use -g node@24

corepack enable
