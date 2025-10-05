# Workshop Incident Runbook

## Purpose

This runbook provides step-by-step procedures for diagnosing and resolving common incidents during monthly workshops.

---

## Incident Response Process

### 1. Initial Response

1. **Acknowledge** the incident in team chat
2. **Assess severity**:
   - **P0 (Critical)**: Complete service outage, data loss, security breach
   - **P1 (High)**: Significant degradation affecting multiple users
   - **P2 (Medium)**: Limited impact, workarounds available
   - **P3 (Low)**: Cosmetic issues, no user impact
3. **Assign incident commander** (P0/P1 only)
4. **Start incident log** (document timeline, actions, decisions)

### 2. Communication

- **Internal**: Update team in dedicated incident channel
- **Participants**: Provide status updates if impact is user-visible
- **Escalation**: Contact on-call engineer for P0/P1 incidents

### 3. Resolution & Follow-up

- Document root cause
- Create GitHub issue for permanent fix
- Update this runbook if new incident type discovered
- Include incident in post-workshop retrospective

---

## Common Incidents

### 1. Workspace Restarts / Self-Healing Loop

**Symptoms**:
- Workspaces repeatedly restarting
- Users losing progress
- Self-healing mechanisms triggering continuously

**Likely Causes**:
- Ephemeral volume storage exhaustion
- Resource contention (CPU, memory)
- Node capacity exceeded

**Diagnosis**:

```bash
# Check node storage
kubectl top nodes
kubectl get nodes -o wide

# Check ephemeral volume usage
kubectl get pods -A -o json | jq '.items[] | select(.spec.volumes != null) | {name: .metadata.name, namespace: .metadata.namespace, volumes: [.spec.volumes[] | select(.emptyDir != null)]}'

# Check for evicted pods
kubectl get pods -A | grep Evicted

# Check workspace pod events
kubectl describe pod <workspace-pod-name> -n <namespace>

# Check Karpenter node allocation
kubectl logs -l app.kubernetes.io/name=karpenter -n karpenter --tail=100
```

**Resolution**:

**Immediate**:
1. Identify workspaces consuming excessive storage:
   ```bash
   kubectl exec -it <workspace-pod> -- df -h
   ```
2. If specific workspace is problematic, delete it:
   ```bash
   kubectl delete pod <workspace-pod> -n <namespace>
   ```
3. If cluster-wide issue, scale up nodes or increase storage capacity

**Temporary Workaround**:
- Pause new workspace deployments
- Ask participants to save work and stop workspaces
- Clean up unused workspaces

**Permanent Fix**:
- See GitHub Issue #1 for long-term storage optimization

---

### 2. Subdomain Routing Failures

**Symptoms**:
- Users cannot access workspaces via subdomain URLs
- 404 or DNS errors on workspace URLs
- Inconsistent routing across regions

**Likely Causes**:
- Image version mismatch between control plane and proxy clusters
- Ingress controller misconfiguration
- DNS propagation delays

**Diagnosis**:

```bash
# Check Coder image versions across clusters
kubectl get pods -n coder -o jsonpath='{.items[*].spec.containers[*].image}' --context=control-plane
kubectl get pods -n coder -o jsonpath='{.items[*].spec.containers[*].image}' --context=oregon
kubectl get pods -n coder -o jsonpath='{.items[*].spec.containers[*].image}' --context=london

# Check ingress configuration
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n <namespace>

# Check DNS resolution
dig <workspace-subdomain>.ai.coder.com
nslookup <workspace-subdomain>.ai.coder.com

# Check load balancer status
kubectl get svc -n coder
```

**Resolution**:

**Immediate**:
1. Verify image versions match across clusters
2. If mismatch found, restart Coder pods in affected cluster:
   ```bash
   kubectl rollout restart deployment/coder -n coder
   ```
3. If DNS issue, wait for propagation or flush DNS cache

**Temporary Workaround**:
- Direct users to working region
- Use direct IP access if subdomain fails

**Permanent Fix**:
- See GitHub Issue #2 for image management standardization

---

### 3. LiteLLM Authentication Failures

**Symptoms**:
- Users cannot authenticate
- "Invalid API key" or similar errors
- AI features not working

**Likely Causes**:
- Expired LiteLLM key
- Rate limiting
- Service outage

**Diagnosis**:

```bash
# Check LiteLLM pod logs
kubectl logs -l app=litellm -n <namespace> --tail=100

# Test LiteLLM API key
curl -H "Authorization: Bearer <api-key>" https://<litellm-endpoint>/v1/models

# Check key expiration (method depends on your key management)
# TODO: Add specific command for your environment
```

**Resolution**:

**Immediate**:
1. Verify key expiration date
2. If expired, rotate key immediately:
   ```bash
   # Follow your key rotation procedure
   # Update secret:
   kubectl create secret generic litellm-key \
     --from-literal=api-key=<new-key> \
     --dry-run=client -o yaml | kubectl apply -f -
   
   # Restart LiteLLM pods
   kubectl rollout restart deployment/litellm -n <namespace>
   ```

**Temporary Workaround**:
- If brief expiration, wait for key rotation
- Disable AI features temporarily if critical

**Permanent Fix**:
- See GitHub Issue #3 for key rotation automation

---

### 4. High Resource Contention

**Symptoms**:
- Slow workspace performance
- Timeouts during operations
- Elevated CPU/memory usage across cluster

**Likely Causes**:
- Too many concurrent workspaces
- Workload-heavy exercises
- Insufficient node capacity

**Diagnosis**:

```bash
# Check cluster resource usage
kubectl top nodes
kubectl top pods -A

# Check Karpenter scaling
kubectl get nodeclaims -A
kubectl logs -l app.kubernetes.io/name=karpenter -n karpenter --tail=50

# Check pod resource limits
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Limits\|Requests"
```

**Resolution**:

**Immediate**:
1. Trigger Karpenter to scale up nodes if not auto-scaling:
   ```bash
   # Check Karpenter NodePool status
   kubectl get nodepool
   ```
2. If nodes are at capacity, consider increasing instance sizes
3. Identify and pause resource-heavy workloads

**Temporary Workaround**:
- Reduce concurrent workspace count
- Switch to less resource-intensive exercises
- Stagger workspace deployments

**Permanent Fix**:
- Adjust resource limits per workspace
- Implement better capacity planning (see Issue #1)
- Add resource monitoring alerts (see Issue #6)

---

### 5. Image Pull Failures

**Symptoms**:
- Workspaces stuck in "ContainerCreating" state
- ImagePullBackOff errors
- Slow workspace startup times

**Likely Causes**:
- Registry authentication issues
- Network connectivity problems
- Rate limiting from container registry
- Image doesn't exist or incorrect tag

**Diagnosis**:

```bash
# Check pod status
kubectl get pods -A | grep -E 'ImagePull|ErrImagePull'

# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check image pull secrets
kubectl get secrets -A | grep docker

# Verify image exists
docker pull <image-name>:<tag>
# or
crane manifest <image-name>:<tag>
```

**Resolution**:

**Immediate**:
1. Verify registry credentials are valid:
   ```bash
   kubectl get secret <image-pull-secret> -n <namespace> -o jsonpath='{.data.dockerconfigjson}' | base64 -d
   ```
2. Re-create image pull secret if expired:
   ```bash
   kubectl create secret docker-registry <secret-name> \
     --docker-server=<registry> \
     --docker-username=<username> \
     --docker-password=<password> \
     -n <namespace>
   ```
3. Restart affected pods

**Temporary Workaround**:
- Use cached images if available
- Switch to alternative image registry

**Permanent Fix**:
- Implement image pre-caching on nodes
- Use image pull secrets with longer expiration
- See GitHub Issue #2 for image management improvements

---

## Emergency Contacts

| Role | Name | Contact |
|------|------|--------|
| Infrastructure Lead | | |
| On-Call Engineer | | |
| Platform Team Lead | | |
| Escalation Contact | jullian@coder.com | |

---

## Post-Incident Checklist

- [ ] Incident resolved and documented
- [ ] Root cause identified
- [ ] GitHub issue created for permanent fix
- [ ] Runbook updated with new learnings
- [ ] Team notified of resolution
- [ ] Participants notified if impacted
- [ ] Incident added to post-workshop retrospective

---

## Related Resources

- [Monthly Workshop Guide](./MONTHLY_WORKSHOP_GUIDE.md)
- [Pre-Workshop Checklist](./PRE_WORKSHOP_CHECKLIST.md)
- [Post-Workshop Retrospective Template](./POST_WORKSHOP_RETROSPECTIVE.md)
- GitHub Issues: [#1](https://github.com/coder/ai.coder.com/issues/1) [#2](https://github.com/coder/ai.coder.com/issues/2) [#3](https://github.com/coder/ai.coder.com/issues/3) [#6](https://github.com/coder/ai.coder.com/issues/6)
