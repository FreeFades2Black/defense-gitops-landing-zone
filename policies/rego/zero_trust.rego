# =============================================================================
# Open Policy Agent (OPA) / Rego - Defense-Grade Zero-Trust Compliance Policies
# Target Standards: DoD Enterprise DevSecOps, CIS Kubernetes Benchmark v1.8, NIST SP 800-53
# =============================================================================

package kubernetes.admission

import future.keywords.contains
import future.keywords.if
import future.keywords.in

default allow = false

# 1. Deny Containers Running as Root (CIS 5.2.6)
deny contains msg if {
    input.request.kind.kind in ["Pod", "Deployment", "StatefulSet", "DaemonSet"]
    container := input_containers[_]
    not container.securityContext.runAsNonRoot == true
    msg := sprintf("CIS 5.2.6 Violation: Container '%v' in pod '%v' must set securityContext.runAsNonRoot=true", [container.name, input.request.object.metadata.name])
}

# 2. Deny Privilege Escalation (CIS 5.2.5)
deny contains msg if {
    input.request.kind.kind in ["Pod", "Deployment", "StatefulSet", "DaemonSet"]
    container := input_containers[_]
    not container.securityContext.allowPrivilegeEscalation == false
    msg := sprintf("CIS 5.2.5 Violation: Container '%v' must explicitly set allowPrivilegeEscalation=false", [container.name])
}

# 3. Enforce Read-Only Root Filesystem (CIS 5.2.4)
deny contains msg if {
    input.request.kind.kind in ["Pod", "Deployment", "StatefulSet", "DaemonSet"]
    container := input_containers[_]
    not container.securityContext.readOnlyRootFilesystem == true
    msg := sprintf("CIS 5.2.4 Violation: Container '%v' must enable readOnlyRootFilesystem=true", [container.name])
}

# 4. Deny Insecure HostPath Volume Mounts (CIS 5.2.1)
deny contains msg if {
    input.request.kind.kind in ["Pod", "Deployment", "StatefulSet", "DaemonSet"]
    volume := input.request.object.spec.template.spec.volumes[_]
    volume.hostPath
    msg := sprintf("CIS 5.2.1 Violation: Volume '%v' uses prohibited hostPath mount. Must use ephemeral or CSI volumes.", [volume.name])
}

# 5. Enforce CPU & Memory Resource Limits (DoD Cloud Benchmark)
deny contains msg if {
    input.request.kind.kind in ["Pod", "Deployment", "StatefulSet", "DaemonSet"]
    container := input_containers[_]
    not container.resources.limits.cpu
    msg := sprintf("DoD Resiliency Violation: Container '%v' lacks explicit CPU resource limits", [container.name])
}

deny contains msg if {
    input.request.kind.kind in ["Pod", "Deployment", "StatefulSet", "DaemonSet"]
    container := input_containers[_]
    not container.resources.limits.memory
    msg := sprintf("DoD Resiliency Violation: Container '%v' lacks explicit memory resource limits", [container.name])
}

# Helper: Extract all containers across pod specs
input_containers := containers if {
    containers := input.request.object.spec.template.spec.containers
} else := containers if {
    containers := input.request.object.spec.containers
}

# Allow only if zero violation messages exist
allow if {
    count(deny) == 0
}
