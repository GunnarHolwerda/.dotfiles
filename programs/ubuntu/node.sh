#!/usr/bin/env bash

curl https://mise.run | sh

# Load MISE into current context
eval "$(mise activate zsh)"

mise install --global node@22.13.1

corepack enable
