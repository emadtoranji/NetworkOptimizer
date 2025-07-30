## 🚀 One-Line Installation (Network Optimizer Script)

Just run this in your terminal (works on root or non-root):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/emadtoranji/NetworkOptimizer/main/optimize.sh)
```

---

## ✨ Features

- ✅ Enables Google's BBR congestion control (`tcp_bbr`) — BBRv2 if using a patched kernel, otherwise defaults to BBRv1
- ✅ Configures `fq` queueing discipline for optimal performance
- ✅ Enables TCP Fast Open, MTU probing, and aggressive memory windows
- ✅ Safe for production environments
- ✅ Writes clean configurations to `/etc/sysctl.d/`
- ✅ No external dependencies or systemd required
- ✅ Easy to install and uninstall
- ⚠️ BBRv2 is not enabled by default in Linux. It requires a patched kernel such as [BBRv2 backports](https://github.com/google/bbr/blob/master/Documentation/bbr2.org).

---

## 🔧 Requirements

- 🐧 Linux Kernel 5.4 or higher (recommended: 5.10+ for full BBRv2 support)
- 🔐 Root or `sudo` access
- 💡 `bash` shell (pre-installed on all major Linux distributions)

To check your kernel version:
```bash
uname -r
```

---

## 🔍 Verify BBR Activation (BBRv1 or v2, depending on kernel)

After running the script, confirm BBR is active (usually BBRv1 unless you use a custom kernel with BBRv2 patches):

1. Check TCP congestion control:
   ```bash
   sysctl net.ipv4.tcp_congestion_control
   ```
   Expected output:
   ```
   net.ipv4.tcp_congestion_control = bbr
   ```

2. Verify BBR module:
   ```bash
   lsmod | grep bbr
   ```
   Expected output:
   ```
   tcp_bbr                20480  1
   ```

3. Inspect active TCP sessions:
   ```bash
   ss -tin
   ```
   Look for `bbr` in the congestion control field.

---

## 🧠 How It Works

While this script enables BBR (tcp_bbr), Linux does not currently offer a user-selectable distinction between BBRv1 and BBRv2. Most systems will run BBRv1 unless a custom kernel with BBRv2 support is used.

The script performs the following:

- Loads the `tcp_bbr` kernel module
- Configures module auto-loading on boot
- Creates `/etc/sysctl.d/99-bbrv2.conf` with optimized settings:
  ```bash
  net.core.default_qdisc=fq
  net.ipv4.tcp_congestion_control=bbr
  net.ipv4.tcp_notsent_lowat=16384
  net.ipv4.tcp_fastopen=3
  net.ipv4.tcp_mtu_probing=1
  net.ipv4.tcp_slow_start_after_idle=0
  net.ipv4.tcp_window_scaling=1
  net.ipv4.tcp_rmem=4096 87380 67108864
  net.ipv4.tcp_wmem=4096 65536 67108864
  ```
- Applies changes instantly with `sysctl --system`

---

## 🧹 Uninstallation

To revert changes:
```bash
sudo rm -f /etc/sysctl.d/99-network-optimizer.conf
sudo rm -f /etc/modules-load.d/bbrv2.conf
sudo sysctl --system
sudo reboot
```

---

## 🧪 Tested Environments

| Distribution       | Kernel   | Status |
|--------------------|----------|--------|
| Ubuntu 20.04       | 5.15.x   | ✅     |
| Ubuntu 22.04       | 5.19+    | ✅     |
| Debian 11          | 5.10.x   | ✅     |
| Debian 12          | 6.1.x    | ✅     |
| AlmaLinux 9        | 5.14.x   | ✅     |
| Oracle Linux 8     | 5.15+ (UEK) | ✅  |
| Alpine Edge        | 6.1+     | ✅     |

---

## 📈 Performance Benefits (with BBR enabled)

After enabling BBRv2, expect:
- 🌍 Faster CDN/Cloudflare traffic
- 🛰️ Reduced SSH/RDP latency
- 📦 Improved TCP-based download speeds (HTTP, Git, APT/YUM, etc.)
- 📡 Enhanced stability for VPNs (WireGuard, OpenVPN, Shadowsocks)

---

## ⚠️ Troubleshooting

- **BBR not active**: Ensure your kernel supports tcp_bbr (5.4+). BBRv2 requires experimental kernel patches and is not enabled by default in mainline kernels. Upgrade your kernel if needed:
  ```bash
  sudo apt update && sudo apt install linux-generic-hwe-22.04
  ```
- **Permission denied**: Run the script with `sudo`.
- **Module not found**: Verify the `tcp_bbr` module is available:
  ```bash
  modprobe tcp_bbr
  ```

---

## 📜 License

This project is licensed under the **MIT License**. Feel free to use, fork, modify, and share!

---

## 🤝 Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add YourFeature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a Pull Request.

Please ensure your changes are well-tested and include a description of the changes.
