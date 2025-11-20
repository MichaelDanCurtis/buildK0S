#!/bin/bash
#
# Download all files from MichaelDanCurtis/buildK0S GitHub repository
# This script uses wget to download all k0s installation scripts and documentation
#

set -e

# Configuration
GITHUB_USER="MichaelDanCurtis"
GITHUB_REPO="buildK0S"
GITHUB_BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Destination directory (default: current directory, or specify as argument)
DEST_DIR="${1:-.}"

echo "========================================="
echo "buildK0S Repository Downloader"
echo "========================================="
echo ""
echo "Source: https://github.com/${GITHUB_USER}/${GITHUB_REPO}"
echo "Branch: ${GITHUB_BRANCH}"
echo "Destination: ${DEST_DIR}"
echo ""

# Create destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo "Creating directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
fi

# Change to destination directory
cd "$DEST_DIR"

echo "Downloading files..."
echo ""

# List of all files in the repository
FILES=(
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
    "99-package-scripts.sh"
    "README.md"
    "QUICK-REFERENCE.md"
    "SCRIPTS-INDEX.md"
)

# Download each file
SUCCESS_COUNT=0
FAIL_COUNT=0

for file in "${FILES[@]}"; do
    printf "Downloading: %-30s ... " "$file"
    
    if wget -q "${BASE_URL}/${file}" -O "$file" 2>/dev/null; then
        echo "✓ OK"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "✗ FAILED"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done

echo ""
echo "========================================="
echo "Download Summary"
echo "========================================="
echo "Total files: ${#FILES[@]}"
echo "Downloaded successfully: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "Files downloaded to: $(pwd)"
    echo ""
    echo "Next steps:"
    echo "  1. Make scripts executable: chmod +x *.sh"
    echo "  2. Or run: chmod +x 00-make-executable.sh && ./00-make-executable.sh"
    echo "  3. Read README.md for installation instructions"
    echo ""
fi

if [ $FAIL_COUNT -gt 0 ]; then
    echo "⚠ Warning: Some files failed to download."
    echo "Please check your internet connection and try again."
    exit 1
fi

echo "========================================="
echo "Download complete!"
echo "========================================="
