#!/bin/bash
set -e

print_banner() {
  echo -e "\033[1;35m"
  echo "╭────────────────────────────────────────────╮"
  echo "│         NetworkOptimizer v1.0              │"
  echo "│  TCP Congestion + Queue + Socket Tweaks   │"
  echo "╰────────────────────────────────────────────╯"
  echo -e "\033[0m"
}

optimize_sysctl() {
  cat <<EOF > /etc/sysctl.d/99-network-optimizer.conf
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_window_scaling=1
EOF
  sysctl --system > /dev/null
}

load_bbr_module() {
  modprobe tcp_bbr 2>/dev/null || true
  echo "tcp_bbr" > /etc/modules-load.d/bbr.conf
}

check_status() {
  echo -e "\n\033[1;34mCurrent TCP congestion control:\033[0m"
  sysctl net.ipv4.tcp_congestion_control
  echo -e "\033[1;34mAvailable algorithms:\033[0m"
  sysctl net.ipv4.tcp_available_congestion_control
  echo -e "\033[1;34mDefault qdisc:\033[0m"
  sysctl net.core.default_qdisc
}

main() {
  print_banner
  load_bbr_module
  optimize_sysctl
  check_status
  echo -e "\n\033[1;32m✔ Network tuning applied successfully.\033[0m"
}

main
