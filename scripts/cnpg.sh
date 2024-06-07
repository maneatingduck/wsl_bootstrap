#!/usr/bin/env sh
# desc: installs the cnpg plugin for kubectl
# prereq: krew
# prereq: kubectl

kubectl krew install cnpg
# brew bundle dump --global --force
