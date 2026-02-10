# Plan: Deploy Qwen3-30B-A3B on DGX Spark

## Context
Currently serving Qwen3-8B (16GB) via vLLM on K3s. The DGX Spark has 125GB unified RAM and 3.4TB free disk. Qwen3-30B-A3B is a MoE model (30B total, 3.3B active, 128 experts/8 active per token) that fits easily in memory (~18GB BF16) while being significantly more capable than the 8B model.

## Steps

### Step 1: Download the model (SSH to Spark)
```bash
export PATH=$HOME/.local/bin:$HOME/.nvm/versions/node/v22.22.0/bin:$PATH
uv run huggingface-cli download Qwen/Qwen3-30B-A3B
```
~18GB download to `~/.cache/huggingface/hub/models--Qwen--Qwen3-30B-A3B/`.

### Step 2: Update Helm chart values
Update `charts/tgi/values.yaml`:
- `model.id`: `Qwen/Qwen3-8B` → `Qwen/Qwen3-30B-A3B`

Update `charts/skill-adapter/values.yaml` (umbrella chart) with same model.id change.

### Step 3: Update deployment template
Add `--enable-reasoning --reasoning-parser deepseek_r1` args to `charts/tgi/templates/deployment.yaml` for MoE thinking mode support.

### Step 4: Upgrade Helm release (SSH to Spark)
```bash
cd ~/agent-skill-adapter && git pull
helm upgrade tgi charts/tgi/
```

### Step 5: Verify
```bash
kubectl get pods -w  # Wait for pod to be Running
kubectl logs -l app.kubernetes.io/name=tgi --tail=20  # Check vLLM loaded model
curl -s <pod-ip>:8080/v1/models  # Verify model name is Qwen3-30B-A3B
```

### Step 6: Update docs and CLAUDE.md
- Update CLAUDE.md in both repos to reference Qwen3-30B-A3B
- Update docs references

### Step 7: Commit and push

## Files to Modify
- `charts/tgi/values.yaml` — model.id
- `charts/tgi/templates/deployment.yaml` — add reasoning args
- `charts/skill-adapter/values.yaml` — model.id in tgi section
- `CLAUDE.md` (both repos) — model reference
