#!/usr/bin/env sh
# installs k3d, a k3s management utility. 
# Prereq: brew
export HOMEBREW_NO_AUTO_UPDATE=1
brew install k3d
# brew bundle dump --global --force
