#!/bin/bash

apt-get update
apt-get install curl docker-compose -yy
curl -sL get.docker.com | bash
systemctl enable docker --now

wget -O /root/bcrypt https://raw.githubusercontent.com/acacia233/Cutenico-Static/main/Ping/bcrypt
chmod +x /root/bcrypt
SECRET="$(echo -n $1 | /root/bcrypt)"

mkdir /usr/dockerapp/
mkdir /usr/dockerapp/monitor/
mkdir /usr/dockerapp/monitor/prometheus
mkdir /usr/dockerapp/monitor/prometheus/data
mkdir /usr/dockerapp/monitor/blackbox

chmod 777 -R /usr/dockerapp/monitor/prometheus/data

cat > /usr/dockerapp/monitor/docker-compose.yml << EOF
version: '3.4'
services:
  prometheus: 
    image: prom/prometheus
    container_name: prometheus
    hostname: prometheus
    volumes:
      - /usr/dockerapp/monitor/prometheus:/etc/prometheus/
    environment:
      - TZ=Asia/Shanghai
    command: --storage.tsdb.path=/etc/prometheus/data --storage.tsdb.retention.time=90d --config.file=/etc/prometheus/prometheus.yml --web.enable-lifecycle --web.config.file=/etc/prometheus/web.yml
    networks:
      monitor_cluster:
          ipv4_address: "172.16.16.10"
    ports:
      - '9090:9090'

  black-exporter:
    image: prom/blackbox-exporter:v0.16.0
    container_name: blackbox
    hostname: black-exporter
    volumes:
      - /usr/dockerapp/monitor/blackbox/blackbox.yml:/config/blackbox.yml
    command:
      - '--config.file=/config/blackbox.yml'
    environment:
      - TZ=Asia/Shanghai
    cap_add:
      - NET_RAW
    networks:
      monitor_cluster:
          ipv4_address: "172.16.16.11"
networks:
  monitor_cluster:
    ipam:
      driver: default
      config:
        - subnet: "172.16.16.0/24"
EOF

cat > /usr/dockerapp/monitor/prometheus/web.yml << EOF
basic_auth_users:
    admin: SECRET
EOF

sed -i "s!SECRET!$SECRET!g" /usr/dockerapp/monitor/prometheus/web.yml

cat > /usr/dockerapp/monitor/prometheus/prometheus.yml << EOF
global:
  scrape_interval: 1s
scrape_configs:
- job_name: tcping
  metrics_path: /probe
  params:
     module: [tcp]
  static_configs:
  - targets: 
    - "probe.cn.gz-ct.cutenico.best:443"
    - "probe.cn.gz-cm.cutenico.best:443"
    - "probe.cn.gz-cu.cutenico.best:443"
    - "probe.cn.bj-ct.cutenico.best:443"
    - "probe.cn.bj-cm.cutenico.best:443"
    - "probe.cn.bj-cu.cutenico.best:443"
    - "probe.cn.sh-ct.cutenico.best:443"
    - "probe.cn.sh-cu.cutenico.best:443"
    - "probe.cn.sh-cm.cutenico.best:443"
    - "probe.cn.sh-ct.cn2.cutenico.best:443"
    - "probe.cn.sh-ct.163plus.cutenico.best:443"
    - "probe.cn.sh-cu.9929.cutenico.best:443"
#Special - Speedtest
    - "probe.sp.cn.gz-ct.cutenico.best:8080"
    - "probe.sp.cn.gz-cm.cutenico.best:8080"
    - "probe.sp.cn.gz-cu.cutenico.best:8080"
    - "probe.sp.cn.bj-ct.cutenico.best:8080"
    - "probe.sp.cn.bj-cm.cutenico.best:8080"
    - "probe.sp.cn.bj-cu.cutenico.best:8080"
    - "probe.sp.cn.sh-ct.cutenico.best:8080"
    - "probe.sp.cn.sh-cu.cutenico.best:8080"
    - "probe.sp.cn.sh-cm.cutenico.best:8080"
    - "probe.sp.cn.sh-ct.cn2.cutenico.best:8080"
    - "probe.sp.cn.sh-ct.163plus.cutenico.best:8080"
    - "probe.sp.cn.sh-cu.9929.cutenico.best:8080"

  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - source_labels: [__address__]
      regex: (probe.cn.gz-ct.cutenico.best:443)
      replacement: "RTT - Guangzhou - China Telecom"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.gz-ct.cutenico.best:443)
      replacement: "Packet Loss - Guangzhou - China Telecom"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.gz-cm.cutenico.best:443)
      replacement: "RTT - Guangzhou - China Mobile"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.gz-cm.cutenico.best:443)
      replacement: "Packet Loss - Guangzhou - China Mobile"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.gz-cu.cutenico.best:443)
      replacement: "RTT - Guangzhou - China Unicom"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.gz-cu.cutenico.best:443)
      replacement: "Packet Loss - Guangzhou - China Unicom"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-ct.cutenico.best:443)
      replacement: "RTT - Shanghai - China Telecom"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-ct.cutenico.best:443)
      replacement: "Packet Loss - Shanghai - China Telecom"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-cm.cutenico.best:443)
      replacement: "RTT - Shanghai - China Mobile"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-cm.cutenico.best:443)
      replacement: "Packet Loss - Shanghai - China Mobile"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-cu.cutenico.best:443)
      replacement: "RTT - Shanghai - China Unicom"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-cu.cutenico.best:443)
      replacement: "Packet Loss - Shanghai - China Unicom"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.bj-ct.cutenico.best:443)
      replacement: "RTT - Beijing - China Telecom"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.bj-ct.cutenico.best:443)
      replacement: "Packet Loss - Beijing - China Telecom"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.bj-cm.cutenico.best:443)
      replacement: "RTT - Beijing - China Mobile"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.bj-cm.cutenico.best:443)
      replacement: "Packet Loss - Beijing - China Mobile"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.bj-cu.cutenico.best:443)
      replacement: "RTT - Beijing - China Unicom"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.bj-cu.cutenico.best:443)
      replacement: "Packet Loss - Beijing - China Unicom"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-ct.cn2.cutenico.best:443)
      replacement: "RTT - Shanghai - China Telecom - CN2"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-ct.cn2.cutenico.best:443)
      replacement: "Packet Loss - Shanghai - China Telecom - CN2"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-ct.163plus.cutenico.best:443)
      replacement: "RTT - Shanghai - China Telecom - 163+"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-ct.163plus.cutenico.best:443)
      replacement: "Packet Loss - Shanghai - China Telecom - 163+"
      target_label: probe_target_packet_loss_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-cu.9929.cutenico.best:443)
      replacement: "RTT - Shanghai - China Unicom - 9929"
      target_label: probe_target_rtt_display
    - source_labels: [__address__]
      regex: (probe.cn.sh-cu.9929.cutenico.best:443)
      replacement: "Packet Loss - Shanghai - China Unicom - 9929"
      target_label: probe_target_packet_loss_display

# - Special - Speedtest

    - source_labels: [__address__]
      regex: (probe.sp.cn.gz-ct.cutenico.best:8080)
      replacement: "RTT - Guangzhou - China Telecom"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.gz-ct.cutenico.best)
      replacement: "Packet Loss - Guangzhou - China Telecom"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.gz-cm.cutenico.best:8080)
      replacement: "RTT - Guangzhou - China Mobile"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.gz-cm.cutenico.best:8080)
      replacement: "Packet Loss - Guangzhou - China Mobile"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.gz-cu.cutenico.best:8080)
      replacement: "RTT - Guangzhou - China Unicom"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.gz-cu.cutenico.best:8080)
      replacement: "Packet Loss - Guangzhou - China Unicom"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-ct.cutenico.best:8080)
      replacement: "RTT - Shanghai - China Telecom"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-ct.cutenico.best:8080)
      replacement: "Packet Loss - Shanghai - China Telecom"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-cm.cutenico.best:8080)
      replacement: "RTT - Shanghai - China Mobile"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-cm.cutenico.best:8080)
      replacement: "Packet Loss - Shanghai - China Mobile"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-cu.cutenico.best:8080)
      replacement: "RTT - Shanghai - China Unicom"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-cu.cutenico.best:8080)
      replacement: "Packet Loss - Shanghai - China Unicom"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.bj-ct.cutenico.best:8080)
      replacement: "RTT - Beijing - China Telecom"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.bj-ct.cutenico.best:8080)
      replacement: "Packet Loss - Beijing - China Telecom"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.bj-cm.cutenico.best:8080)
      replacement: "RTT - Beijing - China Mobile"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.bj-cm.cutenico.best:8080)
      replacement: "Packet Loss - Beijing - China Mobile"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.bj-cu.cutenico.best:8080)
      replacement: "RTT - Beijing - China Unicom"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.bj-cu.cutenico.best:8080)
      replacement: "Packet Loss - Beijing - China Unicom"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-ct.cn2.cutenico.best:8080)
      replacement: "RTT - Shanghai - China Telecom - CN2"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-ct.cn2.cutenico.best:8080)
      replacement: "Packet Loss - Shanghai - China Telecom - CN2"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-ct.163plus.cutenico.best:8080)
      replacement: "RTT - Shanghai - China Telecom - 163+"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-ct.163plus.cutenico.best:8080)
      replacement: "Packet Loss - Shanghai - China Telecom - 163+"
      target_label: probe_target_packet_loss_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-cu.9929.cutenico.best:8080)
      replacement: "RTT - Shanghai - China Unicom - 9929"
      target_label: probe_target_rtt_display_sp
    - source_labels: [__address__]
      regex: (probe.sp.cn.sh-cu.9929.cutenico.best:8080)
      replacement: "Packet Loss - Shanghai - China Unicom - 9929"
      target_label: probe_target_packet_loss_display_sp
    - target_label: __address__
      replacement: 172.16.16.11:9115
EOF

cat > /usr/dockerapp/monitor/blackbox/blackbox.yml << EOF
modules:
  tcp:
    prober: tcp
    timeout: 2s
    tcp:
      preferred_ip_protocol: "ip4"
  ping:
    prober: icmp
    timeout: 2s
    icmp:
      preferred_ip_protocol: "ip4"
      payload_size: 64

EOF

docker-compose -f /usr/dockerapp/monitor/docker-compose.yml up -d

rm -rf /root/bcrypt

echo "done"
