#! /bin/bash

#cd /home/k8s-install
source /usr/local/bin/environment.sh

# 部署worker节点
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "yum install -y epel-release"
    ssh root@${node_ip} "yum install -y conntrack ipvsadm ipset jq iptables curl sysstat libseccomp && /usr/sbin/modprobe ip_vs "
  done

# 部署docker组件
# 下载和分发 docker 二进制文件
if [ ! -f "../packages/docker-18.03.1-ce.tgz" ];then
  wget https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz
  tar -xvf docker-18.03.1-ce.tgz
else
  tar -xvf ../packages/docker-18.03.1-ce.tgz   
fi

for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp docker/docker*  root@${node_ip}:/usr/local/bin/
    ssh root@${node_ip} "chmod +x /usr/local/bin/*"
  done

# 创建和分发systemd unit文件
cat > docker.service <<"EOF"
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
Environment="PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin"
EnvironmentFile=-/run/flannel/docker
ExecStart=/usr/local/bin/dockerd --log-level=error $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

for node_ip in ${NODE_IPS[@]}
  do 
    echo ">>> ${node_ip}" 
    scp docker.service root@${node_ip}:/etc/systemd/system/
  done

# 配置和分发docker配置文件
cat > docker-daemon.json <<EOF
{
    "registry-mirrors": ["https://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn"],
    "max-concurrent-downloads": 20
}
EOF

for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p  /etc/docker/"
    scp docker-daemon.json root@${node_ip}:/etc/docker/daemon.json
  done

# 启动docker服务
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl stop firewalld && systemctl disable firewalld"
    ssh root@${node_ip} "/usr/sbin/iptables -F && /usr/sbin/iptables -X && /usr/sbin/iptables -F -t nat && /usr/sbin/iptables -X -t nat"
    ssh root@${node_ip} "/usr/sbin/iptables -P FORWARD ACCEPT"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable docker && systemctl restart docker"
    ssh root@${node_ip} 'for intf in /sys/devices/virtual/net/docker0/brif/*; do echo 1 > $intf/hairpin_mode; done'
    ssh root@${node_ip} "sudo sysctl -p /etc/sysctl.d/kubernetes.conf"
  done

# 检查服务运行状态
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl status docker|grep Active"
  done
