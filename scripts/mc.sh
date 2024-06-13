#!/usr/bin/bash
# desc: minio s3 storage command line tool
mkdir -p ~/bin
sudo curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
   -o ~/bin/mc

sudo chmod a+x ~/bin/mc
# export PATH=$PATH:~/bin
# echo 'export PATH=$PATH:$HOME/minio-binaries/' >  ~/.bashrc