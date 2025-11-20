#!/bin/bash
#
# k0s Worker Node Installation
# Run this on WORKER nodes (uslvlbmsast036, uslvlbmsast037)
#
# PREREQUISITES: 
#   - Place the worker token in /tmp/worker-token.txt
#   - Token can be generated on control node using: 05-generate-token.sh
#

set -e

TOKEN_FILE="/tmp/worker-token.txt"

echo "========================================="
echo "k0s Worker Node Installation"
echo "========================================="

# Check if token file exists
if [ ! -f "$TOKEN_FILE" ]; then
    echo "ERROR: Worker token not found at $TOKEN_FILE"
    echo ""
    echo "Please follow these steps:"
    echo "  1. On control node, run: ./05-generate-token.sh"
    echo "  2. Copy the token to this node:"
    echo "     scp control-node:/tmp/worker-token.txt /tmp/"
    echo "  OR manually create /tmp/worker-token.txt and paste the token"
    echo ""
    exit 1
fi

# Verify token is not empty
if [ ! -s "$TOKEN_FILE" ]; then
    echo "ERROR: Token file is empty at $TOKEN_FILE"
    exit 1
fi

echo "✓ Found worker token"

# Download k0s
echo "[1/5] Downloading k0s..."
curl -sSLf https://get.k0s.sh | sudo sh

# Verify k0s installation
echo "[2/5] Verifying k0s installation..."
k0s version

# Install k0s as worker
echo "[3/5] Installing k0s as worker..."
sudo k0s install worker --token-file "$TOKEN_FILE"

# Start k0s worker
echo "[4/5] Starting k0s worker..."
sudo systemctl start k0sworker

# Enable k0s on boot
echo "[5/5] Enabling k0s to start on boot..."
sudo systemctl enable k0sworker

# Wait for worker to be ready
echo ""
echo "Waiting for worker to initialize (30 seconds)..."
sleep 30

echo ""
echo "========================================="
echo "Worker node installation completed!"
echo "========================================="
echo ""
echo "k0s Worker Status:"
sudo systemctl status k0sworker --no-pager
echo ""
echo "To verify the node joined the cluster:"
echo "  Run on control node: kubectl get nodes"
echo ""
echo "To view worker logs:"
echo "  sudo journalctl -u k0sworker -f"
echo "========================================="
