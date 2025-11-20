#!/bin/bash
#
# k0s Worker Node Firewall Configuration
# Run this ONLY on WORKER nodes (uslvlbmsast036, uslvlbmsast037)
#

set -e

echo "========================================="
echo "k0s Worker Node Firewall Configuration"
echo "========================================="

echo "Opening required ports for k0s worker..."

# kubelet API
sudo firewall-cmd --permanent --add-port=10250/tcp
echo "✓ Opened port 10250/tcp (kubelet API)"

# konnectivity
sudo firewall-cmd --permanent --add-port=8132/tcp
echo "✓ Opened port 8132/tcp (konnectivity)"

# NodePort Services
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
echo "✓ Opened ports 30000-32767/tcp (NodePort services)"

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
echo "Next step: Wait for control node setup, then run 04-install-worker.sh"
