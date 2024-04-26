#!/usr/bin/env sh
brew install kubernetes-cli
brew install k9s
brew install krew
if [ ! -f ~/Brewfile ]; then
cat << \EOF >> ~/Brewfile
tap "homebrew/bundle"
EOF
fi
cat << \EOF >> ~/Brewfile
"kubernetes-cli"
"k9s"
"krew"
EOF
kubectl completion bash >~/.kubectl_completion

cat << \EOF >> ~/.bashrc
if [ -f ~/.kubectl_completion ]; then
    . ~/.kubectl_completion
fi
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

# yes ''|brew cleanup --prune=all