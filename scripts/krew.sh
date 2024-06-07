#!/usr/bin/env sh
# desc: install krew, a kubektl plugin manager
# Prereq: brew
export HOMEBREW_NO_AUTO_UPDATE=1
brew install krew
# brew bundle dump --global --force
 export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
 echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
 
