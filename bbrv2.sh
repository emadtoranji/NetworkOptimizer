#!/bin/bash

# BBRv2 Ultimate Enabler - Optimized for Iran + Global Servers

set -e

echo "🧠 BBRv2 Optimizer - Starting installation..."

# Check root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root."
  exit 1
fi

# Check kernel version
KERNEL_VERSION=$(uname -r | cut -d'-' -f1)
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d'.' -f1)
KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d'.' -f2)

if [ "$KERNEL_MAJOR" -lt 5 ] || { [ "$KERNEL_MAJOR" -eq 5 ] && [ "$KERNEL_MINOR" -lt 4 ]; }; then
  echo "⚠️  Your kernel version ($KERNEL_VERSION) does not support BBRv2 well."
  echo "➡️  Consider upgrading to 5.10+ for best results."
fi

# Enable TCP BBR module
echo "✅ Loading tcp_bbr module..."
modprobe tcp_bbr
echo "tcp_bbr" > /etc/modules-load.d/bbrv2.conf

# Apply optimal sysctl settings
echo "📦 Writing sysctl config for optimal TCP performance..."
cat > /etc/sysctl.d/99-bbrv2.conf <<EOF
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

# Apply changes
echo "🔧 Applying new sysctl settings..."
sysctl --system

# Check status
echo "🔍 Verifying installation..."
CC=$(sysctl -n net.ipv4.tcp_congestion_control)
if [[ "$CC" == "bbr" ]]; then
  echo "✅ BBR successfully activated!"
else
  echo "❌ BBR activation failed. Please reboot and run this script again."
  exit 1
fi

echo "🎉 Done! Your system is now BBRv2 optimized for maximum throughput."
