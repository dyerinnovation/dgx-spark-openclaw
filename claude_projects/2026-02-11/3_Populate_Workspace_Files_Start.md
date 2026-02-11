# Plan: Populate OpenClaw Workspace Files for Michael

## Problem
Michael acts like a fresh install on every startup because:
- `BOOTSTRAP.md` tells him he "just came online" with a "clean slate"
- `AGENTS.md` says "If BOOTSTRAP.md exists, follow it" — overrides soul context
- `IDENTITY.md` and `USER.md` are blank templates

## Solution
Pre-populate workspace files with real content and rewrite BOOTSTRAP.md as a startup checklist.

## Files Created/Modified
1. `charts/openclaw/workspace/IDENTITY.md` — Michael's identity
2. `charts/openclaw/workspace/USER.md` — Jonathan's profile
3. `charts/openclaw/workspace/TOOLS.md` — Available tools and infrastructure
4. `charts/openclaw/workspace/BOOTSTRAP.md` — Rewritten as startup checklist with active tasks
5. `charts/openclaw/templates/configmap.yaml` — New ConfigMap for workspace files
6. `charts/openclaw/templates/deployment.yaml` — Updated init-config to copy workspace files (skip existing)

## Key Design Decisions
- SOUL.md and BOOTSTRAP.md always overwrite (so we can update tasks/identity from helm)
- IDENTITY.md, USER.md, TOOLS.md skip if they exist (Michael may edit these over time)
- memory/ directory created but left empty for Michael to populate

## Deploy
1. Commit + push
2. On Spark: `git pull` + `bash upgrade.sh`
3. Pod restarts, all workspace files populated
