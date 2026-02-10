# Summary: Increase Max Token Length & Clean Up Qwen3-8B Artifacts

## Completed

### Step 1: Chart Updates (maxModelLen)
- `charts/tgi/values.yaml`: `maxModelLen: 8192` → `40960`
- `charts/skill-adapter/values.yaml`: `maxModelLen: 8192` → `40960`
- Note: Originally targeted 131072 (128K) with YaRN rope scaling, but:
  - vLLM does not accept `--rope-scaling` as a CLI arg (reads from model config)
  - Model's `max_position_embeddings` is 40960, not 32768
  - vLLM refuses maxModelLen > max_position_embeddings without `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`
  - Using 40960 (model native max) is the safe choice

### Step 2: Replaced Qwen3-8B → Qwen3-30B-A3B
All 9 source/config/test files updated (11 files changed total). Verified with `grep -rn "Qwen3-8B"` — no remaining references.

### Step 3: Deleted old 8B model cache
`~/.cache/huggingface/hub/models--Qwen--Qwen3-8B/` removed, freeing ~16GB.

### Step 4: Tests
All 95 tests passing.

### Step 5: Commits & Push
- `92af460` — Initial changes (maxModelLen 131072, 8B refs replaced)
- `fe068e3` — Remove --rope-scaling CLI arg (vLLM reads from model config)
- `cdd271e` — Set maxModelLen to 40960 (model native max_position_embeddings)

### Step 6: Helm Upgrade & Verification
- Helm revision 8 deployed
- Pod running and ready (1/1)
- `/v1/models` confirms: `Qwen/Qwen3-30B-A3B`, `max_model_len: 40960`
- Model uses 56.9 GiB RAM, loads in ~5.5 min (16 shards)

## Lessons Learned
- Qwen3-30B-A3B has `max_position_embeddings: 40960` (not 32768 as assumed)
- vLLM `--rope-scaling` is not a valid CLI flag; it reads rope config from model's `config.json`
- To exceed native context, set env var `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1` (risky for RoPE models)

## CLAUDE.md Updates
- Added: `maxModelLen: 40960 (40K context, model's native max_position_embeddings)`
- Added: local repo structure notes (claude_projects not in git)
