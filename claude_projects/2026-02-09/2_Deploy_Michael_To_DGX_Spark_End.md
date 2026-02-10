# Deploy Michael (OpenClaw) to DGX Spark — Complete

## Work Completed

### Git & GitHub
- Initialized git repo, pushed to `https://github.com/dyerinnovation/dgx-spark-openclaw`
- Cloned on Spark at `~/deploy/dgx-spark-openclaw`

### Helm Chart Refactored
- Switched from custom Dockerfile to **official image** `ghcr.io/openclaw/openclaw:2026.2.9`
- Added **init-config container** (Node.js JSON merge into PVC) — pattern from chrisbattarbee/openclaw-helm
- Auto-generates `OPENCLAW_GATEWAY_TOKEN` via `randAlphaNum 32` if not provided
- Declarative Slack config via `values.yaml` → `openclaw.config.channels.slack`
- `agents.defaults.model` must be object: `{ "primary": "anthropic/claude-opus-4-6" }`
- `NODE_OPTIONS=--max-old-space-size=4096` to prevent OOM
- Health probes: TCP socket (not HTTP `/healthz`)
- CMD: `node openclaw.mjs gateway --bind lan --port 18789`
- Config checksum annotation for automatic rollout on changes

### Deployment Status
- Pod: **Running 1/1** in `openclaw` namespace
- Slack: **socket mode connected** to `#michael-tasks`, `#michael-approvals`, `#michael-reports`
- Security: runAsNonRoot, no privilege escalation, all caps dropped
- NetworkPolicy: `openclaw-egress` applied
- Ingress: `openclaw.spark-b0f2.local` → `172.20.14.68:80`
- Model: `anthropic/claude-opus-4-6` with thinking=high

### Key Learnings
1. OpenClaw's `openclaw.json` has **strict schema validation** — only 17 valid top-level keys
2. `agents.defaults.model` expects `{ "primary": "provider/model" }`, not a string
3. Official image runs as `node` user (UID 1000), home at `/home/node/.openclaw`
4. After first boot, must run `openclaw doctor --fix` to create session dirs
5. `plugins.entries.slack.enabled` must be `true` — doctor may set it to `false` on first boot
6. `sshpass` required for SSH commands needing sudo; single-quote remote commands to prevent `!` expansion

## Work Remaining
- [ ] Send Michael's introductory Slack message (Step 8)
- [ ] Add `channels:read` scope to Slack bot to resolve "missing_scope" warning (non-critical)
- [ ] Set up ANTHROPIC_API_KEY in `.env` (currently empty)
- [ ] Update `docs/openclaw-security.md` baseline config to match actual valid schema
- [ ] Consider adding Slack signing secret verification
