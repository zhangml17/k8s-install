#! /bin/bash

# 设置集群机器的SSH免密登录
ssh-keygen -t rsa
ssh-copy-id root@kube-node1
ssh-copy-id root@kube-node2
ssh-copy-id root@kube-node3

# 设置系统参数
cat > kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
EOF

# 分发集群环境变量定义脚本
# 关闭SELinux
# 关闭dnsmasq
# 设置系统参数
# 加载内核模块
# 设置系统时区
source environment.sh
for node_ip in ${NODE_IPS[@]}
  do 
    echo ">>> ${node_ip}"
    scp environment.sh  root@${node_ip}:/usr/local/bin
    ssh root@${node_ip}  "chmod +x /usr/local/bin/*"
    ssh root@${node_ip}  "sudo setenforce 0"
    ssh root@${node_ip}  "sudo service dnsmasq stop  &&  sudo systemctl disable dnsmasq"
    
    scp kubernetes.conf  root@${node_ip}:/etc/sysctl.d/kubernetes.conf
    ssh root@${node_ip}  "sysctl -p /etc/sysctl.d/kubernetes.conf && mount -t cgroup -o cpu,cpuacct none /sys/fs/cgroup/cpu,cpuacct"
    ssh root@${node_ip}  "sudo modprobe br_netfilter  &&  sudo modprobe ip_vs"
    ssh root@${node_ip}  "sudo timedatectl set-timezone Asia/Shanghai && sudo timedatectl set-local-rtc 0 "
    ssh root@${node_ip}  "sudo systemctl restart rsyslog  &&  sudo systemctl restart crond"
  done
