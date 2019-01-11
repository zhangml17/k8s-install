#! /bin/bash

cd /home/k8s-install
source /usr/local/bin/environment.sh

# 部署Master节点
# 下载最新版本的二进制文件
wget https://dl.k8s.io/v1.10.4/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
tar -xzvf  kubernetes-src.tar.gz

for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp server/bin/* root@${node_ip}:/usr/local/bin/
    ssh root@${node_ip} "chmod +x /usr/local/bin/*"
  done

# 部署高可用组件
# 安装
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "yum install -y keepalived haproxy"
  done

# 配置和下发haproxy配置文件
cat > haproxy.cfg <<EOF
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /var/run/haproxy-admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    nbproc 1

defaults
    log     global
    timeout connect 5000
    timeout client  10m
    timeout server  10m

listen  admin_stats
    bind 0.0.0.0:10080
    mode http
    log 127.0.0.1 local0 err
    stats refresh 30s
    stats uri /status
    stats realm welcome login\ Haproxy
    stats auth admin:123456
    stats hide-version
    stats admin if TRUE

listen kube-master
    bind 0.0.0.0:8443
    mode tcp
    option tcplog
    balance source
    server 192.168.100.31 192.168.100.31:6443 check inter 2000 fall 2 rise 2 weight 1
    server 192.168.100.32 192.168.100.32:6443 check inter 2000 fall 2 rise 2 weight 1
    server 192.168.100.33 192.168.100.33:6443 check inter 2000 fall 2 rise 2 weight 1
EOF

for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp haproxy.cfg root@${node_ip}:/etc/haproxy
  done

# 启动haproxy服务
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable haproxy && systemctl restart haproxy"
  done

# 配置和下发keepalived文件
# master配置文件
cat  > keepalived-master.conf <<EOF
global_defs {
    router_id lb-master-105
}

vrrp_script check-haproxy {
    script "killall -0 haproxy"
    interval 5
    weight -30
}

vrrp_instance VI-kube-master {
    state MASTER
    priority 120
    dont_track_primary
    interface ${VIP_IF}
    virtual_router_id 68
    advert_int 3
    track_script {
        check-haproxy
    }
    virtual_ipaddress {
        ${MASTER_VIP}
    }
}
EOF

# backup配置文件
cat  > keepalived-backup.conf <<EOF
global_defs {
    router_id lb-backup-105
}

vrrp_script check-haproxy {
    script "killall -0 haproxy"
    interval 5
    weight -30
}

vrrp_instance VI-kube-master {
    state BACKUP
    priority 110
    dont_track_primary
    interface ${VIP_IF}
    virtual_router_id 68
    advert_int 3
    track_script {
        check-haproxy
    }
    virtual_ipaddress {
        ${MASTER_VIP}
    }
}
EOF

# 下发keepalived配置文件
scp keepalived-master.conf root@192.168.100.31:/etc/keepalived/keepalived.conf

scp keepalived-backup.conf root@192.168.100.32:/etc/keepalived/keepalived.conf
scp keepalived-backup.conf root@192.168.100.33:/etc/keepalived/keepalived.conf

# 启动keepalived服务
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable keepalived && systemctl restart keepalived"
  done
