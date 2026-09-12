## Defense Landing Zone Operational Overview
*Describe the GovCloud infrastructure, IAM, or policy changes introduced.*

- [ ] Terraform Landing Zone / Baseline Module
- [ ] OPA Rego DISA STIG / NIST 800-53 Policy
- [ ] Network Boundary / Security Group Modification
- [ ] IAM Role / KMS Cryptographic Key Policy

## Compliance & Security Verification
- **DISA STIG / NIST 800-53 Controls Impacted:** (e.g. AC-3, SC-7, SC-28)
- **FIPS 140-3 Endpoint Compliance:** Verified all endpoints target FIPS URLs.
- **Rollback Procedure:** Detailed step-by-step commands to restore prior boundary state.

## Verification Checklist
- [ ] OPA Zero-Trust policy suite passed: `pytest tests/test_zero_trust_policies.py`
- [ ] Security report generated cleanly: `python scripts/generate_security_report.py`
- [ ] Trivy vulnerability scan clean (0 High/Critical)
- [ ] Infracost GovCloud monthly run-rate differential validated
