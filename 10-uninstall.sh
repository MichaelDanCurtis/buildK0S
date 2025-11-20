#!/bin/bash
#
# k0s Uninstall Script
# WARNING: This will completely remove k0s and all data!
# Run on each node you want to remove k0s from
#

set -e

NODE_TYPE=""
if systemctl list-units | grep -q k0scontroller; then
    NODE_TYPE="CONTROL"
elif systemctl list-units | grep -q k0sworker; then
    NODE_TYPE="WORKER"
else
    NODE_TYPE="UNKNOWN"
fi

echo "========================================="
echo "k0s Uninstall Script"
echo "Node Type: $NODE_TYPE"
echo "========================================="
echo ""
echo "⚠️  WARNING ⚠️"
echo ""
echo "This will completely remove k0s and all data!"
echo "This action CANNOT be undone!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "Starting uninstall process..."
echo ""

# Stop services
if [ "$NODE_TYPE" == "CONTROL" ]; then
    echo "[1/5] Stopping k0s controller service..."
    sudo systemctl stop k0scontroller 2>/dev/null || echo "Service already stopped"
    
    echo "[2/5] Disabling k0s controller service..."
    sudo systemctl disable k0scontroller 2>/dev/null || echo "Service already disabled"
    
elif [ "$NODE_TYPE" == "WORKER" ]; then
    echo "[1/5] Stopping k0s worker service..."
    sudo systemctl stop k0sworker 2>/dev/null || echo "Service already stopped"
    
    echo "[2/5] Disabling k0s worker service..."
    sudo systemctl disable k0sworker 2>/dev/null || echo "Service already disabled"
fi

# Reset k0s
if command -v k0s &> /dev/null; then
    echo "[3/5] Resetting k0s (removing all data)..."
    sudo k0s reset 2>/dev/null || echo "k0s reset completed with warnings"
fi

# Remove k0s binary
echo "[4/5] Removing k0s binary..."
if [ -f "/usr/local/bin/k0s" ]; then
    sudo rm -f /usr/local/bin/k0s
    echo "✓ k0s binary removed"
else
    echo "k0s binary not found"
fi

# Clean up directories
echo "[5/5] Cleaning up directories..."
sudo rm -rf /var/lib/k0s
sudo rm -rf /etc/k0s
sudo rm -rf /run/k0s
sudo rm -rf ~/.kube/config 2>/dev/null || true

# Remove kernel module config (optional)
read -p "Remove kernel module configuration? (yes/no): " REMOVE_MODULES
if [ "$REMOVE_MODULES" == "yes" ]; then
    sudo rm -f /etc/modules-load.d/k0s.conf
    sudo rm -f /etc/sysctl.d/k0s.conf
    echo "✓ Kernel module configuration removed"
fi

echo ""
echo "========================================="
echo "k0s Uninstall Complete!"
echo "========================================="
echo ""
echo "The following have been removed:"
echo "  - k0s services (controller/worker)"
echo "  - k0s binary"
echo "  - k0s data directories"
echo "  - kubeconfig files"
if [ "$REMOVE_MODULES" == "yes" ]; then
    echo "  - Kernel module configuration"
fi
echo ""
echo "Note: Firewall rules have NOT been removed."
echo "If you want to remove firewall rules, run:"
echo ""
if [ "$NODE_TYPE" == "CONTROL" ]; then
    echo "  sudo firewall-cmd --permanent --remove-port=6443/tcp"
    echo "  sudo firewall-cmd --permanent --remove-port=2380/tcp"
    echo "  sudo firewall-cmd --permanent --remove-port=2381/tcp"
    echo "  sudo firewall-cmd --permanent --remove-port=8132/tcp"
    echo "  sudo firewall-cmd --permanent --remove-port=9443/tcp"
    echo "  sudo firewall-cmd --permanent --remove-port=10250/tcp"
    echo "  sudo firewall-cmd --reload"
elif [ "$NODE_TYPE" == "WORKER" ]; then
    echo "  sudo firewall-cmd --permanent --remove-port=10250/tcp"
    echo "  sudo firewall-cmd --permanent --remove-port=8132/tcp"
    echo "  sudo firewall-cmd --permanent --remove-port=30000-32767/tcp"
    echo "  sudo firewall-cmd --reload"
fi
echo ""

# Suggest reboot
echo "A system reboot is recommended to ensure all k0s components are removed."
read -p "Reboot now? (yes/no): " REBOOT
if [ "$REBOOT" == "yes" ]; then
    echo "Rebooting in 5 seconds..."
    sleep 5
    sudo reboot
fi
