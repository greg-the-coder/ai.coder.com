# Monthly Workshop Guide

## Overview

This guide outlines the process for planning, executing, and following up on monthly Agentic Workshops for https://ai.coder.com.

## Purpose

Monthly workshops serve multiple objectives:

- **Stress Testing**: Validate platform stability under realistic concurrent user load
- **Continuous Improvement**: Surface optimization opportunities through real-world usage
- **User Feedback**: Gather insights from both internal and external users
- **Regression Prevention**: Ensure previous fixes remain stable and new features don't introduce issues

## Target Audience

- **Internal Users**: Coder employees testing new features and improvements
- **External Users**: Members of the coder-contrib GitHub organization
- **Target Concurrent Users**: 10-20+ simultaneous participants

## Workshop Schedule

**Cadence**: Monthly (first week of each month recommended)
**Duration**: 60-90 minutes
**Time**: Choose time that accommodates both US and international participants

## Pre-Workshop Checklist (T-7 days)

### 1. Scheduling & Communication

- [ ] Schedule workshop date/time (send calendar invite)
- [ ] Create registration form to track expected attendance
- [ ] Send announcement to internal team and coder-contrib organization
- [ ] Prepare workshop agenda and share with participants (T-3 days)
- [ ] Send reminder 24 hours before workshop

### 2. Infrastructure Validation (T-2 days)

Complete the [Pre-Workshop Validation Checklist](./PRE_WORKSHOP_CHECKLIST.md) which includes:

- [ ] LiteLLM authentication key validity (>7 days until expiration)
- [ ] Image consistency across all clusters (control plane, Oregon, London)
- [ ] Ephemeral volume storage capacity on all nodes
- [ ] Subdomain routing tests across all regions
- [ ] Resource limits and quotas verification
- [ ] Smoke tests in each region
- [ ] Monitoring and alerting operational check

### 3. Capacity Planning (T-2 days)

- [ ] Review registration count
- [ ] Calculate required resources based on expected concurrent users
- [ ] Verify storage capacity meets requirements (see Issue #1)
- [ ] Scale infrastructure if necessary
- [ ] Document expected load for post-workshop analysis

### 4. Content Preparation (T-3 days)

- [ ] Prepare workshop materials and exercises
- [ ] Test workshop content in isolated environment
- [ ] Prepare facilitator guide
- [ ] Set up real-time monitoring dashboard for workshop team

## During Workshop

### Facilitation

1. **Introduction (5 min)**
   - Welcome participants
   - Explain workshop objectives
   - Overview of ai.coder.com platform

2. **Onboarding (10 min)**
   - Guide users through login flow
   - Verify all participants can access the platform
   - Troubleshoot access issues

3. **Hands-on Exercise (40-60 min)**
   - Execute planned workshop content
   - Monitor participant progress
   - Provide support as needed

4. **Feedback Collection (10 min)**
   - Gather participant feedback via form
   - Note any issues or suggestions

### Monitoring

- [ ] Workshop team monitors real-time dashboard throughout session
- [ ] Track key metrics:
  - Concurrent workspace count
  - Storage utilization per node
  - Workspace restart/failure rate
  - Image pull times
  - Subdomain routing success rate
- [ ] Document any anomalies or incidents
- [ ] Be prepared to execute incident runbook if needed

## Post-Workshop (Within 48 hours)

### 1. Data Collection

- [ ] Export metrics data from monitoring system
- [ ] Compile participant feedback
- [ ] Document any incidents or issues encountered
- [ ] Capture performance baselines for comparison

### 2. Retrospective

- [ ] Hold team retrospective meeting
- [ ] Use [Post-Workshop Retrospective Template](./POST_WORKSHOP_RETROSPECTIVE.md)
- [ ] Identify action items and assign owners
- [ ] Create GitHub issues for newly discovered problems

### 3. Issue Tracking

- [ ] Triage issues discovered during workshop
- [ ] Link issues to workshop retrospective
- [ ] Prioritize fixes for next workshop
- [ ] Update relevant documentation

### 4. Communication

- [ ] Send thank you message to participants
- [ ] Share key learnings with internal team
- [ ] Document improvements made for next workshop
- [ ] Update workshop metrics dashboard

## Success Metrics

Track these metrics month-over-month to measure improvement:

### Platform Stability

- Workspace restart/failure rate
- Incidents with user-visible impact
- Storage contention events
- Authentication failures
- Subdomain routing errors

### Workshop Quality

- Participant satisfaction score
- Percentage of participants who completed workshop
- Time to resolution for support requests
- Number of blockers encountered

### Continuous Improvement

- Issues discovered and fixed between workshops
- Reduction in repeat issues
- Infrastructure capacity headroom
- Pre-workshop checklist completion time

## Resources

- [Pre-Workshop Validation Checklist](./PRE_WORKSHOP_CHECKLIST.md)
- [Post-Workshop Retrospective Template](./POST_WORKSHOP_RETROSPECTIVE.md)
- [Incident Runbook](./INCIDENT_RUNBOOK.md)
- [Workshop Participant Guide](./PARTICIPANT_GUIDE.md)
- GitHub Issues: [#5 - Monthly Workshop Cadence](https://github.com/coder/ai.coder.com/issues/5)

## Contact

For questions about workshop planning, contact the infrastructure team or reach out to jullian@coder.com.
