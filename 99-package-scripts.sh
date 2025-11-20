#!/bin/bash
#
# Package all k0s scripts for distribution
#

PACKAGE_NAME="k0s-rhel9-scripts"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${PACKAGE_NAME}_${TIMESTAMP}.tar.gz"

echo "========================================="
echo "k0s Scripts Packager"
echo "========================================="
echo ""

# Create list of files to package
FILES=(
    "README.md"
    "QUICK-REFERENCE.md"
    "00-make-executable.sh"
    "01-prepare-node.sh"
    "02-firewall-control.sh"
    "02-firewall-worker.sh"
    "03-install-control.sh"
    "04-install-worker.sh"
    "05-generate-token.sh"
    "06-verify-cluster.sh"
    "07-test-deployment.sh"
    "08-cleanup-test.sh"
    "09-troubleshoot.sh"
    "10-uninstall.sh"
    "11-setup-helper.sh"
)

echo "Packaging the following files:"
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (missing)"
    fi
done
echo ""

# Create the tarball
echo "Creating tarball: $OUTPUT_FILE"
tar -czf "$OUTPUT_FILE" "${FILES[@]}" 2>/dev/null

if [ $? -eq 0 ]; then
    SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    echo "✓ Package created successfully!"
    echo ""
    echo "========================================="
    echo "Package Information:"
    echo "========================================="
    echo "Filename: $OUTPUT_FILE"
    echo "Size: $SIZE"
    echo "Location: $(pwd)/$OUTPUT_FILE"
    echo ""
    echo "To extract on target nodes:"
    echo "  tar -xzf $OUTPUT_FILE"
    echo "  cd into the directory"
    echo "  Run: chmod +x 00-make-executable.sh && ./00-make-executable.sh"
    echo ""
    echo "To transfer to nodes:"
    echo "  scp $OUTPUT_FILE user@node:/tmp/"
    echo ""
else
    echo "✗ Failed to create package"
    exit 1
fi
