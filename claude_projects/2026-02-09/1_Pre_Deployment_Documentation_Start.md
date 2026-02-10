# Pre-Deployment Documentation — Start

**Date**: 2026-02-09
**Objective**: Create comprehensive security hardening and deployment documentation before deploying OpenClaw to DGX Spark.

## Plan

### Files to Create
1. `docs/openclaw-security.md` — Security hardening guide covering gateway security, sandboxing, DM/channel security, credential management, prompt injection mitigations, tool permissions, network hardening, logging, incident response, and baseline config
2. `docs/deployment-guide.md` — Git-based deployment procedures including Docker build, K3s import, Helm install, verification, rollback
3. `charts/openclaw/soul.md` — Copy of OpenClaw-Soul.md for the Helm chart ConfigMap
4. `charts/openclaw/templates/networkpolicy.yaml` — Kubernetes NetworkPolicy for egress restrictions
5. `charts/openclaw/templates/deployment.yaml` — Add security context (readOnlyRootFilesystem, automountServiceAccountToken, runAsNonRoot)

### Key Decisions
- Sandbox mode "all" with workspace access "rw" (Michael needs read/write for pipelines)
- Gmail disabled for initial deployment
- NetworkPolicy restricts egress to HTTPS (443) + kube-dns only
- Block SMTP, SSH, raw HTTP egress
- Token-based auth, loopback binding, NGINX Ingress for access control
