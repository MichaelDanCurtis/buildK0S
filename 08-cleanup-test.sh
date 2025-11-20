#!/bin/bash
#
# Cleanup Test Deployment
# Run this on the CONTROL node to remove the test nginx deployment
#

echo "========================================="
echo "Cleaning up test deployment"
echo "========================================="
echo ""

# Delete service
echo "Deleting nginx test service..."
kubectl delete svc nginx-test-svc 2>/dev/null || echo "Service not found (may already be deleted)"

# Delete deployment
echo "Deleting nginx test deployment..."
kubectl delete deployment nginx-test 2>/dev/null || echo "Deployment not found (may already be deleted)"

echo ""
echo "Waiting for resources to be removed..."
sleep 5

echo ""
echo "========================================="
echo "Cleanup complete!"
echo "========================================="
echo ""
echo "Remaining deployments:"
kubectl get deployments
echo ""
echo "Remaining services:"
kubectl get svc
echo ""
