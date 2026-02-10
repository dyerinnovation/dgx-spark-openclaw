# Plan: Model Download, Serving via TGI Helm Chart, Docs, and Local Clone

## Status: In Progress

## Objective
Clone repo locally, download Qwen3-7B on Spark, deploy TGI via Helm for model serving, write comprehensive setup docs, add inference service to backend, and rewrite CLAUDE.md.

## Steps
1. Clone repo locally ✅
2. Create `docs/` folder with 5 setup docs
3. Update README.md with docs section
4. Add TGI Helm chart to charts/
5. Download Qwen3-7B model on Spark (SSH)
6. Create inference service in backend
7. Deploy TGI on Spark and test
8. Rewrite CLAUDE.md with comprehensive project context
9. Write tests for new code
10. Commit, push, update plan docs

## Team
- **docs-writer** — docs, README, CLAUDE.md
- **backend-dev** — inference service, config updates
- **devops** — TGI Helm chart, umbrella chart updates
- **tester** — unit/integration tests (blocked by backend-dev & devops)
- **team lead** — coordination, model download on Spark, deploy & test TGI
