#!/bin/bash
#
# k0s Troubleshooting Script
# Run this script to diagnose k0s issues
#
# Can be run on either CONTROL or WORKER nodes
#

NODE_TYPE=""
if systemctl list-units | grep -q k0scontroller; then
    NODE_TYPE="CONTROL"
elif systemctl list-units | grep -q k0sworker; then
    NODE_TYPE="WORKER"
else
    NODE_TYPE="UNKNOWN"
fi

echo "========================================="
echo "k0s Troubleshooting Script"
echo "Node Type: $NODE_TYPE"
echo "========================================="
echo ""

# System Information
echo "1. System Information:"
echo "----------------------------------------"
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -I | awk '{print $1}')"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo ""

# Check if k0s is installed
echo "2. k0s Installation:"
echo "----------------------------------------"
if command -v k0s &> /dev/null; then
    echo "✓ k0s is installed"
    k0s version
else
    echo "✗ k0s is NOT installed"
fi
echo ""

# Service Status
echo "3. Service Status:"
echo "----------------------------------------"
if [ "$NODE_TYPE" == "CONTROL" ]; then
    sudo systemctl status k0scontroller --no-pager -l
elif [ "$NODE_TYPE" == "WORKER" ]; then
    sudo systemctl status k0sworker --no-pager -l
else
    echo "No k0s service found"
fi
echo ""

# Recent Logs
echo "4. Recent Logs (last 50 lines):"
echo "----------------------------------------"
if [ "$NODE_TYPE" == "CONTROL" ]; then
    sudo journalctl -u k0scontroller -n 50 --no-pager
elif [ "$NODE_TYPE" == "WORKER" ]; then
    sudo journalctl -u k0sworker -n 50 --no-pager
else
    echo "No k0s service logs available"
fi
echo ""

# Kernel Modules
echo "5. Required Kernel Modules:"
echo "----------------------------------------"
if lsmod | grep -q overlay; then
    echo "✓ overlay module loaded"
else
    echo "✗ overlay module NOT loaded"
fi

if lsmod | grep -q br_netfilter; then
    echo "✓ br_netfilter module loaded"
else
    echo "✗ br_netfilter module NOT loaded"
fi
echo ""

# Sysctl Settings
echo "6. Sysctl Settings:"
echo "----------------------------------------"
echo "net.bridge.bridge-nf-call-iptables: $(sysctl -n net.bridge.bridge-nf-call-iptables 2>/dev/null || echo 'NOT SET')"
echo "net.bridge.bridge-nf-call-ip6tables: $(sysctl -n net.bridge.bridge-nf-call-ip6tables 2>/dev/null || echo 'NOT SET')"
echo "net.ipv4.ip_forward: $(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 'NOT SET')"
echo ""

# Swap Status
echo "7. Swap Status:"
echo "----------------------------------------"
if swapon --show | grep -q '/'; then
    echo "⚠ WARNING: Swap is enabled (should be disabled)"
    swapon --show
else
    echo "✓ Swap is disabled"
fi
echo ""

# Firewall Status
echo "8. Firewall Status:"
echo "----------------------------------------"
if systemctl is-active --quiet firewalld; then
    echo "✓ Firewalld is active"
    echo ""
    echo "Open ports:"
    sudo firewall-cmd --list-ports
else
    echo "Firewalld is not active"
fi
echo ""

# SELinux Status
echo "9. SELinux Status:"
echo "----------------------------------------"
if command -v getenforce &> /dev/null; then
    SELINUX_STATUS=$(getenforce)
    echo "SELinux: $SELINUX_STATUS"
    if [ "$SELINUX_STATUS" == "Enforcing" ]; then
        echo "⚠ SELinux is enforcing - may cause issues"
    fi
else
    echo "SELinux tools not found"
fi
echo ""

# Network Connectivity (Control Node Only)
echo "10. Network Connectivity Tests:"
echo "----------------------------------------"
CONTROL_NODE="140.176.201.59"
if [ "$NODE_TYPE" == "WORKER" ]; then
    echo "Testing connection to control node ($CONTROL_NODE)..."
    
    # Ping test
    if ping -c 2 $CONTROL_NODE &> /dev/null; then
        echo "✓ Ping to control node successful"
    else
        echo "✗ Cannot ping control node"
    fi
    
    # Port 6443 test (API server)
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$CONTROL_NODE/6443" 2>/dev/null; then
        echo "✓ Can reach API server port 6443"
    else
        echo "✗ Cannot reach API server port 6443"
    fi
fi
echo ""

# Disk Space
echo "11. Disk Space:"
echo "----------------------------------------"
df -h / | tail -n 1
echo ""

# Memory Usage
echo "12. Memory Usage:"
echo "----------------------------------------"
free -h
echo ""

# If this is control node, show kubectl info
if [ "$NODE_TYPE" == "CONTROL" ]; then
    echo "13. Kubectl Access:"
    echo "----------------------------------------"
    if command -v kubectl &> /dev/null; then
        echo "✓ kubectl is installed"
        if kubectl get nodes &> /dev/null; then
            echo "✓ kubectl can access cluster"
            echo ""
            kubectl get nodes
        else
            echo "✗ kubectl cannot access cluster"
        fi
    else
        echo "✗ kubectl is NOT installed"
    fi
    echo ""
fi

echo "========================================="
echo "Troubleshooting Complete"
echo "========================================="
echo ""
echo "Common Issues and Solutions:"
echo ""
echo "1. Service won't start:"
echo "   - Check logs: sudo journalctl -u k0s[controller|worker] -n 100"
echo "   - Verify swap is disabled: swapon --show"
echo "   - Check disk space: df -h"
echo ""
echo "2. Worker won't join:"
echo "   - Verify network connectivity to control node"
echo "   - Check firewall rules on both nodes"
echo "   - Verify token is correct and not expired"
echo ""
echo "3. Pods stuck in Pending:"
echo "   - Check node resources: kubectl describe nodes"
echo "   - Check pod events: kubectl describe pod <pod-name>"
echo ""
echo "For more details, check full logs:"
if [ "$NODE_TYPE" == "CONTROL" ]; then
    echo "  sudo journalctl -u k0scontroller -f"
elif [ "$NODE_TYPE" == "WORKER" ]; then
    echo "  sudo journalctl -u k0sworker -f"
fi
echo ""
