#! /bin/bash

# 设置集群机器的SSH免密登录

ssh-keygen -t rsa
ssh-copy-id root@kube-node1
ssh-copy-id root@kube-node2
ssh-copy-id root@kube-node3
