#!/bin/bash

set -x
cd ~
yum install -y wget
gofile=go1.23.4.linux-arm64.tar.gz
wget https://go.dev/dl/$gofile

if [ -d "/usr/local/go" ]; then 
  rm -r /usr/local/go
fi
tar -C /usr/local -xzf $gofile
ln -s /usr/local/go/bin/go /usr/local/bin/go # for login shell finding go

set +x
