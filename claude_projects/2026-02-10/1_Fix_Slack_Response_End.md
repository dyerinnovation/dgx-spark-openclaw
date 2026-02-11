# Fix Michael Not Responding — Summary

## Completed

### Documentation Updates
- **`docs/Initial-Setup.md`**: Expanded Slack section from 6 to 22 bot token scopes, added 12 event subscriptions table, clarified setup token workflow (pasted in pod, not env var)
- **`docs/deployment-guide.md`**: Rewritten for current workflow — official image, no Docker build, `scp .env` + `git pull` + `helm upgrade`, post-deploy doctor/auth/Slack steps
- **`docs/fix-slack-response.md`**: Deleted (content merged into Initial-Setup.md)
- **`CLAUDE.md`**: Added git deployment rule ("always use git, never scp/rsync for repo files"), removed resolved `missing_scope` known issue

### Helm Chart Cleanup
- Removed `ANTHROPIC_SETUP_TOKEN` from `secret.yaml` and `values.yaml` (token is pasted via CLI, not injected as env var)

### Deployment (Helm revision 4)
- Pushed 3 commits to GitHub, pulled on Spark via `git pull`
- `.env` transferred via `scp` (only file that uses scp — it's gitignored)
- `helm upgrade` with new `SLACK_BOT_TOKEN` (updated scopes/events)
- Pod rolled out successfully, Slack socket connected

### Commits
1. `55c1145` — Update Initial-Setup with full Slack scopes/events, rewrite deployment guide
2. `f00bef0` — Remove ANTHROPIC_SETUP_TOKEN from Helm chart secrets
3. `681eb0b` — Add git deployment rule to CLAUDE.md, remove resolved missing_scope issue

### Anthropic Auth Token
- Wrote `auth-profiles.json` directly to PVC (TUI `paste-token` command doesn't work non-interactively)
- Restarted pod — auth picked up, no errors

### Verification
- `missing_scope` warning is **gone** — channels now resolve correctly
- Slack socket connected, all 3 channels resolved (#michael-tasks, #michael-approvals, #michael-reports)
- No auth errors in logs

## Remaining

### Manual Verification
1. **Send a DM to Michael** in Slack — confirm response
2. **@mention Michael** in #michael-tasks — confirm response

### Notes
- Auth profile is written directly to `/home/node/.openclaw/auth-profiles.json` on the PVC. The `openclaw models auth paste-token` TUI doesn't work non-interactively, so direct file write is the workaround for automated deploys.
- This approach should be documented if auth tokens need rotation in the future.
