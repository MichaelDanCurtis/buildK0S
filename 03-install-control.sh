#!/bin/bash
#
# k0s Control Node Installation
# Run this ONLY on the CONTROL node (uslvlbmsast035)
#

set -e

KUBE_DIR="$HOME/.kube"

echo "========================================="
echo "k0s Control Node Installation"
echo "========================================="

# Download k0s
echo "[1/7] Downloading k0s..."
curl -sSLf https://get.k0s.sh | sudo sh

# Verify k0s installation
echo "[2/7] Verifying k0s installation..."
k0s version

# Install k0s as controller
echo "[3/7] Installing k0s as controller (single node control plane)..."
sudo k0s install controller --single

# Start k0s
echo "[4/7] Starting k0s controller..."
sudo systemctl start k0scontroller

# Enable k0s on boot
echo "[5/7] Enabling k0s to start on boot..."
sudo systemctl enable k0scontroller

# Wait for k0s to be ready
echo "[6/7] Waiting for k0s to be ready (this may take 1-2 minutes)..."
WAIT_TIME=2
MAX_WAIT=120
TOTAL_WAITED=0
while [ $TOTAL_WAITED -lt $MAX_WAIT ]; do
    if sudo k0s status 2>/dev/null | grep -q "Version:"; then
        echo "✓ k0s is ready!"
        break
    fi
    echo -n "."
    sleep $WAIT_TIME
    TOTAL_WAITED=$((TOTAL_WAITED + WAIT_TIME))
    # Exponential backoff: double wait time up to 10 seconds
    if [ $WAIT_TIME -lt 10 ]; then
        WAIT_TIME=$((WAIT_TIME * 2))
    fi
done
echo ""
if [ $TOTAL_WAITED -ge $MAX_WAIT ]; then
    echo "⚠ Warning: Timeout waiting for k0s to be ready. Continuing anyway..."
fi

# Create kubeconfig
echo "[7/7] Creating kubeconfig..."
mkdir -p "$KUBE_DIR"
sudo k0s kubeconfig admin | tee "$KUBE_DIR/config" > /dev/null
sudo chown "$(id -u):$(id -g)" "$KUBE_DIR/config"
chmod 600 "$KUBE_DIR/config"

# Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
    echo ""
    echo "Installing kubectl..."
    # Get kubectl version with retry
    for attempt in 1 2 3; do
        KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt 2>/dev/null)
        if [ -n "$KUBECTL_VERSION" ]; then
            break
        fi
        echo "Retry $attempt/3: Failed to get kubectl version, retrying..."
        sleep 2
    done
    
    if [ -z "$KUBECTL_VERSION" ]; then
        # Try to get version from the running k0s cluster as fallback
        KUBECTL_VERSION=$(sudo k0s kubectl version --client --short 2>/dev/null | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "")
        if [ -z "$KUBECTL_VERSION" ]; then
            echo "⚠ Warning: Could not determine kubectl version, using latest stable fallback"
            KUBECTL_VERSION="v1.31.0"
        else
            echo "Using kubectl version matching k0s: $KUBECTL_VERSION"
        fi
    fi
    
    # Download kubectl with retry
    for attempt in 1 2 3; do
        if curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" 2>/dev/null; then
            break
        fi
        echo "Retry $attempt/3: Failed to download kubectl, retrying..."
        sleep 2
    done
    
    if [ -f kubectl ]; then
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        echo "✓ kubectl installed"
    else
        echo "⚠ Warning: Failed to install kubectl. You can install it manually later."
    fi
fi

echo ""
echo "========================================="
echo "Control node installation completed!"
echo "========================================="
echo ""
echo "k0s Status:"
sudo k0s status
echo ""
echo "Cluster Info:"
kubectl cluster-info
echo ""
echo "Nodes:"
kubectl get nodes
echo ""
echo "========================================="
echo "Next steps:"
echo "  1. Generate worker token: ./05-generate-token.sh"
echo "  2. Copy token to worker nodes"
echo "  3. Run 04-install-worker.sh on each worker"
echo "========================================="
