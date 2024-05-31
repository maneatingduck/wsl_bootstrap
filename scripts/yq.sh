#!/usr/bin/env sh
# desc: installs yq (yaml processor, similar to jq)
# Prereq: brew
export HOMEBREW_NO_AUTO_UPDATE=1
brew install yq
# brew bundle dump --global --force
