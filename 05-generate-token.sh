#!/bin/bash
#
# Generate Worker Token
# Run this on the CONTROL node (uslvlbmsast035) to generate worker join token
#

set -e

TOKEN_FILE="/tmp/worker-token.txt"

echo "========================================="
echo "k0s Worker Token Generator"
echo "========================================="

# Generate worker token
echo "Generating worker join token..."
sudo k0s token create --role=worker > "$TOKEN_FILE"

if [ ! -s "$TOKEN_FILE" ]; then
    echo "ERROR: Failed to generate token"
    exit 1
fi

echo "✓ Worker token generated successfully!"
echo ""
echo "Token saved to: $TOKEN_FILE"
echo ""
echo "========================================="
echo "Token content:"
echo "========================================="
cat "$TOKEN_FILE"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Copy this token to your worker nodes using one of these methods:"
echo ""
echo "     Method 1 - SCP:"
echo "       scp $TOKEN_FILE worker-node:/tmp/"
echo ""
echo "     Method 2 - Manual:"
echo "       - Copy the token content above"
echo "       - On worker node, create /tmp/worker-token.txt and paste it"
echo ""
echo "  2. On each worker node, run: ./04-install-worker.sh"
echo ""
echo "Token file location on this node: $TOKEN_FILE"
echo "========================================="
