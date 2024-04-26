#!/usr/bin/env sh
# get ssh keys
cd ~
mkdir -p ~/platform
cd ~/platform
git clone git@gitlab.intility.com:developer-infrastructure/platform-2.0/data-platform/data-api.git
git clone git@gitlab.intility.com:developer-infrastructure/platform-2.0/data-platform/infra.git
git clone git@gitlab.intility.com:developer-infrastructure/platform-2.0/data-platform/kubernetes-agent.git
cd ~/platform/infra