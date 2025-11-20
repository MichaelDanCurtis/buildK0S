#!/bin/bash
#
# k0s Control Node Firewall Configuration
# Run this ONLY on the CONTROL node (uslvlbmsast035)
#

set -e

echo "========================================="
echo "k0s Control Node Firewall Configuration"
echo "========================================="

echo "Opening required ports for k0s control plane..."

# Kubernetes API Server
sudo firewall-cmd --permanent --add-port=6443/tcp
echo "✓ Opened port 6443/tcp (Kubernetes API)"

# etcd client communication
sudo firewall-cmd --permanent --add-port=2380/tcp
echo "✓ Opened port 2380/tcp (etcd client)"

# etcd peer communication
sudo firewall-cmd --permanent --add-port=2381/tcp
echo "✓ Opened port 2381/tcp (etcd peer)"

# konnectivity
sudo firewall-cmd --permanent --add-port=8132/tcp
echo "✓ Opened port 8132/tcp (konnectivity)"

# k0s API
sudo firewall-cmd --permanent --add-port=9443/tcp
echo "✓ Opened port 9443/tcp (k0s API)"

# kubelet API
sudo firewall-cmd --permanent --add-port=10250/tcp
echo "✓ Opened port 10250/tcp (kubelet API)"

# Reload firewall
echo ""
echo "Reloading firewall..."
sudo firewall-cmd --reload

echo ""
echo "========================================="
echo "Firewall configuration completed!"
echo "========================================="
echo ""
echo "Current firewall rules:"
sudo firewall-cmd --list-all
echo ""
echo "Next step: Run 03-install-control.sh"
