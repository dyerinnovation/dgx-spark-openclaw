# OpenClaw Security Hardening Guide

> For Michael — Dyer Innovation's autonomous business operations agent on DGX Spark.

---

## Table of Contents
1. [Gateway Security](#gateway-security)
2. [Sandboxing](#sandboxing)
3. [DM & Channel Security](#dm--channel-security)
4. [Credential Management](#credential-management)
5. [Prompt Injection Mitigations](#prompt-injection-mitigations)
6. [Tool Permissions](#tool-permissions)
7. [Network Hardening (Kubernetes)](#network-hardening-kubernetes)
8. [Logging & Monitoring](#logging--monitoring)
9. [Incident Response](#incident-response)
10. [Secure Baseline Config](#secure-baseline-config)

---

## Gateway Security

### Token-Based Authentication
- Use a strong, randomly generated gateway token (minimum 32 characters)
- Set via `OPENCLAW_GATEWAY_TOKEN` environment variable
- **Never** use password-based authentication

### Loopback Binding
- Bind OpenClaw gateway to `127.0.0.1` only — never `0.0.0.0`
- Use NGINX Ingress to proxy external access with TLS termination
- In `openclaw.json5`:
  ```json5
  { "gateway": { "host": "127.0.0.1", "port": 18789 } }
  ```

### Disable Discovery
- Set `OPENCLAW_DISABLE_BONJOUR=1` to prevent mDNS/Bonjour advertisement
- OpenClaw should not be discoverable on the local network

### Trusted Proxy
- Configure NGINX Ingress as the trusted reverse proxy
- Set `X-Forwarded-For` header trust to the ingress controller IP only

---

## Sandboxing

### Sandbox Mode
- Enable sandbox mode `"all"` — all agent tool execution runs in Docker isolation
- This means every `exec`, `bash`, and `browser` call runs inside a container
- The sandbox isolates **where** code runs, not **what** Michael can do

### Workspace Access
- Set workspace access to `"rw"` — Michael needs to read/write pipeline files, drafts, and outlines
- Writable paths limited to `/home/openclaw` and `/tmp`

### Per-Agent Sandbox Profiles
- Michael runs sandboxed with no elevated tools
- No agent should have elevated execution privileges

In `openclaw.json5`:
```json5
{
  "sandbox": {
    "mode": "all",
    "workspace": "rw"
  },
  "elevated": {
    "allowFrom": []  // No agents can escape sandbox
  }
}
```

---

## DM & Channel Security

### DM Policy
- Set DM policy to `"pairing"` — require approval codes for unknown senders
- This prevents unauthorized users from DMing the agent directly

### Group Chat
- Require `@mention` in group chats: `requireMention: true`
- Michael only responds when explicitly addressed

### Channel Allowlist
Restrict Michael to approved Slack channels only:
- `#michael-tasks` — active task tracking
- `#michael-approvals` — drafts and proposals awaiting approval
- `#michael-reports` — status updates and action logs

```json5
{
  "slack": {
    "dmPolicy": "pairing",
    "requireMention": true,
    "allowedChannels": [
      "#michael-tasks",
      "#michael-approvals",
      "#michael-reports"
    ]
  }
}
```

---

## Credential Management

### Environment Variables Only
- All secrets injected via Kubernetes Secrets → environment variables
- **Never** store credentials in config files, ConfigMaps, or source code
- Reference `.env.example` for the full list of required variables

### File Permissions
On the host and within containers:
```bash
chmod 700 ~/.openclaw/
chmod 600 ~/.openclaw/openclaw.json
```

### Kubernetes Secrets
- All API keys stored as Kubernetes Secrets (not ConfigMaps)
- The Helm chart's `secret.yaml` template handles this
- Verify with: `kubectl get secret openclaw-secrets -n openclaw -o yaml`

### Post-Setup Audit
After initial configuration:
```bash
openclaw security audit --fix
```
This checks file permissions, config security, and token strength.

---

## Prompt Injection Mitigations

### Instruction-Hardened LLM
- Use Claude (Anthropic API) as the primary LLM — it has built-in instruction-following hardening
- Do **not** use local models (Qwen3) for security-sensitive decision-making

### Treat All Input as Hostile
- All inbound Slack messages, emails, and attachments should be treated as potentially adversarial
- Never execute instructions embedded in external content without validation

### Gmail Disabled for Initial Deployment
- Gmail integration is **disabled** at launch
- No external email access until trust boundaries are established and tested
- When eventually enabled, use a read-only "reader agent" to summarize untrusted content before the main agent processes it

### Content Sanitization
- Strip or escape any code blocks, URLs, or command-like patterns from untrusted input before processing
- Log all inbound messages for post-hoc review

---

## Tool Permissions

### Principle
Sandbox isolates **where** code runs (Docker container), not **what** Michael can do. Michael has full capability within the sandbox but cannot escape to the host.

### Allowed Tools
Michael needs these tools for his business pipelines (articles, courses, freelance work):

| Tool | Purpose |
|------|---------|
| `read` | Read pipeline files, drafts, research |
| `write` | Create drafts, outlines, content |
| `edit` | Modify existing files |
| `exec` | Run pipeline scripts, agent teams |
| `bash` | Shell commands within sandbox |
| `browser` | Web research for topics |
| `web_fetch` | Gather content from URLs |
| `web_search` | Topic research |
| `slack` | Communication with Jonathan |
| `sessions_list` | Manage agent sessions |

### Denied Tools
| Tool | Reason |
|------|--------|
| `process` | No system process management — prevents host interference |

### Command Restrictions
Within the sandbox, block destructive commands via sandbox policy:
- `rm -rf /`
- `dd`
- `mkfs`
- `shutdown`, `reboot`

### Elevated Execution
- **Disabled**: `elevated.allowFrom: []`
- No agent can escalate to host-level execution

---

## Network Hardening (Kubernetes)

### NetworkPolicy — Egress Restrictions
A `NetworkPolicy` restricts what the OpenClaw pod can reach:

**Allowed Egress:**
| Destination | Port | Purpose |
|-------------|------|---------|
| Any | 443 (TCP) | HTTPS — Anthropic API, OpenAI API, ElevenLabs, Slack, web research |
| kube-dns | 53 (TCP/UDP) | DNS resolution |

**Blocked Egress:**
| Destination | Port | Reason |
|-------------|------|--------|
| Any | 25, 465, 587 | SMTP — no email sending |
| Any | 22 | SSH — no lateral movement |
| Any | 80 | Raw HTTP — force HTTPS |

### Host Firewall
- Firewall OpenClaw's gateway port (18789) at the host level
- Only allow connections from the NGINX Ingress controller
- No inbound from the public internet

### Pod Network Isolation
- No inbound connections except from NGINX Ingress
- `automountServiceAccountToken: false` — pod cannot access Kubernetes API

---

## Logging & Monitoring

### Sensitive Data Redaction
```json5
{
  "logging": {
    "redactSensitive": "tools",
    "customRedactionPatterns": [
      "sk-[a-zA-Z0-9]{20,}",    // Anthropic/OpenAI keys
      "xoxb-[a-zA-Z0-9-]+",     // Slack bot tokens
      "xapp-[a-zA-Z0-9-]+"      // Slack app tokens
    ]
  }
}
```

### Command Logging
- Log all executed commands with their parameters
- Include timestamps, agent identity, and sandbox context

### Log Forwarding
- Forward logs to persistent storage on the DGX Spark
- Use a `/var/log/openclaw/` directory on a persistent volume

### Review Schedule
- Weekly review of gateway logs for anomalies
- Check for: unusual command patterns, unexpected tool usage, failed authentication attempts

---

## Incident Response

### Immediate Actions
1. **Stop the gateway**: `kubectl scale deployment openclaw-gateway -n openclaw --replicas=0`
2. **Verify loopback binding**: Ensure gateway was on `127.0.0.1`
3. **Disable DMs**: Set DM policy to `"none"` in config

### Token Rotation
Rotate **all** tokens immediately:
- Gateway token
- Slack bot token & signing secret
- Anthropic API key
- OpenAI API key
- ElevenLabs API key

Update `.env`, re-deploy the Kubernetes Secret, and restart the pod.

### Forensics
- Review session transcripts in `/home/openclaw/sessions/`
- Review gateway logs
- Check Slack audit logs for unauthorized interactions
- Examine NetworkPolicy logs for unexpected egress

### Post-Incident
- Document the incident with timeline, impact, and root cause
- Update security policies based on findings
- Report to Jonathan via Slack

---

## Secure Baseline Config

Copy this to `~/.openclaw/openclaw.json5` as the starting configuration:

```json5
{
  // Gateway — bind to LAN for K8s service access
  "gateway": {
    "mode": "local",
    "host": "0.0.0.0",
    "port": 18789
  },

  // Agent defaults — model, sandbox, timeouts
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-6"
      },
      "timeoutSeconds": 600,
      "thinkingDefault": "high",
      "sandbox": {
        "mode": "all",
        "workspaceAccess": "rw"
      }
    }
  },

  // Slack integration (Socket Mode)
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "${SLACK_BOT_TOKEN}",
      "appToken": "${SLACK_APP_TOKEN}",
      "dm": {
        "enabled": true,
        "policy": "pairing"
      },
      "channels": {
        "#michael-tasks": { "allow": true },
        "#michael-approvals": { "allow": true, "requireMention": true },
        "#michael-reports": { "allow": true }
      }
    }
  },

  // Tool permissions
  "tools": {
    "allow": [
      "read", "write", "edit", "exec",
      "browser", "web_fetch", "web_search",
      "slack", "sessions_list"
    ],
    "deny": ["process"],
    "elevated": {
      "enabled": false
    }
  },

  // Logging — redact secrets from tool outputs
  "logging": {
    "redactSensitive": "tools"
  },

  // Plugins — Slack enabled
  "plugins": {
    "entries": {
      "slack": { "enabled": true }
    }
  }
}
```
