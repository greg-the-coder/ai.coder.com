# Pre-Workshop Validation Checklist

**Workshop Date**: _________________  
**Expected Participants**: _________________  
**Validated By**: _________________  
**Validation Date**: _________________  

## Purpose

This checklist ensures all systems are operational and properly configured before each monthly workshop. Complete this checklist **2 days before** the workshop.

---

## 1. Authentication & Access

### LiteLLM Keys

- [ ] **Check key expiration**: Keys must be valid for >7 days
  ```bash
  # Command to check key expiration
  # TODO: Add specific command for your environment
  ```
- [ ] **Result**: Expires on: _________________
- [ ] **Action Required**: If <7 days, rotate keys using documented procedure

### GitHub OAuth

- [ ] **Test GitHub authentication** for internal users (Okta flow)
- [ ] **Test GitHub authentication** for external users (GitHub direct)
- [ ] **Verify coder-contrib org access** for test external account

---

## 2. Multi-Region Infrastructure

### Image Consistency

- [ ] **Control Plane** - Verify Coder image version:
  ```bash
  # kubectl get pods -n coder -o jsonpath='{.items[*].spec.containers[*].image}'
  ```
  - Image: _________________
  - Tag/Digest: _________________

- [ ] **Oregon Proxy Cluster** - Verify Coder image version:
  - Image: _________________
  - Tag/Digest: _________________

- [ ] **London Proxy Cluster** - Verify Coder image version:
  - Image: _________________
  - Tag/Digest: _________________

- [ ] **Confirm all clusters use identical images**
- [ ] **Action Required**: If images differ, see Issue #2 for remediation

### Subdomain Routing

- [ ] **Test subdomain routing from Oregon**:
  ```bash
  # Example: curl https://test-workspace-oregon.ai.coder.com
  ```
  - Result: _________________

- [ ] **Test subdomain routing from London**:
  ```bash
  # Example: curl https://test-workspace-london.ai.coder.com
  ```
  - Result: _________________

- [ ] **Test subdomain routing from control plane**:
  - Result: _________________

---

## 3. Storage & Capacity

### Ephemeral Volume Storage

- [ ] **Check storage capacity per node**:
  ```bash
  # kubectl top nodes
  # df -h on relevant mount points
  ```

  **Node 1**: _________________% used  
  **Node 2**: _________________% used  
  **Node 3**: _________________% used  
  **Node N**: _________________% used  

- [ ] **All nodes <60% storage utilization**
- [ ] **Action Required**: If any node >60%, add capacity or rebalance workloads

### Resource Quotas

- [ ] **Verify workspace resource limits** are configured:
  - CPU limit per workspace: _________________
  - Memory limit per workspace: _________________
  - Storage limit per workspace: _________________

- [ ] **Calculate total capacity**:
  - Expected concurrent workspaces: _________________
  - Available capacity for concurrent workspaces: _________________
  - Headroom percentage: _________________

- [ ] **Headroom >30% for expected concurrent users**

---

## 4. Smoke Tests

### Control Plane Region

- [ ] **Create test workspace**
  - Workspace created successfully: ✅ / ❌
  - Time to ready: _________________

- [ ] **Execute workload in test workspace**
  - Workload executed successfully: ✅ / ❌
  - Performance acceptable: ✅ / ❌

- [ ] **Delete test workspace**
  - Workspace deleted successfully: ✅ / ❌
  - Resources cleaned up: ✅ / ❌

### Oregon Proxy Cluster

- [ ] **Create test workspace**
  - Workspace created successfully: ✅ / ❌
  - Time to ready: _________________

- [ ] **Execute workload in test workspace**
  - Workload executed successfully: ✅ / ❌
  - Performance acceptable: ✅ / ❌

- [ ] **Delete test workspace**
  - Workspace deleted successfully: ✅ / ❌
  - Resources cleaned up: ✅ / ❌

### London Proxy Cluster

- [ ] **Create test workspace**
  - Workspace created successfully: ✅ / ❌
  - Time to ready: _________________

- [ ] **Execute workload in test workspace**
  - Workload executed successfully: ✅ / ❌
  - Performance acceptable: ✅ / ❌

- [ ] **Delete test workspace**
  - Workspace deleted successfully: ✅ / ❌
  - Resources cleaned up: ✅ / ❌

---

## 5. Monitoring & Alerting

### Dashboard Validation

- [ ] **Real-time workshop dashboard** is accessible
- [ ] **All metrics** are populating correctly:
  - [ ] Ephemeral volume storage per node
  - [ ] Concurrent workspace count
  - [ ] Workspace restart/failure rate
  - [ ] Image pull times
  - [ ] LiteLLM key expiration
  - [ ] Subdomain routing success rate
  - [ ] Node resource utilization

### Alert Configuration

- [ ] **Test critical alerts** (trigger test alert):
  - [ ] Storage capacity threshold alert
  - [ ] Workspace failure rate alert
  - [ ] LiteLLM key expiration alert

- [ ] **Verify alert destinations** are correct (Slack, email, etc.)
- [ ] **Confirm on-call rotation** is updated

---

## 6. Documentation & Support

- [ ] **Workshop agenda** finalized and shared with participants
- [ ] **Participant onboarding guide** up to date
- [ ] **Incident runbook** accessible to workshop team
- [ ] **Support team** notified and available during workshop

---

## 7. Final Go/No-Go

**All checks passed**: ✅ / ❌

**If NO**:
- Document blockers: _________________
- Escalate to: _________________
- Decision: Proceed / Postpone

**If YES**:
- Workshop is **GO** ✅
- Checklist completion time: _________________
- Notes: _________________

---

## Post-Validation Actions

- [ ] Share checklist results with workshop team
- [ ] Update capacity planning based on validation results
- [ ] Address any warnings or minor issues before workshop
- [ ] Archive completed checklist for historical reference

---

**Completed By**: _________________  
**Sign-off**: _________________  
**Date**: _________________
