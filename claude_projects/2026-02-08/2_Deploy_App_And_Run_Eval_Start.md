# Plan: Deploy Full App Stack & Run Baseline Model Evaluation

## Context
vLLM is serving Qwen3-30B-A3B on K8s (pod ready, max_model_len=40960), but the rest of the stack (API backend, frontend, Redis, ingress) is NOT deployed. The 3 skill directories (`backend/skills/pdf/`, `mcp-builder/`, `internal-comms/`) exist but their SKILL.md files are **empty**. We need to: populate skills from the official Anthropic skills repo with evaluation rubrics, deploy the full stack, and run the evaluation endpoint to get baseline model performance.

## Key Architecture

### Evaluation Pipeline
- **Evaluator** (`backend/src/services/evaluator.py`): Scores output against rubrics (0.0-1.0 per rubric). Uses heuristics: keyword presence, markdown format detection, JSON validity, list formatting, word counts.
- **Eval Controller** (`backend/src/controllers/evaluation.py`): `POST /api/evaluation/run` with `EvalRequest(skill_id, prompts, num_samples)`. Loads skill, sends prompts to vLLM, evaluates responses.
- **Skill Loader** (`backend/src/services/skill_loader.py`): Parses SKILL.md files. Extracts rubrics from `## Constraints` (behavioral) and `## Output Format` (structural) sections. Uses markdown list items as individual rubrics.
- **Inference Client** (`backend/src/services/inference.py`): Async HTTP client calling vLLM's `/v1/completions` endpoint. Retries with exponential backoff.

### Critical Code Detail
The eval controller only uses vLLM if `inference_url` is NOT localhost:
```python
use_inference = (
    settings.inference_url
    and settings.inference_url != "http://localhost:8080"
    and not settings.inference_url.startswith("http://localhost")
)
```
So we MUST set `SKILL_ADAPTER_INFERENCE_URL=http://tgi:8080` in the API configmap.

### Current K8s State
- **Running**: vLLM (tgi pod, default namespace), NGINX Ingress Controller
- **NOT deployed**: API backend, frontend, Redis, ingress routing rules
- **Docker images available**: skill-adapter-api:latest, skill-adapter-frontend:latest

---

## Step 1: Clone Anthropic Skills & Add Evaluation Rubrics

Official skills at `github.com/anthropics/skills` are reference guides for Claude — they don't have rubric sections. We need to:
1. Clone SKILL.md files from the Anthropic repo for `pdf`, `mcp-builder`, `internal-comms`
2. Also clone supporting files (reference docs, examples, scripts) that skills reference
3. **Append** `## Constraints` (behavioral rubrics) and `## Output Format` (structural rubrics) sections based on each skill's expected behavior

The rubrics should be designed to test what a model SHOULD produce when using each skill. The heuristic evaluator checks:
- Keyword presence from rubric descriptions
- Markdown formatting (headers, bold, code blocks, lists)
- JSON validity
- Word count thresholds
- Section presence

### Files on Spark (`~/agent-skill-adapter/backend/skills/`):
- `pdf/SKILL.md` + `pdf/reference.md`, `pdf/forms.md`, `pdf/scripts/`
- `mcp-builder/SKILL.md` + `mcp-builder/reference/`
- `internal-comms/SKILL.md` + `internal-comms/examples/`

## Step 2: Add Missing Env Vars to API Chart

**`charts/api/templates/configmap.yaml`** — Currently missing `SKILL_ADAPTER_INFERENCE_URL` and `SKILL_ADAPTER_SKILLS_DIR`. Add:
```yaml
SKILL_ADAPTER_INFERENCE_URL: {{ .Values.config.inferenceUrl | default "http://tgi:8080" | quote }}
SKILL_ADAPTER_SKILLS_DIR: {{ .Values.config.skillsDir | default "/app/skills" | quote }}
```

**`charts/api/values.yaml`** — Add new config values:
```yaml
config:
  inferenceUrl: "http://tgi:8080"
  skillsDir: "/app/skills"
```

**`charts/api/templates/deployment.yaml`** — Add hostPath volume mount for skills directory:
```yaml
volumeMounts:
- name: skills
  mountPath: /app/skills
  readOnly: true
volumes:
- name: skills
  hostPath:
    path: /home/jondyer3/agent-skill-adapter/backend/skills
    type: Directory
```

## Step 3: Deploy Components (in order)

All in **default namespace** (where tgi already lives — simplifies service discovery: `http://tgi:8080`).

1. **Redis**: `helm install redis charts/redis/` (PVC auto-provisions via local-path)
2. **API**: `helm install api charts/api/` — verify health + skills loaded
3. **Frontend**: `helm install frontend charts/frontend/`
4. **Ingress**: `helm install ingress charts/ingress/`

## Step 4: Run Evaluation

For each skill, POST to `/api/evaluation/run` with prompts relevant to the skill's purpose:
```bash
curl -X POST http://spark-b0f2.local/skill-adapter-api/api/evaluation/run \
  -H "Content-Type: application/json" \
  -d '{"skill_id":"pdf","prompts":[...], "num_samples":10}'
```

Collect aggregate scores and per-rubric breakdowns for all 3 skills.

## Step 5: Commit, Push, Document Results

- Commit SKILL.md files + chart changes on Spark
- Push to GitHub
- Document baseline scores in `2_Deploy_App_And_Run_Eval_End.md`
- Update CLAUDE.md with deployment details

## Team Execution Plan

### Team: "deploy-eval"

**Phase A — Parallel (2 agents):**
| Agent | Type | Task |
|-------|------|------|
| **skill-writer** | general-purpose | Step 1: Clone Anthropic SKILL.md files + supporting files, add rubric sections |
| **chart-fixer** | general-purpose | Step 2: Update API chart configmap, values, deployment on Spark |

**Phase B — Lead agent (sequential, after Phase A):**
- Step 3: Deploy Redis → API → Frontend → Ingress
- Verify pods running, API health, skills loaded

**Phase C — Parallel (2 agents):**
| Agent | Type | Task |
|-------|------|------|
| **eval-runner** | general-purpose | Step 4: Run evaluation via curl for all 3 skills |
| **browser-tester** | general-purpose | Use Playwright to verify frontend loads, API health, skills list, screenshot results |

**Phase D — Lead agent:**
- Step 5: Commit, push, document results

## Verification
- All pods Running: redis, api, frontend, tgi
- `curl http://spark-b0f2.local/skill-adapter-api/api/skills` → 3 skills with rubrics
- Eval returns non-zero scores for all 3 skills (confirms vLLM inference working)
- Playwright screenshots confirm frontend and API accessible via browser
- Results documented in End file

## SSH Reference
```bash
sshpass -p 'JDf33nawm3!' ssh jondyer3@spark-b0f2.local '<command>'
# PATH: $HOME/.local/bin:$HOME/.nvm/versions/node/v22.22.0/bin:$PATH
# KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```
