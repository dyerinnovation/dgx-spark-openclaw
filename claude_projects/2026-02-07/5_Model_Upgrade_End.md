# Model Upgrade Summary: Qwen3-8B → Qwen3-30B-A3B

## Completed

1. **Downloaded Qwen3-30B-A3B** (~50GB on disk) to `~/.cache/huggingface/hub/models--Qwen--Qwen3-30B-A3B/` on DGX Spark
2. **Updated Helm charts**:
   - `charts/tgi/values.yaml` — model.id changed to `Qwen/Qwen3-30B-A3B`
   - `charts/skill-adapter/values.yaml` — same model.id change in tgi section
   - `charts/tgi/templates/deployment.yaml` — increased probe timeouts (liveness: 600s initial delay, readiness: 30s, failureThreshold: 30) to accommodate larger model loading time (~6 min)
3. **Removed `--enable-reasoning` args** — not supported by vLLM 26.01; was attempted per plan but reverted
4. **Updated all documentation**: CLAUDE.md (both repos), docs/01-05, .env.example — all Qwen3-8B references → Qwen3-30B-A3B
5. **Deployed via Helm** — `helm upgrade tgi charts/tgi/` (revision 5)
6. **Verified**: Pod running 1/1, `/v1/models` returns `Qwen/Qwen3-30B-A3B`, max_model_len=8192
7. **Committed and pushed** all changes (4 commits to dyerinnovation/agent-skill-adapter)

## Key Findings

- **Model size**: ~50GB on disk (larger than the ~18GB BF16 estimate — includes all safetensors shards)
- **Load time**: ~6 minutes for 16 safetensors shards (needed probe timeout increase from 120s to 600s)
- **vLLM 26.01 does NOT support `--enable-reasoning`** flag — this is a newer feature not in this version
- **Rolling updates fail** with GPU-bound pods since new pod can't schedule while old holds the GPU — need to delete old pod first or use Recreate strategy

## Remaining / Future

- Consider upgrading vLLM to a version that supports `--enable-reasoning` for thinking mode
- Consider increasing `maxModelLen` from 8192 to 32768 (native context length) if memory allows
- Consider setting deployment strategy to `Recreate` instead of `RollingUpdate` for GPU workloads
- The model is ~50GB which is larger than expected — could investigate quantized versions if memory becomes an issue
