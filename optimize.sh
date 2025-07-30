#!/bin/bash
set -e

print_banner() {
  echo -e "\033[1;35m"
  echo "╭────────────────────────────────────────────╮"
  echo "│         NetworkOptimizer v1.0.1            │"
  echo "│   TCP Congestion + Queue + Socket Tweaks   │"
  echo "│       + Advanced Kernel Networking         │"
  echo "╰────────────────────────────────────────────╯"
  echo -e "\033[0m"
}

load_bbr_module() {
  if modprobe tcp_bbr 2>/dev/null; then
    echo -e "\033[1;32m✔ tcp_bbr module loaded successfully.\033[0m"
  else
    echo -e "\033[1;33m⚠ Warning: tcp_bbr module failed to load or already loaded.\033[0m"
  fi
  echo "tcp_bbr" > /etc/modules-load.d/bbr.conf
  echo -e "\033[1;32m✔ tcp_bbr module set to load on boot.\033[0m"
}

optimize_sysctl() {
  cat <<EOF > /etc/sysctl.d/99-network-optimizer.conf
# Queue discipline and congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Enable TCP Fast Open to reduce latency on connection establishment
net.ipv4.tcp_fastopen=3

# Enable MTU probing to avoid blackhole issues with Path MTU Discovery
net.ipv4.tcp_mtu_probing=1

# TCP memory settings - increase buffers for high-speed networks
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
net.core.rmem_max=67108864
net.core.wmem_max=67108864

# Enable window scaling for large TCP windows
net.ipv4.tcp_window_scaling=1

# Reduce delayed ACK to improve latency in some scenarios
net.ipv4.tcp_delack_min=10

# Enable reuse of TIME_WAIT sockets for faster recycling of connections
net.ipv4.tcp_tw_reuse=1

# Enable fast recycling of TIME_WAIT sockets (be cautious on public servers)
net.ipv4.tcp_tw_recycle=0

# Increase the maximum number of incoming connections backlog
net.core.somaxconn=1024

# Increase the maximum socket receive buffer size for all protocols
net.core.netdev_max_backlog=5000

# Enable selective acknowledgments to improve TCP performance
net.ipv4.tcp_sack=1

# Enable SYN cookies to protect against SYN flood attacks
net.ipv4.tcp_syncookies=1

# Enable TCP timestamps for better RTT measurement and PAWS (Protect Against Wrapped Sequence numbers)
net.ipv4.tcp_timestamps=1

# Increase local port range for ephemeral ports to handle many outgoing connections
net.ipv4.ip_local_port_range=10240 65535

# Enable ARP filtering to avoid spoofing in multi-interface setups
net.ipv4.conf.all.arp_filter=1

# Disable source routing for security and network stability
net.ipv4.conf.all.accept_source_route=0

# Disable ICMP redirects acceptance for security
net.ipv4.conf.all.accept_redirects=0

# Disable sending of ICMP redirects (prevent router misbehavior)
net.ipv4.conf.all.send_redirects=0
EOF

  if sysctl --system > /dev/null 2>&1; then
    echo -e "\033[1;32m✔ sysctl parameters applied successfully.\033[0m"
  else
    echo -e "\033[1;33m⚠ Warning: Failed to apply sysctl parameters.\033[0m"
  fi
}

check_status() {
  echo -e "\n\033[1;34mCurrent TCP congestion control:\033[0m"
  current_cc=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
  echo "$current_cc"

  echo -e "\033[1;34mAvailable congestion control algorithms:\033[0m"
  sysctl net.ipv4.tcp_available_congestion_control

  echo -e "\033[1;34mDefault queuing discipline (qdisc):\033[0m"
  sysctl net.core.default_qdisc

  echo -e "\033[1;34mTCP Fast Open status:\033[0m"
  sysctl net.ipv4.tcp_fastopen

  echo -e "\033[1;34mSocket backlog limits:\033[0m"
  sysctl net.core.somaxconn
  sysctl net.core.netdev_max_backlog

  echo -e "\033[1;34mTCP Memory Buffers (rmem/wmem):\033[0m"
  sysctl net.ipv4.tcp_rmem
  sysctl net.ipv4.tcp_wmem

  if [[ "$current_cc" == "bbr" ]]; then
    echo -e "\033[1;32m✔ BBR congestion control is active.\033[0m"
  else
    echo -e "\033[1;33m⚠ Warning: BBR congestion control is NOT active.\033[0m"
  fi
}

main() {
  print_banner
  load_bbr_module
  optimize_sysctl
  check_status
  echo -e "\n\033[1;32m✔ Network tuning applied successfully.\033[0m"
}

main
