#!/usr/bin/env sh
# desc: brew leaves a lot of cache, remove it all
y ''|brew cleanup -s --prune=all
rm -rf "$(brew --cache)"