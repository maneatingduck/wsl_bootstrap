#!/usr/bin/bash
# desc: minio s3 storage command line tool
sudo curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o /usr/local/bin/mc
  # -o $HOME/minio-binaries/mc

# chmod +x $HOME/minio-binaries/mc
# export PATH=$PATH:$HOME/minio-binaries/