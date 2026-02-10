# Pre-Deployment Documentation — End

**Date**: 2026-02-09

## Work Completed

### Files Created
1. **`docs/openclaw-security.md`** — Comprehensive security hardening guide covering:
   - Gateway security (token auth, loopback binding, Bonjour disabled)
   - Sandboxing (mode "all", workspace "rw", no elevated execution)
   - DM & channel security (pairing policy, mention required, channel allowlist)
   - Credential management (env vars only, K8s Secrets, file permissions)
   - Prompt injection mitigations (Claude as primary LLM, Gmail disabled, hostile input handling)
   - Tool permissions (allowed/denied tools, command blacklist, sandbox principle)
   - Network hardening (egress to HTTPS+DNS only, block SMTP/SSH/HTTP)
   - Logging & monitoring (redaction patterns, command logging, weekly review)
   - Incident response (stop, rotate, review, report)
   - Secure baseline `openclaw.json5` config (copy-paste ready)

2. **`docs/deployment-guide.md`** — Git-based deployment procedures:
   - Git push workflow (direct to Spark or via GitHub)
   - scp for `.env` credentials
   - Docker build on Spark (ARM64 native)
   - Image import to K3s containerd
   - Helm install/upgrade with secrets from `.env`
   - Post-deploy verification checklist (7 checks)
   - Security verification steps
   - Rollback procedures (Helm rollback, emergency stop, full uninstall)
   - Soul document update process
   - Troubleshooting table

3. **`charts/openclaw/soul.md`** — Copy of `OpenClaw-Soul.md` for the Helm chart ConfigMap mount

4. **`charts/openclaw/templates/networkpolicy.yaml`** — Kubernetes NetworkPolicy:
   - Allows egress to port 443 (HTTPS) for all API and web access
   - Allows egress to kube-dns (port 53) for DNS resolution
   - Implicitly blocks all other egress (SMTP, SSH, raw HTTP)

### Files Modified
5. **`charts/openclaw/templates/deployment.yaml`** — Added security context:
   - `automountServiceAccountToken: false`
   - `readOnlyRootFilesystem: true`
   - `runAsNonRoot: true` (UID/GID 1000)
   - `allowPrivilegeEscalation: false`
   - Drop all Linux capabilities
   - Writable `/tmp` via emptyDir volume

## Work Remaining
- Deploy to DGX Spark using the deployment guide
- Run `openclaw security audit --fix` after initial setup
- Configure the secure baseline `openclaw.json5` on the pod
- Test all verification steps from the deployment guide
- Consider adding CLAUDE.md updates for deployment workflow reference

## Suggested CLAUDE.md Additions
- Add reference to `docs/openclaw-security.md` and `docs/deployment-guide.md` under Key Directories
- Add note that `charts/openclaw/soul.md` must be kept in sync with `OpenClaw-Soul.md`
- Document the NetworkPolicy egress rules for quick reference
