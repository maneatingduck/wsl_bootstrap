#!/usr/bin/env sh
# installs kubectl. Prereq: brew
brew install kubernetes-cli
# brew bundle dump --global --force
kubectl completion bash >~/.kubectl_completion

cat << \EOF >> ~/.bashrc
if [ -f ~/.kubectl_completion ]; then
    . ~/.kubectl_completion
fi
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
