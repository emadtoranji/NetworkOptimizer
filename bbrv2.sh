#!/usr/bin/env bash

# BBRv2.sh — Fully Auto TCP Booster (rootless-safe)

set -e

[[ $EUID -ne 0 ]] && { echo "⚡ Elevating to root..."; exec sudo bash "$0" "$@"; }

echo "🚀 Starting BBRv2 Optimization Script"

# Kernel version check
kernel_version=$(uname -r | cut -d- -f1)
major=$(echo $kernel_version | cut -d. -f1)
minor=$(echo $kernel_version | cut -d. -f2)
if (( major < 5 || (major == 5 && minor < 4) )); then
    echo "❌ Kernel $kernel_version is too old. Need 5.4 or higher."
    exit 1
fi

# Load tcp_bbr now
modprobe tcp_bbr 2>/dev/null || true

# Ensure BBR module is loaded at boot
mkdir -p /etc/modules-load.d
echo "tcp_bbr" > /etc/modules-load.d/bbrv2.conf

# Create sysctl config
cat <<EOF > /etc/sysctl.d/99-bbrv2.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
EOF

# Apply settings
sysctl --system

# Confirm
echo
echo "✅ BBRv2 and TCP optimizations applied!"
sysctl net.ipv4.tcp_congestion_control | grep -q bbr && echo "🎉 BBR is ACTIVE!" || echo "⚠️ BBR not active"
lsmod | grep -q bbr && echo "📦 tcp_bbr module loaded" || echo "⚠️ tcp_bbr module not loaded"

echo
echo "💡 You may now test your TCP speed. No reboot needed."
