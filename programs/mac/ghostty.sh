#!/usr/bin/env bash

brew install --cask ghostty

defaults write com.mitchellh.ghostty NSUserKeyEquivalents -dict-add "Hide Ghostty" "^~\$@h"
