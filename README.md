# k0s Installation Scripts for RHEL 9

Automated installation scripts for deploying k0s Kubernetes on a 3-node RHEL 9 cluster.

## Cluster Configuration

- **Control Node**: uslvlbmsast035.net.bms.com (140.176.201.59)
- **Worker Node 1**: uslvlbmsast036.net.bms.com (140.176.201.60)
- **Worker Node 2**: uslvlbmsast037.net.bms.com (140.176.201.61)

## Prerequisites

- Root or sudo access on all nodes
- RHEL 9 installed on all nodes
- Network connectivity between all nodes
- Internet access for downloading k0s and dependencies

## Installation Steps

### Step 1: Prepare All Nodes

Run on **ALL** nodes (control and workers):

```bash
chmod +x 01-prepare-node.sh
./01-prepare-node.sh
```

This script will:
- Update system packages
- Disable swap
- Load required kernel modules
- Configure sysctl parameters
- Install required packages

### Step 2: Configure Firewall

**On the control node (uslvlbmsast035):**
```bash
chmod +x 02-firewall-control.sh
./02-firewall-control.sh
```

**On worker nodes (uslvlbmsast036, uslvlbmsast037):**
```bash
chmod +x 02-firewall-worker.sh
./02-firewall-worker.sh
```

### Step 3: Install Control Node

**On control node (uslvlbmsast035) only:**
```bash
chmod +x 03-install-control.sh
./03-install-control.sh
```

Wait for the control node installation to complete. This may take 2-3 minutes.

### Step 4: Generate Worker Token

**On control node (uslvlbmsast035):**
```bash
chmod +x 05-generate-token.sh
./05-generate-token.sh
```

This will generate a token and save it to `/tmp/worker-token.txt`.

### Step 5: Copy Token to Workers

Transfer the token to each worker node using one of these methods:

**Method 1 - SCP:**
```bash
# From control node
scp /tmp/worker-token.txt uslvlbmsast036:/tmp/
scp /tmp/worker-token.txt uslvlbmsast037:/tmp/
```

**Method 2 - Manual:**
1. Display token on control node: `cat /tmp/worker-token.txt`
2. On each worker, create file: `sudo vi /tmp/worker-token.txt`
3. Paste the token and save

### Step 6: Install Workers

**On each worker node (uslvlbmsast036, uslvlbmsast037):**
```bash
chmod +x 04-install-worker.sh
./04-install-worker.sh
```

Wait for each worker installation to complete (about 30-60 seconds per node).

### Step 7: Verify Cluster

**On control node (uslvlbmsast035):**
```bash
chmod +x 06-verify-cluster.sh
./06-verify-cluster.sh
```

All three nodes should show as "Ready".

## Testing the Cluster

### Deploy Test Application

**On control node:**
```bash
chmod +x 07-test-deployment.sh
./07-test-deployment.sh
```

This deploys a test nginx application and exposes it via NodePort.

### Cleanup Test Application

**On control node:**
```bash
chmod +x 08-cleanup-test.sh
./08-cleanup-test.sh
```

## Troubleshooting

### Run Troubleshooting Script

Can be run on any node:
```bash
chmod +x 09-troubleshoot.sh
./09-troubleshoot.sh
```

### Common Issues

**1. Worker won't join cluster**
- Verify firewall rules are applied on all nodes
- Test connectivity: `ping 140.176.201.59` from workers
- Check if port 6443 is reachable: `telnet 140.176.201.59 6443`
- Verify token is correct in `/tmp/worker-token.txt`
- Check worker logs: `sudo journalctl -u k0sworker -f`

**2. Swap is enabled**
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

**3. SELinux blocking k0s**
```bash
# Check status
sudo getenforce

# Temporarily disable (for testing)
sudo setenforce 0

# Permanently disable (if needed)
sudo vi /etc/selinux/config  # Set SELINUX=permissive or disabled
```

**4. Service fails to start**
```bash
# Control node
sudo journalctl -u k0scontroller -n 100 -f

# Worker node
sudo journalctl -u k0sworker -n 100 -f
```

**5. Nodes show as NotReady**
- Check kubelet logs on the affected node
- Verify network connectivity
- Ensure all required ports are open
- Check system resources (CPU, memory, disk)

## Useful Commands

### Control Node Commands
```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A
kubectl cluster-info

# Check k0s status
sudo k0s status
sudo systemctl status k0scontroller

# View logs
sudo journalctl -u k0scontroller -f

# Restart k0s
sudo systemctl restart k0scontroller

# Generate new worker token
sudo k0s token create --role=worker
```

### Worker Node Commands
```bash
# Check worker status
sudo systemctl status k0sworker

# View logs
sudo journalctl -u k0sworker -f

# Restart worker
sudo systemctl restart k0sworker
```

### kubectl Commands
```bash
# Get node details
kubectl get nodes -o wide

# Describe node (shows events and capacity)
kubectl describe node <node-name>

# Get all resources
kubectl get all -A

# Check pod logs
kubectl logs <pod-name> -n <namespace>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Delete stuck pod
kubectl delete pod <pod-name> --force --grace-period=0
```

## Uninstalling k0s

### On Control Node
```bash
chmod +x 10-uninstall.sh
./10-uninstall.sh
```

### On Worker Nodes
```bash
chmod +x 10-uninstall.sh
./10-uninstall.sh
```

**WARNING**: This will completely remove k0s and all data!

## Script Reference

| Script | Purpose | Run On |
|--------|---------|--------|
| `01-prepare-node.sh` | System preparation | All nodes |
| `02-firewall-control.sh` | Firewall setup for control | Control node |
| `02-firewall-worker.sh` | Firewall setup for worker | Worker nodes |
| `03-install-control.sh` | Install k0s controller | Control node |
| `04-install-worker.sh` | Install k0s worker | Worker nodes |
| `05-generate-token.sh` | Generate worker token | Control node |
| `06-verify-cluster.sh` | Verify cluster status | Control node |
| `07-test-deployment.sh` | Deploy test application | Control node |
| `08-cleanup-test.sh` | Remove test application | Control node |
| `09-troubleshoot.sh` | Diagnose issues | Any node |
| `10-uninstall.sh` | Uninstall k0s | Any node |

## Port Reference

### Control Node Ports
- 6443: Kubernetes API server
- 2380: etcd client communication
- 2381: etcd peer communication  
- 8132: Konnectivity server
- 9443: k0s API
- 10250: kubelet API

### Worker Node Ports
- 10250: kubelet API
- 8132: Konnectivity agent
- 30000-32767: NodePort services

## Additional Resources

- k0s Documentation: https://docs.k0sproject.io/
- k0s GitHub: https://github.com/k0sproject/k0s
- Kubernetes Documentation: https://kubernetes.io/docs/

## Support

For issues specific to these scripts, check:
1. Run `09-troubleshoot.sh` for automated diagnostics
2. Check service logs: `sudo journalctl -u k0s[controller|worker] -f`
3. Verify all prerequisites are met
4. Review the k0s documentation for advanced troubleshooting

## License

These scripts are provided as-is for setting up k0s on your specific cluster configuration.
