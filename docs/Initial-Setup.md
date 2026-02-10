# Next Steps — OpenClaw "Michael" Deployment

## 1. Generate Claude Setup Token
```bash
claude setup-token
```
Copy the output and add to `.env`:
```
ANTHROPIC_SETUP_TOKEN=<paste-token-here>
```

---

## 2. Create Slack Workspace & App

1. Go to https://api.slack.com/apps → **Create New App** → **From scratch**
2. Name: `Michael` | Workspace: your workspace (e.g., "Dyer Innovation HQ")
3. **OAuth & Permissions** → add Bot Token Scopes:
   - `chat:write`, `chat:write.public`, `channels:read`, `channels:history`
   - `reactions:read`, `files:write`
   - `im:read`, `im:write`, `im:history`
4. **Install to Workspace** → copy the **Bot User OAuth Token** (`xoxb-...`)
5. Copy the **Signing Secret** from the **Basic Information** page
6. **Enable Socket Mode**: **Settings → Socket Mode → Enable**
   - Generate an **App-Level Token** with `connections:write` scope → copy the token (`xapp-...`)
7. Create channels: `#michael-tasks`, `#michael-approvals`, `#michael-reports`
8. Invite the Michael bot to all three channels (`/invite @Michael`)
9. Add to `.env`:
   ```
   SLACK_BOT_TOKEN=xoxb-...
   SLACK_APP_TOKEN=xapp-...
   SLACK_SIGNING_SECRET=...
   ```

---

## 3. Create Gmail Account for Michael

1. Create a Gmail account (e.g., `michael.dyer.innovation@gmail.com`)
2. Enable 2-Factor Authentication
3. Generate an App Password: **Google Account → Security → 2-Step Verification → App passwords**
4. Add to `.env`:
   ```
   GMAIL_ADDRESS=michael.dyer.innovation@gmail.com
   GMAIL_APP_PASSWORD=<app-password>
   ```

---

## 4. Get API Keys

| Service | URL | `.env` Variable |
|---------|-----|-----------------|
| OpenAI (image gen) | https://platform.openai.com/api-keys | `OPENAI_API_KEY` |
| ElevenLabs (audio) | https://elevenlabs.io/app/settings/api-keys | `ELEVENLABS_API_KEY` |

---

## 5. Clean Up Exposed Credentials

Once `.env` is populated, delete the plaintext credential files:
```bash
rm DGX-SPARK.md huggingface-token.txt
```
These are already in `.gitignore` but should not remain on disk.

---

## 6. Deploy (Run With Claude)

Once all `.env` values are filled, start a new Claude session and say:

> Deploy OpenClaw to the DGX Spark using the Helm chart and .env credentials.

This will:
1. SSH to the Spark and install OpenClaw
2. Build + push the Docker image
3. `helm install` the chart with your secrets
4. Verify the pod is running and Slack integration works
