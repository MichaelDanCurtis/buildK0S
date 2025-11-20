# k0s Quick Reference Card

## Node Information
```
Control: uslvlbmsast035.net.bms.com (140.176.201.59)
Worker1: uslvlbmsast036.net.bms.com (140.176.201.60)
Worker2: uslvlbmsast037.net.bms.com (140.176.201.61)
```

## Quick Installation (Copy & Paste)

### On ALL nodes:
```bash
chmod +x 00-make-executable.sh && ./00-make-executable.sh
./01-prepare-node.sh
```

### On Control Node (uslvlbmsast035):
```bash
./02-firewall-control.sh
./03-install-control.sh
./05-generate-token.sh
# Copy /tmp/worker-token.txt to workers
./06-verify-cluster.sh  # After workers join
```

### On Worker Nodes (uslvlbmsast036, uslvlbmsast037):
```bash
./02-firewall-worker.sh
# Ensure /tmp/worker-token.txt exists
./04-install-worker.sh
```

## Common kubectl Commands

### Cluster Status
```bash
kubectl get nodes                    # List all nodes
kubectl get nodes -o wide            # Detailed node info
kubectl get pods -A                  # All pods in all namespaces
kubectl get all -A                   # All resources
kubectl cluster-info                 # Cluster information
```

### Troubleshooting
```bash
kubectl describe node <name>         # Node details and events
kubectl describe pod <name> -n <ns>  # Pod details and events
kubectl logs <pod> -n <ns>           # View pod logs
kubectl logs <pod> -n <ns> -f        # Follow logs
kubectl get events -A                # All cluster events
kubectl top nodes                    # Node resource usage (if metrics-server installed)
```

### Deployments
```bash
kubectl create deployment <name> --image=<image>
kubectl scale deployment <name> --replicas=3
kubectl expose deployment <name> --port=80 --type=NodePort
kubectl delete deployment <name>
kubectl rollout status deployment <name>
kubectl rollout restart deployment <name>
```

## k0s Service Management

### Control Node
```bash
sudo systemctl status k0scontroller
sudo systemctl start k0scontroller
sudo systemctl stop k0scontroller
sudo systemctl restart k0scontroller
sudo journalctl -u k0scontroller -f
```

### Worker Node
```bash
sudo systemctl status k0sworker
sudo systemctl start k0sworker
sudo systemctl stop k0sworker
sudo systemctl restart k0sworker
sudo journalctl -u k0sworker -f
```

## k0s Commands

```bash
k0s version                          # Show version
sudo k0s status                      # Show cluster status
sudo k0s token create --role=worker  # Generate worker token
sudo k0s kubeconfig admin            # Display kubeconfig
sudo k0s reset                       # ⚠️ DANGER: Reset/uninstall k0s
```

## Port Reference

### Control Node
- 6443: Kubernetes API
- 2380/2381: etcd
- 8132: Konnectivity
- 9443: k0s API
- 10250: kubelet

### Worker Nodes
- 10250: kubelet
- 8132: Konnectivity
- 30000-32767: NodePort services

## Troubleshooting Quick Checks

### Node won't join
```bash
ping 140.176.201.59                  # Test connectivity
telnet 140.176.201.59 6443           # Test API port
sudo firewall-cmd --list-all         # Check firewall
cat /tmp/worker-token.txt            # Verify token exists
sudo journalctl -u k0sworker -n 50   # Check logs
```

### Service won't start
```bash
sudo systemctl status k0s[controller|worker]
sudo journalctl -u k0s[controller|worker] -n 100
swapon --show                        # Verify swap is off
df -h                                # Check disk space
free -h                              # Check memory
```

### Pods stuck pending
```bash
kubectl describe pod <pod-name>
kubectl get events -A --sort-by='.lastTimestamp'
kubectl get nodes -o wide
kubectl describe nodes
```

## File Locations

```
k0s binary:       /usr/local/bin/k0s
k0s data:         /var/lib/k0s
k0s config:       /etc/k0s
kubeconfig:       ~/.kube/config
worker token:     /tmp/worker-token.txt
logs:             journalctl -u k0s[controller|worker]
```

## Emergency Procedures

### Restart entire cluster
```bash
# On each worker:
sudo systemctl restart k0sworker

# On control node:
sudo systemctl restart k0scontroller

# Wait and verify:
kubectl get nodes
```

### Remove stuck pod
```bash
kubectl delete pod <pod-name> --force --grace-period=0 -n <namespace>
```

### Regenerate worker token
```bash
# On control node:
sudo k0s token create --role=worker > /tmp/worker-token.txt
# Copy to workers and reinstall
```

### Complete reset
```bash
# ⚠️ WARNING: Destroys all data
./10-uninstall.sh
# Then reinstall from scratch
```

## Testing

### Deploy test app
```bash
./07-test-deployment.sh              # Deploy nginx test
curl http://140.176.201.59:<port>    # Test access
./08-cleanup-test.sh                 # Clean up
```

### Verify cluster health
```bash
./06-verify-cluster.sh               # Run verification
./09-troubleshoot.sh                 # Diagnostic info
```

## Useful one-liners

```bash
# Watch nodes
watch kubectl get nodes

# Watch all pods
watch kubectl get pods -A

# Check all pod statuses
kubectl get pods -A --field-selector=status.phase!=Running

# Get all container images in use
kubectl get pods -A -o jsonpath="{.items[*].spec.containers[*].image}" | tr -s '[[:space:]]' '\n' | sort | uniq

# Get node resource usage
kubectl top nodes

# Force delete namespace
kubectl delete namespace <name> --force --grace-period=0
```
