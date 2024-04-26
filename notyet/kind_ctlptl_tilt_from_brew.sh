#!/usr/bin/env sh
echo install tilt and ctlptl
brew install tilt-dev/tap/ctlptl tilt kind

if [ ! -f ~/Brewfile ]; then
cat << \EOF >> ~/Brewfile
tap "homebrew/bundle"
EOF
fi
cat << \EOF >> ~/Brewfile
"tilt-dev/tap/ctlptl"
"kind"
"tilt"
EOF
# yes ''|brew cleanup --prune=all