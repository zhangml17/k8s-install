+ 以root用户安装k8s
+ 可执行文件路径为/usr/local/bin
+ MASTER_VIP必须和节点IP在同一个网段

# 准备工作
事先设置好集群机器的主机名
+ hostnamectl set-hostname kube-node1
+ hostnamectl set-hostname kube-node2
+ hostnamectl set-hostname kube-node3

+ 修改/etc/hosts文件,添加：
+ 好192.168.100.31  kube-node1    kube-node1
+ 192.168.100.32  kube-node2    kube-node2
+ 192.168.100.33  kube-node3    kube-node3
<br/>
然后执行preready.sh 实现SSH免密登录等初始化环境操作
再按步骤执行部署.sh<br/>
+ createCA.sh
+ deployKubectl.sh
+ deployEtcd.sh
+ deployFlannel.sh
+ deployHaproxy.sh
+ deployKube-apiserver.sh
+ deployKube-controller-manager.sh
+ deployKube-scheduler.sh
+ deployDocker.sh
+ deployKubelet.sh
+ deployKube-proxy.sh
