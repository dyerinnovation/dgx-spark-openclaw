# Project: dgx-spark-clawdbot

## Architecture Overview
- **Agent**: "Michael" — autonomous business operations agent powered by OpenClaw + Claude
- **Infrastructure**: DGX Spark (K3s v1.34.3, GPU Operator v25.10.1, NGINX Ingress at 172.20.14.68:80)
- **LLM**: Claude via Anthropic API (primary), Qwen3-30B-A3B via vLLM (local inference)
- **Communication**: Slack (internal with Jonathan), Gmail (external, read-only by default)
- **Soul Document**: `OpenClaw-Soul.md` — Michael's identity, rules, workflows, and pipeline definitions

## Key Directories
- `charts/openclaw/` — Helm chart for deploying OpenClaw gateway on K3s
- `docker/` — Dockerfiles for custom images
- `pipelines/` — Business pipeline definitions (x-articles, udemy-courses, freelance, dyer-capital)
- `claude_projects/` — Work documentation organized by date

## Credentials
- All secrets in `.env` (never committed) — see `.env.example` for template
- Helm chart injects secrets via Kubernetes Secret resource
- SSH access: `ssh jondyer3@spark-b0f2.local`

## Deployment
```bash
# Build and push OpenClaw image
docker build -f docker/Dockerfile.openclaw -t ghcr.io/dyerinnovation/openclaw:latest .

# Deploy to DGX Spark
helm install openclaw charts/openclaw/ -n openclaw --create-namespace \
  --set secrets.anthropicSetupToken=$ANTHROPIC_SETUP_TOKEN \
  --set secrets.slackBotToken=$SLACK_BOT_TOKEN \
  # ... (all secrets from .env)
```

---

## Mandatory-Work-Documentation
  - Check if there is a folder created for today's date in the claude_projects/ directory and if not create it
  - Start each plan by creating a markdown file to document the plan: 
    - The plan should be of sufficient detail to be passed to another instance of claude and have the work picked up (in case Claude becomes disconnected)
    - The title should sufficiently explain what the plan is for 
    - The title should start with the number after the latest file in the folder e.g. if the last file was 1_BootStrapProject the next file would be of the format 2_<feature_name>
    - the first file for each day should start with 1
  - Once work on each plan is complete, summarize the work completed and the work remaining in another markdown file 
  - The first file should end in _Start while the second file should end in _End
  - Once _End is created, review it and _Start to check if anything should be added to the Claude.md for better context avout the project in the futrue

## Git Conventions
- Do NOT include "Co-Authored-By" lines in commit messages
