# ADR-0001: Dedicated AWS GovCloud Partition (`arn:aws-us-gov:`) with FIPS 140-3 Endpoints

**Status:** Accepted  
**Date:** 2026-05-10  
**Lead Architect:** William Free Hall (Free) <whall4.wh@gmail.com>

## 1. Context & Operational Challenge
To host mission-critical DoD workloads meeting DoD Cloud SRG Impact Level 5 (IL5) and FedRAMP High authorizations, all data at rest and in transit must be cryptographically protected using FIPS 140-3 validated cryptographic modules, restricted to US Persons on US Soil.

## 2. Options Considered
* **Option A: Commercial AWS (`us-east-1` / `us-west-2`) with Client-Side KMS Encryption**
  - *Evaluation:* Simpler developer access and lower costs, but legally prohibited for Controlled Unclassified Information (CUI) and Mission Critical data under DoD SRG IL5.
* **Option B: Isolated AWS GovCloud (US) Partition with Dedicated DirectConnect and FIPS Endpoints**
  - *Evaluation:* Restricts all IAM and API access to authenticated US Citizens, enforces mandatory FIPS 140-3 cryptographic endpoints (e.g. `kms.us-gov-west-1.amazonaws.com`), and guarantees boundary physical isolation.

## 3. Decision & Trade-Off Accepted
We adopted **Option B (AWS GovCloud Partition)**.  
**Trade-Off Accepted:** GovCloud service availability lags commercial regions by 6-12 months for bleeding-edge managed services, and requires specialized deployment tooling to account for partition-specific ARNs (`arn:aws-us-gov:*`).
