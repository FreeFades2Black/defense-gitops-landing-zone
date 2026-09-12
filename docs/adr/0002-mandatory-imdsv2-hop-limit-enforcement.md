# ADR-0002: Mandatory IMDSv2 Hop Limit Enforcement at Landing Zone Boundary

**Status:** Accepted  
**Date:** 2026-05-22  
**Lead Architect:** William Free Hall (Free) <whall4.wh@gmail.com>

## 1. Context & Operational Challenge
Server-Side Request Forgery (SSRF) vulnerabilities in containerized applications represent a critical vector for extracting EC2 IAM instance profile credentials via the Instance Metadata Service (IMDS). 

## 2. Options Considered
* **Option A: Allow IMDSv1 Fallback for Backward Compatibility**
  - *Evaluation:* Prevents broken container network edge cases, but leaves the cluster vulnerable to credential exfiltration via simple HTTP GET requests.
* **Option B: Enforce IMDSv2 with `http_put_response_hop_limit = 1` across all Launch Templates**
  - *Evaluation:* Requires session-oriented `PUT` requests with short-lived tokens; a hop limit of 1 physically prevents pods on bridge networks or container runtimes from reaching IMDS, forcing containers to use IRSA (IAM Roles for Service Accounts) exclusively.

## 3. Decision & Trade-Off Accepted
We adopted **Option B (Strict IMDSv2 with Hop Limit 1)**.  
**Trade-Off Accepted:** Any legacy tooling running inside containers that relied on instance metadata will fail immediately. All workloads are required to use IRSA OIDC federation.
