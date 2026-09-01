"""
Defense-Grade DevSecOps Pipeline
Test Suite for Zero-Trust Security Context, OPA Policies, and Security Report Generation.
"""

import pytest
import os
from src.app.main import ZeroTrustSecurityContext, get_health_status
from scripts.generate_security_report import generate_security_release_dossier


def test_zero_trust_security_context():
    """Verify runtime context audits non-root UID and compliance flags."""
    ctx = ZeroTrustSecurityContext.audit_runtime_security()
    assert "runtime_uid" in ctx
    assert ctx["read_only_rootfs_enforced"] is True
    assert "service_name" in ctx


def test_health_status_endpoint():
    """Verify health status returns healthy with security posture payload."""
    health = get_health_status()
    assert health["status"] == "HEALTHY"
    assert "security_posture" in health


def test_security_dossier_generation(tmp_path):
    """Verify automated generation of NIST/CIS compliance release markdown."""
    test_out = tmp_path / "TEST_SECURITY_RELEASE_DOSSIER.md"
    dossier = generate_security_release_dossier(output_path=str(test_out))
    assert test_out.exists()
    assert "NIST SP 800-53 Rev. 5" in dossier
    assert "CIS Kubernetes v1.8" in dossier
    assert "Chamber 1: SAST & Type Safety" in dossier
