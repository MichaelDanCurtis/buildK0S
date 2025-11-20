#!/bin/bash
#
# k0s Cluster Verification Script
# Run this on the CONTROL node to verify cluster status
#

echo "========================================="
echo "k0s Cluster Verification"
echo "========================================="
echo ""

# Check k0s status
echo "1. k0s Status:"
echo "----------------------------------------"
sudo k0s status
echo ""

# Check nodes
echo "2. Cluster Nodes:"
echo "----------------------------------------"
kubectl get nodes -o wide
echo ""

# Check system pods
echo "3. System Pods:"
echo "----------------------------------------"
kubectl get pods -A
echo ""

# Check cluster info
echo "4. Cluster Info:"
echo "----------------------------------------"
kubectl cluster-info
echo ""

# Check component status
echo "5. Component Status:"
echo "----------------------------------------"
kubectl get componentstatuses 2>/dev/null || echo "Component status API not available (this is normal for k0s)"
echo ""

# Check services
echo "6. Services:"
echo "----------------------------------------"
kubectl get svc -A
echo ""

# Node capacity
echo "7. Node Resources:"
echo "----------------------------------------"
kubectl top nodes 2>/dev/null || echo "Metrics server not installed (optional)"
echo ""

# Check for any issues
echo "8. Checking for Issues:"
echo "----------------------------------------"
NOT_READY=$(kubectl get nodes | grep -c "NotReady" || true)
if [ "$NOT_READY" -gt 0 ]; then
    echo "⚠ WARNING: $NOT_READY node(s) not ready!"
    echo ""
    echo "Not ready nodes:"
    kubectl get nodes | grep "NotReady"
else
    echo "✓ All nodes are ready!"
fi
echo ""

# Check for pending pods
PENDING_PODS=$(kubectl get pods -A | grep -c "Pending" || true)
if [ "$PENDING_PODS" -gt 0 ]; then
    echo "⚠ WARNING: $PENDING_PODS pod(s) in pending state!"
    echo ""
    echo "Pending pods:"
    kubectl get pods -A | grep "Pending"
else
    echo "✓ No pending pods"
fi
echo ""

# Expected nodes count
EXPECTED_NODES=3
ACTUAL_NODES=$(kubectl get nodes --no-headers | wc -l)
if [ "$ACTUAL_NODES" -eq "$EXPECTED_NODES" ]; then
    echo "✓ All $EXPECTED_NODES nodes are present in the cluster"
else
    echo "⚠ WARNING: Expected $EXPECTED_NODES nodes, but found $ACTUAL_NODES"
fi
echo ""

echo "========================================="
echo "Verification Complete!"
echo "========================================="
echo ""
echo "Cluster Summary:"
echo "  Control Node: uslvlbmsast035.net.bms.com (140.176.201.59)"
echo "  Worker Nodes: uslvlbmsast036.net.bms.com (140.176.201.60)"
echo "                uslvlbmsast037.net.bms.com (140.176.201.61)"
echo "  Total Nodes: $ACTUAL_NODES/$EXPECTED_NODES"
echo ""
