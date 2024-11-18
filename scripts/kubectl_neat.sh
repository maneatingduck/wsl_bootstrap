#!/usr/bin/env sh
# desc: installs the neat plugin for kubectl
# prereq: krew
# prereq: kubectl

kubectl krew install neat
# brew bundle dump --global --force
