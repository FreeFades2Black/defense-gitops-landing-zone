# Incident Post-Mortem: IMDSv2 Hop Limit Misconfiguration Evicting DaemonSet Sidecars

**Incident Date:** 2026-05-19  
**Impact Duration:** 18 minutes  
**Severity:** SEV-3  
**Root Cause:** Launch template updated `http_put_response_hop_limit = 1` globally, causing a node-level logging DaemonSet executing in container network namespace to lose access to instance tags.

## Timeline
* **09:12 UTC:** Terraform landing zone applied hop limit enforcement to node launch templates.
* **09:15 UTC:** Node rotation began; fluent-bit logging pods failed health checks with `EC2MetadataError: 403 Forbidden`.
* **09:24 UTC:** Security and DevOps engineering determined fluent-bit was running with `hostNetwork: false`.
* **09:30 UTC:** Updated fluent-bit DaemonSet to `hostNetwork: true`, allowing legitimate node-level daemons to retrieve local instance metadata while keeping container workloads quarantined.

## Corrective Actions
1. Documented standard architecture requirement: node monitoring DaemonSets requiring instance metadata must declare `hostNetwork: true`.
2. Created Conftest policy verifying no application pods specify `hostNetwork: true`.
