#! /bin/bash
sudo mkdir -p /usr/local/cert && sudo mkdir -p /home/k8s-install && cd /home/k8s-install
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
mv cfssl_linux-amd64  /usr/local/bin/cfssl
