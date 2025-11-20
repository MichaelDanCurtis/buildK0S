#!/bin/bash
#
# k0s Setup Helper
# Detects node and suggests next steps
#

set -e

# Node definitions
CONTROL_NODE="uslvlbmsast035"
WORKER1_NODE="uslvlbmsast036"
WORKER2_NODE="uslvlbmsast037"

# Get current hostname
CURRENT_HOST=$(hostname -s)

echo "========================================="
echo "k0s Setup Helper"
echo "========================================="
echo ""
echo "Current hostname: $(hostname)"
echo "Short hostname: $CURRENT_HOST"
echo ""

# Detect node type
NODE_TYPE="UNKNOWN"
if [[ "$CURRENT_HOST" == *"$CONTROL_NODE"* ]]; then
    NODE_TYPE="CONTROL"
elif [[ "$CURRENT_HOST" == *"$WORKER1_NODE"* ]] || [[ "$CURRENT_HOST" == *"$WORKER2_NODE"* ]]; then
    NODE_TYPE="WORKER"
fi

echo "Detected node type: $NODE_TYPE"
echo ""

# Check what's already done
PREP_DONE=false
FIREWALL_DONE=false
K0S_INSTALLED=false

# Check if kernel modules are loaded (indicates prep was done)
if lsmod | grep -q overlay && lsmod | grep -q br_netfilter; then
    PREP_DONE=true
fi

# Check if firewall rules are in place
if [ "$NODE_TYPE" == "CONTROL" ]; then
    if sudo firewall-cmd --list-ports 2>/dev/null | grep -q "6443"; then
        FIREWALL_DONE=true
    fi
elif [ "$NODE_TYPE" == "WORKER" ]; then
    if sudo firewall-cmd --list-ports 2>/dev/null | grep -q "30000-32767"; then
        FIREWALL_DONE=true
    fi
fi

# Check if k0s is installed
if command -v k0s &> /dev/null; then
    K0S_INSTALLED=true
fi

echo "Status Check:"
echo "  - Node preparation: $([ "$PREP_DONE" == true ] && echo "✓ DONE" || echo "✗ NOT DONE")"
echo "  - Firewall configured: $([ "$FIREWALL_DONE" == true ] && echo "✓ DONE" || echo "✗ NOT DONE")"
echo "  - k0s installed: $([ "$K0S_INSTALLED" == true ] && echo "✓ DONE" || echo "✗ NOT DONE")"
echo ""

echo "========================================="
echo "Recommended Next Steps:"
echo "========================================="
echo ""

if [ "$NODE_TYPE" == "UNKNOWN" ]; then
    echo "⚠ Could not detect node type!"
    echo ""
    echo "Expected hostnames:"
    echo "  - Control: $CONTROL_NODE"
    echo "  - Worker 1: $WORKER1_NODE"
    echo "  - Worker 2: $WORKER2_NODE"
    echo ""
    echo "Current hostname: $CURRENT_HOST"
    echo ""
    echo "Please run manually based on your node type:"
    echo "  - For control node: Follow control node steps in README.md"
    echo "  - For worker nodes: Follow worker node steps in README.md"
    echo ""
    exit 1
fi

# Generate recommendations based on node type and status
if [ "$NODE_TYPE" == "CONTROL" ]; then
    echo "This is the CONTROL NODE (uslvlbmsast035)"
    echo ""
    
    if [ "$PREP_DONE" == false ]; then
        echo "1️⃣  First: Prepare the node"
        echo "   Run: ./01-prepare-node.sh"
        echo ""
    fi
    
    if [ "$PREP_DONE" == true ] && [ "$FIREWALL_DONE" == false ]; then
        echo "2️⃣  Next: Configure firewall"
        echo "   Run: ./02-firewall-control.sh"
        echo ""
    fi
    
    if [ "$PREP_DONE" == true ] && [ "$FIREWALL_DONE" == true ] && [ "$K0S_INSTALLED" == false ]; then
        echo "3️⃣  Next: Install k0s control plane"
        echo "   Run: ./03-install-control.sh"
        echo ""
    fi
    
    if [ "$K0S_INSTALLED" == true ]; then
        echo "4️⃣  Next: Generate worker token"
        echo "   Run: ./05-generate-token.sh"
        echo ""
        echo "5️⃣  Then: Copy token to worker nodes"
        echo "   scp /tmp/worker-token.txt worker-node:/tmp/"
        echo ""
        echo "6️⃣  After workers join: Verify cluster"
        echo "   Run: ./06-verify-cluster.sh"
        echo ""
        echo "7️⃣  Optional: Test deployment"
        echo "   Run: ./07-test-deployment.sh"
        echo ""
    fi

elif [ "$NODE_TYPE" == "WORKER" ]; then
    echo "This is a WORKER NODE"
    echo ""
    
    if [ "$PREP_DONE" == false ]; then
        echo "1️⃣  First: Prepare the node"
        echo "   Run: ./01-prepare-node.sh"
        echo ""
    fi
    
    if [ "$PREP_DONE" == true ] && [ "$FIREWALL_DONE" == false ]; then
        echo "2️⃣  Next: Configure firewall"
        echo "   Run: ./02-firewall-worker.sh"
        echo ""
    fi
    
    if [ "$PREP_DONE" == true ] && [ "$FIREWALL_DONE" == true ] && [ "$K0S_INSTALLED" == false ]; then
        echo "3️⃣  Next: Get worker token from control node"
        echo "   Either:"
        echo "   - Copy: scp control-node:/tmp/worker-token.txt /tmp/"
        echo "   - Or manually create /tmp/worker-token.txt with token content"
        echo ""
        echo "4️⃣  Then: Install k0s worker"
        echo "   Run: ./04-install-worker.sh"
        echo ""
    fi
    
    if [ "$K0S_INSTALLED" == true ]; then
        echo "✓ Worker installation complete!"
        echo ""
        echo "Verify on control node:"
        echo "   kubectl get nodes"
        echo ""
    fi
fi

echo "========================================="
echo "Useful Commands:"
echo "========================================="
echo ""
echo "Check status:           ./09-troubleshoot.sh"
echo "View logs:              sudo journalctl -u k0s[controller|worker] -f"
if [ "$K0S_INSTALLED" == true ]; then
    echo "k0s status:             sudo k0s status"
fi
if [ "$NODE_TYPE" == "CONTROL" ] && [ "$K0S_INSTALLED" == true ]; then
    echo "Cluster status:         kubectl get nodes"
fi
echo ""
