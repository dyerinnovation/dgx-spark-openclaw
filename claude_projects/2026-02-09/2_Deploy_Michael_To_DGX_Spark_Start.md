# Deploy Michael (OpenClaw) to DGX Spark

## Plan
Execute the deployment of Michael (OpenClaw agent) to DGX Spark K3s cluster.

## Steps
1. Initialize git repo locally, commit all files, push to GitHub
2. Clone repo on Spark via SSH, transfer `.env`
3. Build Docker image on Spark (ARM64 native)
4. Import image into K3s containerd
5. Deploy with Helm, injecting all secrets from `.env`
6. Post-deploy verification (pod, health, ingress, security)
7. Configure secure baseline (`openclaw.json5`)
8. Connect to gateway and send introductory Slack message

## Prerequisites
- `.env` with 13 secrets (confirmed present)
- Helm chart, Dockerfiles, security docs all in place
- GitHub repo created at `https://github.com/dyerinnovation/dgx-spark-openclaw`
- SSH access to `jondyer3@spark-b0f2.local`

## Rollback
```bash
helm rollback openclaw 1 -n openclaw
kubectl scale deploy openclaw-gateway -n openclaw --replicas=0
helm uninstall openclaw -n openclaw
```
