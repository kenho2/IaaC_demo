#!/usr/bin/env bash
# Run this INSIDE VM 888 as root (or with sudo) before converting it to a
# Proxmox template. It removes all per-instance identity so every clone starts
# clean and obtains a DHCP address on first boot via cloud-init.
#
# Usage (from inside the VM console or SSH):
#   chmod +x generalize-ubuntu-template.sh
#   sudo bash generalize-ubuntu-template.sh
#
# After this script completes:
#   1. Shut down the VM: sudo poweroff
#   2. In Proxmox GUI or CLI: right-click VM 888 -> Convert to Template
#      (or: qm template 888)
#   3. Re-run Terraform to recreate clones from the clean template.

set -euo pipefail

echo "==> Installing cloud-init (if not already present)"
apt-get update -qq
apt-get install -y -qq cloud-init cloud-guest-utils qemu-guest-agent

echo "==> Enabling qemu-guest-agent on boot"
systemctl enable qemu-guest-agent

echo "==> Writing generic cloud-init network config (DHCP, no MAC pin)"
mkdir -p /etc/cloud/cloud.cfg.d

cat > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg <<'EOF'
network: {config: disabled}
EOF

# Write a clean netplan that matches ANY ethernet interface name, no MAC pin
rm -f /etc/netplan/*.yaml /etc/netplan/*.yml
cat > /etc/netplan/50-cloud-init.yaml <<'EOF'
network:
  version: 2
  ethernets:
    all-eth:
      match:
        name: "en*"
      dhcp4: true
      dhcp6: false
EOF
chmod 600 /etc/netplan/50-cloud-init.yaml

echo "==> Resetting cloud-init state so it runs fresh on each clone"
cloud-init clean --logs --seed --configs all

echo "==> Removing SSH host keys (regenerated on first boot)"
rm -f /etc/ssh/ssh_host_*

echo "==> Clearing machine-id (new ID assigned per clone)"
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

echo "==> Removing persistent udev network rules if present"
rm -f /etc/udev/rules.d/70-persistent-net.rules

echo "==> Clearing apt cache and bash history"
apt-get clean
rm -f /root/.bash_history /home/*/.bash_history

echo ""
echo "==> Done. Shut down now with: sudo poweroff"
echo "    Then in Proxmox: qm template 888"
