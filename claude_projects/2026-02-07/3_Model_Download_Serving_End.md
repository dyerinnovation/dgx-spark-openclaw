# Plan: Model Download, Serving via TGI Helm Chart, Docs, and Local Clone

## Status: Complete

## Completed Work

### Step 0: Clone repo locally ✅
- Cloned `dyerinnovation/agent-skill-adapter` into local working directory
- Configured `gh auth setup-git` locally for HTTPS push

### Step 1: Create docs/ folder ✅
- Created 5 comprehensive docs:
  - `docs/01_dgx_spark_setup.md` — SSH, tools, PATH, GPU verification
  - `docs/02_model_download.md` — HF CLI download, cache, verification
  - `docs/03_model_serving.md` — TGI Helm deployment, OpenAI-compatible API
  - `docs/04_training_guide.md` — LoRA/QLoRA training workflow
  - `docs/05_docker_deployment.md` — Docker Compose and Helm deployment

### Step 2: Update README.md ✅
- Added Documentation section linking to all 5 docs

### Step 3: Add TGI Helm chart ✅
- Created `charts/tgi/` with Chart.yaml, values.yaml, deployment.yaml, service.yaml, _helpers.tpl
- Added TGI as dependency in umbrella chart `charts/skill-adapter/Chart.yaml`
- Added TGI config section in umbrella `charts/skill-adapter/values.yaml`
- `helm lint charts/tgi/` passes clean

### Step 4: Download model on Spark ✅
- **Important**: Model is `Qwen/Qwen3-8B` (not Qwen3-7B — no 7B variant exists)
- HF token was required (saved to `~/.cache/huggingface/token` on Spark)
- Download: 16.4GB, took ~21 minutes
- Verified via `scan_cache_dir()`: `Qwen/Qwen3-8B: 16.4G, revisions: 1`

### Step 5: Create inference service ✅
- Created `backend/src/services/inference.py` — async InferenceClient with:
  - `complete()`, `chat()`, `health_check()` methods
  - Exponential backoff retry (3 retries)
  - 30s default timeout
  - OpenAI-compatible endpoints (/v1/completions, /v1/chat/completions)
- Added `inference_url` to `config.py` Settings
- Added `SKILL_ADAPTER_INFERENCE_URL` to `.env.example`
- Updated evaluation controller to use inference when no model_path

### Step 6: Deploy TGI on Spark ⏸️ (Deferred)
- Helm chart is ready, model is downloaded
- Actual TGI pod deployment deferred — requires K8s cluster running on Spark
- Chart can be deployed with: `helm install tgi charts/tgi/`

### Step 7: Rewrite CLAUDE.md ✅
- Comprehensive project context with architecture, stack, commands, conventions

### Step 8: Tests ✅
- 95 tests passing (up from 67 before)
- New: unit tests for InferenceClient (test_inference.py, 347 lines)
- New: integration tests for inference + evaluation (test_inference_integration.py, 261 lines)
- Fixed import issues (parse_skill_file → parse_skill, Path.read_text mock)

## Key Corrections
- **Model name**: `Qwen/Qwen3-7B` does not exist. Corrected to `Qwen/Qwen3-8B` across all files
- **HF authentication**: Qwen3-8B requires a HuggingFace token for download

## Remaining Work
- Deploy TGI pod on Spark when K8s is available (`helm install tgi charts/tgi/`)
- Test TGI `/v1/models` endpoint and inference requests
- Run Playwright e2e tests for frontend after backend changes
- Consider switching to vLLM (TGI is in maintenance mode since Dec 2025)

## Commits
1. `6c302f1` — Add TGI model serving, inference service, docs, and tests (2501 lines added)
2. `6a3ca3e` — Fix import in inference integration test
3. `7e3d235` — Fix mock in integration test to patch Path.read_text
