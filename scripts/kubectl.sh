#!/usr/bin/env sh
# desc: installs kubectl
# prereq: brew
# prereq: kubectl
brew install kubectl
# brew bundle dump --global --force
kubectl completion bash > ~/.kubectl_completion
# . ~/.kubectl_completion
cat << \EOF >> ~/.bashrc
if [ -f ~/.kubectl_completion ]; then
    . ~/.kubectl_completion
fi
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
