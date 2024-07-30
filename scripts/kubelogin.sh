#!/usr/bin/env sh
# desc: install kubelogin, an azure login plugin for az
# prereq: brew,az
export HOMEBREW_NO_AUTO_UPDATE=1
brew install Azure/kubelogin/kubelogin
# brew bundle dump --global --force
