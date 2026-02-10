# OpenClaw Setup on DGX Spark — Start

## Date: 2026-02-08
## Plan: Deploy OpenClaw agent ("Michael") on DGX Spark with Claude as LLM backend

## Scope
1. **Security Cleanup (Phase 0)**: Move credentials to `.env`, create `.gitignore`
2. **Soul Document Restructure (Phase 2)**: Fix typos, add hard rules, approval workflows, priority order
3. **Helm Chart Scaffolding (Phase 1)**: Create `charts/openclaw/` with all templates
4. **Pipeline Scaffolding (Phase 3)**: Create `pipelines/` directory structure for X Articles, Courses, Freelance, Capital
5. **CLAUDE.md Update**: Add OpenClaw architecture context

## Dependencies (Jonathan Must Complete)
- Slack workspace + app creation (Bot Token, Signing Secret)
- Gmail account + App Password or OAuth2
- `claude setup-token` for Claude Max integration
- OpenAI API key, ElevenLabs API key

## What Gets Done This Session
- `.gitignore` created
- `.env.example` template created
- Credentials moved to `.env` (DGX-SPARK.md, huggingface-token.txt content)
- `OpenClaw-Soul.md` restructured with all fixes
- `charts/openclaw/` Helm chart created
- `docker/Dockerfile.openclaw` created
- `pipelines/` scaffolded
- `CLAUDE.md` updated

## What Requires Future Sessions
- SSH to DGX Spark to install OpenClaw
- Helm deploy after Jonathan provides API keys
- Pipeline testing once Slack/Gmail connected
