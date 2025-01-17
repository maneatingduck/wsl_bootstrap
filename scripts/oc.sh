#!/usr/bin/bash
# desc: openshift command line tool
echo  get OC
cd ~
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz -O oc.tar.gz
tar -xzvf oc.tar.gz oc
sudo cp -fv oc /usr/local/bin/oc
sudo rm oc
cd ~
oc completion bash > ~/.oc_completion_bash

cat << \EOF >> ~/.bashrc
if [ -f ~/.oc_completion_bash ]; then
    . ~/.oc_completion_bash
fi
EOF
