# Fix Agent Auth — Summary

## Problem
Agent runtime reads auth from `/home/node/.openclaw/agents/main/agent/auth-profiles.json`, but we only wrote it to `/home/node/.openclaw/auth-profiles.json`. Michael failed with "No API key found for provider anthropic".

## Completed

### Runtime Fix
- Created `/home/node/.openclaw/agents/main/agent/` directory in running pod
- Copied `auth-profiles.json` into it — no pod restart needed

### Helm Chart Fix (Persistent)
- Updated `charts/openclaw/templates/deployment.yaml` init-config initContainer
- Added Node.js code to `mkdir -p` the agent dir and copy auth-profiles.json on every pod start
- This ensures auth survives pod restarts and helm upgrades

### Documentation
- Updated `CLAUDE.md` with auth-profiles dual-path requirement
- Updated `1_Fix_Slack_Response_End.md` with this finding

## Remaining
1. **Commit and push** changes to GitHub
2. **Deploy**: `git pull` on Spark + `helm upgrade` to persist the fix
3. **Verify**: Send DM to Michael in Slack — should respond now
