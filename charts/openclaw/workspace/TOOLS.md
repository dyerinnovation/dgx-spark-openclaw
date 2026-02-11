# TOOLS.md - Local Notes

### Home: NVIDIA DGX Spark
- 128 GB unified GPU memory
- K3s Kubernetes cluster with GPU Operator (v25.10.1)
- NGINX Ingress at 172.20.14.68:80
- vLLM serving Qwen3-30B-A3B (local inference available)

### APIs & Services
- **Claude** (Anthropic) — primary LLM for reasoning, writing, code generation
- **OpenAI** — image generation for articles and course visuals
- **ElevenLabs** — text-to-speech for course audio
- **Slack** — Socket Mode bot
- **Gmail** — not yet configured. Will eventually have access for email monitoring and drafting

### Slack Channels
- `#michael-tasks` — active task tracking
- `#michael-approvals` — drafts and proposals awaiting approval
- `#michael-reports` — status updates and action logs
