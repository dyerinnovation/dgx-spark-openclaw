# OpenClaw Deployment Guide

> Git-based deployment of Michael (OpenClaw agent) to DGX Spark (K3s cluster).

---

## Prerequisites
- SSH access to DGX Spark: `ssh jondyer3@spark-b0f2.local`
- Git remote configured on Spark (or GitHub access from Spark)
- `.env` file with all required secrets (see `.env.example`)
- Docker installed on Spark (for ARM64 native builds)
- K3s running with GPU Operator and NGINX Ingress

---

## Step 1: Push Repo via Git

On your local machine:
```bash
# Add Spark as a remote (one-time setup)
git remote add spark ssh://jondyer3@spark-b0f2.local:/home/jondyer3/repos/dgx-spark-clawdbot.git

# Push to Spark
git push spark main
```

Alternatively, push to GitHub and pull from Spark:
```bash
# On local machine
git push origin main

# On Spark
ssh jondyer3@spark-b0f2.local
cd ~/repos/dgx-spark-clawdbot
git pull origin main
```

---

## Step 2: Transfer Credentials

Credentials are **never** committed to git. Transfer `.env` via `scp`:
```bash
scp .env jondyer3@spark-b0f2.local:~/repos/dgx-spark-clawdbot/.env
```

Verify on Spark:
```bash
ssh jondyer3@spark-b0f2.local "ls -la ~/repos/dgx-spark-clawdbot/.env"
```

---

## Step 3: Build Docker Image on Spark

Build natively on Spark (ARM64):
```bash
ssh jondyer3@spark-b0f2.local
cd ~/repos/dgx-spark-clawdbot

docker build -f docker/Dockerfile.openclaw -t ghcr.io/dyerinnovation/openclaw:latest .
```

---

## Step 4: Import Image to K3s containerd

K3s uses containerd, not Docker. Import the image:
```bash
docker save ghcr.io/dyerinnovation/openclaw:latest | sudo k3s ctr images import -
```

Verify:
```bash
sudo k3s ctr images list | grep openclaw
```

---

## Step 5: Deploy with Helm

Source the `.env` file and deploy:
```bash
cd ~/repos/dgx-spark-clawdbot

# Source secrets
set -a && source .env && set +a

# Install (first time)
helm install openclaw charts/openclaw/ -n openclaw --create-namespace \
  --set secrets.anthropicSetupToken="$ANTHROPIC_SETUP_TOKEN" \
  --set secrets.anthropicApiKey="$ANTHROPIC_API_KEY" \
  --set secrets.slackBotToken="$SLACK_BOT_TOKEN" \
  --set secrets.slackSigningSecret="$SLACK_SIGNING_SECRET" \
  --set secrets.gmailAddress="$GMAIL_ADDRESS" \
  --set secrets.gmailAppPassword="$GMAIL_APP_PASSWORD" \
  --set secrets.openaiApiKey="$OPENAI_API_KEY" \
  --set secrets.elevenlabsApiKey="$ELEVENLABS_API_KEY" \
  --set secrets.gatewayToken="$GATEWAY_TOKEN"

# Upgrade (subsequent deploys)
helm upgrade openclaw charts/openclaw/ -n openclaw \
  --set secrets.anthropicSetupToken="$ANTHROPIC_SETUP_TOKEN" \
  --set secrets.anthropicApiKey="$ANTHROPIC_API_KEY" \
  --set secrets.slackBotToken="$SLACK_BOT_TOKEN" \
  --set secrets.slackSigningSecret="$SLACK_SIGNING_SECRET" \
  --set secrets.gmailAddress="$GMAIL_ADDRESS" \
  --set secrets.gmailAppPassword="$GMAIL_APP_PASSWORD" \
  --set secrets.openaiApiKey="$OPENAI_API_KEY" \
  --set secrets.elevenlabsApiKey="$ELEVENLABS_API_KEY" \
  --set secrets.gatewayToken="$GATEWAY_TOKEN"
```

---

## Step 6: Post-Deploy Verification

Run these checks after deployment:

```bash
# Pod is running
kubectl get pods -n openclaw
# Expected: openclaw-gateway-xxx   1/1   Running

# Logs look clean
kubectl logs -n openclaw -l app=openclaw --tail=50

# Health check responds
kubectl exec -n openclaw deploy/openclaw-gateway -- curl -s http://127.0.0.1:18789/healthz

# Ingress is configured
kubectl get ingress -n openclaw
# Expected: openclaw.spark-b0f2.local → openclaw:18789

# NetworkPolicy applied
kubectl get networkpolicy -n openclaw

# Secret exists
kubectl get secret -n openclaw openclaw-secrets

# Test from ingress
curl -H "Host: openclaw.spark-b0f2.local" http://172.20.14.68:80/healthz
```

---

## Step 7: Verify Security

```bash
# Confirm pod security context
kubectl get pod -n openclaw -l app=openclaw -o jsonpath='{.items[0].spec.containers[0].securityContext}'

# Confirm service account token not mounted
kubectl get pod -n openclaw -l app=openclaw -o jsonpath='{.items[0].spec.automountServiceAccountToken}'
# Expected: false

# Confirm NetworkPolicy egress rules
kubectl describe networkpolicy -n openclaw openclaw-egress
```

---

## Rollback Procedures

### Helm Rollback
```bash
# List revisions
helm history openclaw -n openclaw

# Rollback to previous revision
helm rollback openclaw <REVISION> -n openclaw
```

### Emergency Stop
```bash
# Scale to zero (keeps config, stops all processing)
kubectl scale deployment openclaw-gateway -n openclaw --replicas=0
```

### Full Uninstall
```bash
helm uninstall openclaw -n openclaw
kubectl delete namespace openclaw
```

---

## Updating the Soul Document

When `OpenClaw-Soul.md` is updated:
1. Commit changes to git
2. Push to Spark
3. Run `helm upgrade` (the soul.md is mounted via ConfigMap)
4. The pod will restart and pick up the new soul document

---

## Troubleshooting

| Issue | Check |
|-------|-------|
| Pod in CrashLoopBackOff | `kubectl logs -n openclaw -l app=openclaw --previous` |
| Health check fails | Verify port 18789 is correct, check container startup logs |
| Ingress not routing | `kubectl describe ingress -n openclaw` — check backend service |
| Secrets not loaded | `kubectl exec -n openclaw deploy/openclaw-gateway -- env \| grep -c API` |
| Image not found | Verify `k3s ctr images list \| grep openclaw` shows the image |
