#!/bin/bash
#
# k0s Node Preparation Script
# Run this on ALL nodes (control and workers)
#

set -e

echo "========================================="
echo "k0s Node Preparation Script"
echo "========================================="

# Update system
echo "[1/6] Updating system packages..."
sudo dnf update -y

# Disable swap
echo "[2/6] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
echo "[3/6] Loading required kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k0s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl parameters
echo "[4/6] Configuring sysctl parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/k0s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Install required packages
echo "[5/6] Installing required packages..."
sudo dnf install -y curl wget tar

# Verify kernel modules
echo "[6/6] Verifying kernel modules..."
lsmod | grep overlay
lsmod | grep br_netfilter

echo ""
echo "========================================="
echo "Node preparation completed successfully!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  - If this is the CONTROL node, run: 02-firewall-control.sh"
echo "  - If this is a WORKER node, run: 02-firewall-worker.sh"
