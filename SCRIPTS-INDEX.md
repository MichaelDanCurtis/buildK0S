# k0s RHEL 9 Installation Scripts - Complete Index

## 📦 Package Contents

This package contains all necessary scripts to deploy a k0s Kubernetes cluster on RHEL 9.

## 📋 Script Inventory

### Setup Scripts (Run in Order)

| # | Script | Purpose | Run On | Size |
|---|--------|---------|--------|------|
| 00 | `00-make-executable.sh` | Makes all scripts executable | All nodes | 777B |
| 01 | `01-prepare-node.sh` | System preparation (swap, kernel modules, sysctl) | All nodes | 1.4K |
| 02a | `02-firewall-control.sh` | Configure firewall for control plane | Control node | 1.4K |
| 02b | `02-firewall-worker.sh` | Configure firewall for workers | Worker nodes | 1.1K |
| 03 | `03-install-control.sh` | Install k0s controller | Control node | 2.2K |
| 04 | `04-install-worker.sh` | Install k0s worker | Worker nodes | 2.1K |
| 05 | `05-generate-token.sh` | Generate worker join token | Control node | 1.3K |

### Verification & Testing Scripts

| # | Script | Purpose | Run On | Size |
|---|--------|---------|--------|------|
| 06 | `06-verify-cluster.sh` | Comprehensive cluster verification | Control node | 2.7K |
| 07 | `07-test-deployment.sh` | Deploy test nginx application | Control node | 1.9K |
| 08 | `08-cleanup-test.sh` | Remove test deployment | Control node | 889B |

### Maintenance & Utility Scripts

| # | Script | Purpose | Run On | Size |
|---|--------|---------|--------|------|
| 09 | `09-troubleshoot.sh` | Diagnostic and troubleshooting tool | Any node | 5.8K |
| 10 | `10-uninstall.sh` | Complete k0s removal (with confirmation) | Any node | 3.8K |
| 11 | `11-setup-helper.sh` | Smart helper - detects node and suggests next steps | Any node | 5.3K |
| 99 | `99-package-scripts.sh` | Package all scripts for distribution | Dev machine | 1.8K |

### Documentation

| File | Purpose | Size |
|------|---------|------|
| `README.md` | Complete installation guide with troubleshooting | ~15K |
| `QUICK-REFERENCE.md` | Quick reference card for commands and procedures | ~5K |
| `SCRIPTS-INDEX.md` | This file - complete script inventory | ~2K |

## 🚀 Quick Start

### First Time Setup

1. **Extract package on all nodes:**
   ```bash
   tar -xzf k0s-rhel9-scripts_*.tar.gz
   cd k0s-rhel9-scripts/
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x 00-make-executable.sh
   ./00-make-executable.sh
   ```

3. **Get smart recommendations:**
   ```bash
   ./11-setup-helper.sh
   ```
   This will detect your node type and tell you exactly what to run next!

### Control Node (uslvlbmsast035)

```bash
./01-prepare-node.sh          # Prepare system
./02-firewall-control.sh      # Configure firewall
./03-install-control.sh       # Install k0s
./05-generate-token.sh        # Generate worker token
./06-verify-cluster.sh        # Verify after workers join
```

### Worker Nodes (uslvlbmsast036, uslvlbmsast037)

```bash
./01-prepare-node.sh          # Prepare system
./02-firewall-worker.sh       # Configure firewall
# Copy token from control node to /tmp/worker-token.txt
./04-install-worker.sh        # Install k0s worker
```

## 🔍 Script Descriptions

### 00-make-executable.sh
Makes all scripts executable with proper permissions. Run this first after extracting the package.

### 01-prepare-node.sh
Prepares the system for k0s by:
- Updating system packages
- Disabling swap permanently
- Loading kernel modules (overlay, br_netfilter)
- Configuring sysctl parameters
- Installing required packages

### 02-firewall-control.sh
Opens required ports on control node:
- 6443 (Kubernetes API)
- 2380/2381 (etcd)
- 8132 (Konnectivity)
- 9443 (k0s API)
- 10250 (kubelet)

### 02-firewall-worker.sh
Opens required ports on worker nodes:
- 10250 (kubelet)
- 8132 (Konnectivity)
- 30000-32767 (NodePort services)

### 03-install-control.sh
Installs k0s as a controller:
- Downloads k0s binary
- Installs as systemd service
- Configures kubeconfig
- Installs kubectl
- Enables auto-start on boot

### 04-install-worker.sh
Installs k0s as a worker:
- Downloads k0s binary
- Joins cluster using token
- Configures as systemd service
- Enables auto-start on boot

### 05-generate-token.sh
Generates a worker join token that:
- Can be used multiple times
- Must be copied to worker nodes
- Is required for workers to join cluster

### 06-verify-cluster.sh
Comprehensive verification that checks:
- k0s status
- All nodes present and ready
- System pods running
- Cluster connectivity
- Any issues or warnings

### 07-test-deployment.sh
Deploys a test nginx application:
- Creates deployment with 2 replicas
- Exposes via NodePort
- Provides access URLs
- Tests cluster functionality

### 08-cleanup-test.sh
Removes the test deployment cleanly.

### 09-troubleshoot.sh
Diagnostic tool that checks:
- System information
- Service status and logs
- Kernel modules
- Firewall configuration
- Network connectivity
- Resource usage
- SELinux status

### 10-uninstall.sh
Complete removal of k0s:
- Stops services
- Runs k0s reset
- Removes binaries
- Cleans data directories
- Optional: removes kernel config
- Requires confirmation

### 11-setup-helper.sh
Intelligent helper that:
- Detects which node you're on
- Checks what's already done
- Suggests next steps
- Provides context-aware guidance

### 99-package-scripts.sh
Creates a distributable tarball:
- Bundles all scripts and docs
- Creates timestamped archive
- Provides extraction instructions

## 📊 Execution Flow

```
┌─────────────────────────────────────────┐
│         Extract & Setup                 │
│  00-make-executable.sh (all nodes)      │
└──────────────────┬──────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
  ┌──────────┐         ┌──────────┐
  │ Control  │         │  Worker  │
  └────┬─────┘         └────┬─────┘
       │                    │
       │ 01-prepare-node    │ 01-prepare-node
       │ 02-firewall-ctrl   │ 02-firewall-wrkr
       │ 03-install-ctrl    │
       │ 05-generate-token  │
       │        │           │
       │        └───token───┤
       │                    │ 04-install-worker
       │                    │
       └────────┬───────────┘
                │
         06-verify-cluster
                │
         07-test-deployment
                │
         08-cleanup-test
```

## 🎯 Node Configuration

```
Control Node: uslvlbmsast035.net.bms.com
IP: 140.176.201.59
Role: k0s controller, kubectl access point

Worker Node 1: uslvlbmsast036.net.bms.com
IP: 140.176.201.60
Role: k0s worker

Worker Node 2: uslvlbmsast037.net.bms.com
IP: 140.176.201.61
Role: k0s worker
```

## 🔧 Maintenance Commands

### Check Status
```bash
./09-troubleshoot.sh              # Any node
./06-verify-cluster.sh            # Control node
```

### View Logs
```bash
sudo journalctl -u k0scontroller -f    # Control node
sudo journalctl -u k0sworker -f        # Worker nodes
```

### Restart Services
```bash
sudo systemctl restart k0scontroller   # Control node
sudo systemctl restart k0sworker       # Worker nodes
```

## 📚 Additional Resources

- Full documentation: `README.md`
- Quick reference: `QUICK-REFERENCE.md`
- k0s official docs: https://docs.k0sproject.io/
- Troubleshooting: Run `./09-troubleshoot.sh`

## ⚠️ Important Notes

1. **Always run 00-make-executable.sh first** after extracting the package
2. **Run 01-prepare-node.sh on ALL nodes** before proceeding
3. **Copy the worker token** from control to workers manually
4. **Firewall scripts differ** between control and worker nodes
5. **Use 11-setup-helper.sh** when unsure what to do next
6. **Run 06-verify-cluster.sh** after all nodes join to confirm status

## 🆘 Getting Help

1. Run `./11-setup-helper.sh` - Smart helper with context-aware guidance
2. Run `./09-troubleshoot.sh` - Comprehensive diagnostic tool
3. Check `README.md` - Detailed troubleshooting section
4. Check `QUICK-REFERENCE.md` - Common commands and solutions

## 📝 Version Info

- Target OS: RHEL 9
- k0s Version: Latest (downloaded at runtime)
- Cluster Type: Single control plane with 2 workers
- Network Plugin: Default (kube-router)

---

**Last Updated**: 2024
**Cluster**: BMS k0s Deployment
