+ 以root用户安装k8s
+ 可执行文件路径为/usr/local/bin
+ MASTER_VIP必须和节点IP在同一个网段

# 准备工作
事先设置好集群机器的主机名
hostnamectl set-hostname kube-node1
hostnamectl set-hostname kube-node2
hostnamectl set-hostname kube-node3
