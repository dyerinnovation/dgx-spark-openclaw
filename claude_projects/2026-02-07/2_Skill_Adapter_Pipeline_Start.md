# Skill Adapter Pipeline — Start

## Date: 2026-02-07

## Objective
Build a full-stack RLVF training pipeline ("Skill Adapter") that trains HuggingFace models to follow Agent Skills (SKILL.md files). Includes FastAPI backend, React+Vite frontend dashboard, Helm charts for K8s deployment on DGX Spark.

## DGX Spark Status
- SSH: `ssh jondyer3@spark-b0f2.local` (passwordless key auth configured)
- OS: Ubuntu 24.04.3 LTS
- GPU: NVIDIA GB10 (Blackwell), 119GB unified memory
- Installed: git, docker, python 3.12.3
- Missing: helm, uv, node/npm, kubectl

## GitHub Repo
`dyerinnovation/agent-skill-adapter` — needs to be created and cloned to DGX Spark

## Plan
1. **Setup** (Lead): Install tools on DGX Spark (uv, node, helm, kubectl), create GitHub repo, scaffold monorepo
2. **Research docs** (Lead): Write 5 research docs to `research/`
3. **Backend** (backend-dev): FastAPI app with MVC, skill loader, eval harness, training pipeline
4. **Frontend** (frontend-dev): React+Vite dashboard with docs, all pages and components
5. **DevOps** (devops): Helm charts (api, frontend, redis, training-job, umbrella), Dockerfiles
6. **Testing** (tester): Unit, integration, e2e tests
7. **Validation** (validator): Review all outputs

## Team
Using Claude Code teams with 6 agents working in parallel on DGX Spark.
