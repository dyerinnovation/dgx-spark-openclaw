# Fix Agent Auth — auth-profiles.json in Wrong Location

## Problem
After deploying OpenClaw, Michael fails on first Slack message with:
> No API key found for provider "anthropic". Auth store: /home/node/.openclaw/agents/main/agent/auth-profiles.json

We had written `auth-profiles.json` to `/home/node/.openclaw/auth-profiles.json` but the agent runtime looks for it at `/home/node/.openclaw/agents/main/agent/auth-profiles.json`.

## Plan
1. **Runtime fix**: `mkdir -p` the agent dir and copy auth-profiles.json into it
2. **Helm chart fix**: Update init-config initContainer to copy auth-profiles.json into agent dir on every pod start
3. **Documentation**: Update CLAUDE.md with this finding
