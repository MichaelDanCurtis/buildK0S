#!/bin/bash
#
# Make all scripts executable
# Run this first after copying scripts to each node
#

echo "Making all k0s scripts executable..."

chmod +x 01-prepare-node.sh
chmod +x 02-firewall-control.sh
chmod +x 02-firewall-worker.sh
chmod +x 03-install-control.sh
chmod +x 04-install-worker.sh
chmod +x 05-generate-token.sh
chmod +x 06-verify-cluster.sh
chmod +x 07-test-deployment.sh
chmod +x 08-cleanup-test.sh
chmod +x 09-troubleshoot.sh
chmod +x 10-uninstall.sh

echo "✓ All scripts are now executable"
echo ""
echo "Next steps:"
echo "  1. Run: ./01-prepare-node.sh (on all nodes)"
echo "  2. Run: ./02-firewall-control.sh (on control node)"
echo "     OR: ./02-firewall-worker.sh (on worker nodes)"
echo ""
echo "See README.md for complete installation instructions"
