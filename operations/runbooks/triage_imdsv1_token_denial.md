# Operational Runbook: Triage IMDSv2 Token Denials & Metadata Access Violations

**Severity:** P3 / Security Compliance Alert  
**Target Systems:** AWS GovCloud EC2 Node Groups, CloudTrail, IMDSv2 Guardrails

## Diagnostic Workflow

### 1. Identify Instances with IMDSv1 Calls in CloudTrail
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=GetRoleCredentials \
  --region us-gov-west-1 \
  --query 'Events[?contains(CloudTrailEvent, `"userAgent":"aws-sdk"`)]'
```

### 2. Inspect Live Instance Metadata Options
```bash
aws ec2 describe-instances \
  --instance-ids i-0a1b2c3d4e5f67890 \
  --region us-gov-west-1 \
  --query 'Reservations[*].Instances[*].MetadataOptions'
```
Expected output:
```json
{
  "HttpTokens": "required",
  "HttpPutResponseHopLimit": 1,
  "HttpEndpoint": "enabled"
}
```

### 3. Verify Container Identity Isolation
Verify that the pod is authenticating via IRSA and not attempting to query node metadata:
```bash
kubectl exec -it <pod-name> -n workloads -- env | grep AWS_WEB_IDENTITY_TOKEN_FILE
```
If empty, attach an IAM role to the Kubernetes ServiceAccount via the `eks.amazonaws.com/role-arn` annotation.
