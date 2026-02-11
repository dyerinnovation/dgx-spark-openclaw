# Plan: Load Soul Document into Michael's Workspace

## Problem
Michael is responding to Slack messages but doesn't know who he is — the soul document (`OpenClaw-Soul.md`) isn't being loaded. OpenClaw expects `SOUL.md` (uppercase, case-sensitive) in `~/.openclaw/workspace/`, but our init-config was copying it to `~/.openclaw/soul.md` (wrong location and case).

## Evidence
- Pod logs show successful Slack delivery but no soul context
- `ENOENT: no such file or directory, access '/home/node/.openclaw/workspace/MEMORY.md'` — workspace dir doesn't exist
- OpenClaw source (`system-prompt.ts`) loads `SOUL.md` from workspace dir during bootstrap

## Changes

### `charts/openclaw/templates/deployment.yaml`
Updated init-config script to:
1. Create `/home/node/.openclaw/workspace/` directory
2. Copy `soul.md` → `workspace/SOUL.md` (correct uppercase filename)
3. Added error logging if copy fails

## Deploy Steps
1. Commit + push to GitHub
2. SSH to Spark, `cd ~/deploy/dgx-spark-openclaw && git pull`
3. `sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade openclaw charts/openclaw/ -n openclaw` (with same `--set` flags)
4. Pod restarts, init-config copies SOUL.md to workspace

## Verification
1. Check init-config logs: `kubectl logs <pod> -c init-config` for "Soul document copied to workspace/SOUL.md"
2. Exec into pod: `kubectl exec <pod> -- cat /home/node/.openclaw/workspace/SOUL.md`
3. Slack DM Michael: "Who are you and who do you work for?" — should reference identity from soul doc
