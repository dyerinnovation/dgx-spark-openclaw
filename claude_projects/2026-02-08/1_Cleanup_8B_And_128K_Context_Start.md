# Plan: Increase Max Token Length to 128K & Clean Up Qwen3-8B Artifacts

## Objective
1. Increase `maxModelLen` from 8192 to 131072 (128K context) with YaRN rope scaling
2. Replace all hardcoded `Qwen/Qwen3-8B` references with `Qwen/Qwen3-30B-A3B`
3. Delete old 8B model cache (~16GB) from Spark
4. Helm upgrade, test, commit, push

## Step 1: Chart Updates (maxModelLen + YaRN)
- `charts/tgi/values.yaml`: `maxModelLen: 8192` → `131072`
- `charts/skill-adapter/values.yaml`: same if applicable
- `charts/tgi/templates/deployment.yaml`: add `--rope-scaling '{"rope_type":"yarn","factor":4.0,"original_max_position_embeddings":32768}'`

## Step 2: Replace Qwen3-8B → Qwen3-30B-A3B
Files: `backend/src/models/config.py`, `backend/src/models/schemas.py`, `backend/tests/unit/test_schemas.py`, `backend/tests/integration/test_api.py`, `docker-compose.yaml`, `backend/.env.example`, `README.md`, `research/03_training_architecture.md`

## Step 3: Delete old cache
`rm -rf ~/.cache/huggingface/hub/models--Qwen--Qwen3-8B/`

## Step 4: Helm upgrade & restart
## Step 5: Run tests (95 should pass)
## Step 6: Commit, push, docs

## SSH Details
- `sshpass -p '<password>' ssh jondyer3@spark-b0f2.local '<command>'`
- Credentials in DGX-SPARK.md
