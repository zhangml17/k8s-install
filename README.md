+ 以root用户安装k8s
+ 可执行文件路径为/usr/local/bin
+ MASTER_VIP必须和节点IP在同一个网段
+ VIP_IF 根据实际网卡情况设置

# 准备工作
事先设置好集群机器的主机名
+ hostnamectl set-hostname kube-node1
+ hostnamectl set-hostname kube-node2
+ hostnamectl set-hostname kube-node3

修改/etc/hosts文件,添加：
+ 192.168.100.31  kube-node1    kube-node1
+ 192.168.100.32  kube-node2    kube-node2
+ 192.168.100.33  kube-node3    kube-node3

从github克隆项目（将项目clone在/home目录下，代码中写死了），然后将预先下载好的组件的安装包拷贝到/k8s-install/packages文件夹下

最后执行 ./install-start.sh 即可

注意： sed -e 进行替换时 s/a/aaa/g 末尾要加g
