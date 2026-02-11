# OpenClaw Deployment Guide

> Deploy Michael (OpenClaw agent) to DGX Spark (K3s cluster).

---

## Prerequisites

- SSH access to DGX Spark: `ssh jondyer3@spark-b0f2.local`
- `.env` file with all required secrets (see `.env.example`)
- K3s running with GPU Operator and NGINX Ingress
- Helm chart at `charts/openclaw/`

---

## Step 1: Transfer Files to Spark

Transfer `.env` and Helm chart to the deploy directory on Spark:
```bash
scp .env jondyer3@spark-b0f2.local:~/deploy/dgx-spark-openclaw/.env
rsync -av charts/ jondyer3@spark-b0f2.local:~/deploy/dgx-spark-openclaw/charts/
```

---

## Step 2: Deploy with Helm

SSH to Spark and run `helm install` (first time) or `helm upgrade` (subsequent deploys):
```bash
ssh jondyer3@spark-b0f2.local
cd ~/deploy/dgx-spark-openclaw
set -a && source .env && set +a

# First deploy
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install openclaw charts/openclaw/ \
  -n openclaw --create-namespace \
  --set secrets.anthropicApiKey="$ANTHROPIC_API_KEY" \
  --set secrets.slackBotToken="$SLACK_BOT_TOKEN" \
  --set secrets.slackAppToken="$SLACK_APP_TOKEN" \
  --set secrets.slackSigningSecret="$SLACK_SIGNING_SECRET" \
  --set secrets.openaiApiKey="$OPENAI_API_KEY" \
  --set secrets.elevenlabsApiKey="$ELEVENLABS_API_KEY"

# Subsequent deploys
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade openclaw charts/openclaw/ \
  -n openclaw \
  --set secrets.anthropicApiKey="$ANTHROPIC_API_KEY" \
  --set secrets.slackBotToken="$SLACK_BOT_TOKEN" \
  --set secrets.slackAppToken="$SLACK_APP_TOKEN" \
  --set secrets.slackSigningSecret="$SLACK_SIGNING_SECRET" \
  --set secrets.openaiApiKey="$OPENAI_API_KEY" \
  --set secrets.elevenlabsApiKey="$ELEVENLABS_API_KEY"
```

---

## Step 3: Post-Deploy Setup

### Run Doctor
```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
  kubectl exec -n openclaw deploy/openclaw-gateway -- node openclaw.mjs doctor --fix
```

### Paste Anthropic Setup Token
The setup token must be pasted interactively inside the pod:
```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
  kubectl exec -it -n openclaw deploy/openclaw-gateway -- \
  openclaw models auth paste-token --provider anthropic
```
Paste the token from `ANTHROPIC_SETUP_TOKEN` in `.env` when prompted.

### Enable Slack Plugin
After doctor runs, verify the Slack plugin is enabled. If doctor disabled it:
```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
  kubectl exec -n openclaw deploy/openclaw-gateway -- \
  cat /home/node/.openclaw/openclaw.json
```
Check that `plugins.entries.slack.enabled` is `true`.

---

## Step 4: Verify

```bash
# Pod is running
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl get pods -n openclaw
# Expected: openclaw-gateway-xxx   1/1   Running

# Logs look clean (no missing_scope, no auth errors, Slack connected)
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl logs -n openclaw -l app=openclaw --tail=50

# Health check
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
  kubectl exec -n openclaw deploy/openclaw-gateway -- curl -s http://127.0.0.1:18789/healthz

# Test from ingress
curl -H "Host: openclaw.spark-b0f2.local" http://172.20.14.68:80/healthz
```

Then test Slack:
1. Send a DM to Michael → should get a response
2. @mention Michael in a channel → should respond

---

## Rollback

```bash
# List revisions
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm history openclaw -n openclaw

# Rollback
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm rollback openclaw <REVISION> -n openclaw

# Emergency stop
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
  kubectl scale deployment openclaw-gateway -n openclaw --replicas=0

# Full uninstall
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm uninstall openclaw -n openclaw
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl delete namespace openclaw
```

---

## Updating the Soul Document

When `OpenClaw-Soul.md` is updated:
1. Commit and push changes
2. Transfer to Spark
3. Run `helm upgrade` (soul.md is mounted via ConfigMap)
4. Pod restarts and picks up the new soul document

---

## Troubleshooting

| Issue | Check |
|-------|-------|
| Pod CrashLoopBackOff | `kubectl logs -n openclaw -l app=openclaw --previous` |
| Health check fails | Verify port 18789, check startup logs |
| Ingress not routing | `kubectl describe ingress -n openclaw` |
| Secrets not loaded | `kubectl exec -n openclaw deploy/openclaw-gateway -- env \| grep -c API` |
| Slack not connecting | Check `SLACK_APP_TOKEN` (xapp-) is set, Socket Mode enabled in app config |
| Missing scopes | Reinstall app to workspace after adding scopes, update `SLACK_BOT_TOKEN` |
