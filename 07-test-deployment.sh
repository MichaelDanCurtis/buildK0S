#!/bin/bash
#
# k0s Test Deployment Script
# Run this on the CONTROL node to deploy a test application
#

set -e

echo "========================================="
echo "k0s Test Deployment"
echo "========================================="
echo ""

# Deploy nginx
echo "[1/4] Deploying nginx test application..."
kubectl create deployment nginx-test --image=nginx:latest --replicas=2

# Wait for deployment
echo "[2/4] Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/nginx-test

# Expose service
echo "[3/4] Exposing nginx service on NodePort..."
kubectl expose deployment nginx-test --port=80 --type=NodePort --name=nginx-test-svc

# Get service details
echo "[4/4] Getting service details..."
sleep 5

echo ""
echo "========================================="
echo "Test Deployment Complete!"
echo "========================================="
echo ""

# Show deployment status
echo "Deployment Status:"
kubectl get deployment nginx-test
echo ""

echo "Pods:"
kubectl get pods -l app=nginx-test -o wide
echo ""

echo "Service:"
kubectl get svc nginx-test-svc
echo ""

# Get NodePort
NODEPORT=$(kubectl get svc nginx-test-svc -o jsonpath='{.spec.ports[0].nodePort}')
echo "========================================="
echo "Test Access Information"
echo "========================================="
echo ""
echo "The nginx service is available on NodePort: $NODEPORT"
echo ""
echo "You can access it from any of these URLs:"
echo "  http://140.176.201.59:$NODEPORT"
echo "  http://140.176.201.60:$NODEPORT"
echo "  http://140.176.201.61:$NODEPORT"
echo ""
echo "Test from command line:"
echo "  curl http://140.176.201.59:$NODEPORT"
echo ""
echo "To view logs:"
echo "  kubectl logs -l app=nginx-test"
echo ""
echo "To clean up this test deployment:"
echo "  ./08-cleanup-test.sh"
echo ""
echo "========================================="
