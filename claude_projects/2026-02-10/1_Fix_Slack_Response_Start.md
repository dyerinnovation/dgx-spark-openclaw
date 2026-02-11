# Fix Michael Not Responding to Slack Messages

## Problem
Michael (OpenClaw) is deployed on DGX Spark — pod Running 1/1, can **send** messages but does **not respond** when Jonathan sends messages.

## Root Causes
1. **Missing Slack Bot OAuth Scopes & Event Subscriptions** — `missing_scope` error in logs; bot can't receive incoming message events
2. **Empty `ANTHROPIC_API_KEY` in Pod** — env var is blank; need to use setup token via CLI instead

## Plan

### Step 1: Configure Auth via Setup Token Inside Pod
- Run `kubectl exec` to paste the setup token via `openclaw models auth paste-token --provider anthropic`
- Remove `ANTHROPIC_SETUP_TOKEN` from Helm chart (not used as env var)
- Clean up `secret.yaml`, `values.yaml`, and `CLAUDE.md`

### Step 2: Fix Slack App Scopes (Interactive — walk Jonathan through Slack API UI)
- Add required Bot Token Scopes (channels:history, im:history, app_mentions:read, etc.)
- Add Event Subscriptions (app_mention, message.channels, message.im, etc.)
- Reinstall app to workspace, copy new SLACK_BOT_TOKEN

### Step 3: Deploy
- Paste setup token inside pod (no redeploy needed for auth)
- Helm upgrade with new Slack token + chart cleanup
- Wait for rollout, check logs

### Step 4: Verify
- No `missing_scope` or auth errors in logs
- DM to Michael gets a response
- @mention in #michael-tasks gets a response
