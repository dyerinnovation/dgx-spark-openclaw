# Next Steps — OpenClaw "Michael" Deployment

## 1. Generate Claude Setup Token
```bash
claude setup-token
```
Copy the output and save to `.env` as `ANTHROPIC_SETUP_TOKEN` for reference. Note: this token is **not** used as an environment variable — it is pasted inside the pod via CLI during deployment. See [Deployment Guide](deployment-guide.md) for details.

---

## 2. Create Slack Workspace & App

1. Go to https://api.slack.com/apps → **Create New App** → **From scratch**
2. Name: `Michael` | Workspace: your workspace (e.g., "Dyer Innovation HQ")
3. **OAuth & Permissions** → add all Bot Token Scopes:

   | Scope | Purpose |
   |-------|---------|
   | `chat:write` | Send messages |
   | `channels:history` | Read messages in public channels |
   | `channels:read` | List and get info about channels |
   | `groups:history` | Read messages in private channels |
   | `groups:read` | List private channels |
   | `groups:write` | Manage private channels |
   | `im:history` | Read DM messages |
   | `im:read` | List DMs |
   | `im:write` | Open DMs |
   | `mpim:history` | Read group DM messages |
   | `mpim:read` | List group DMs |
   | `mpim:write` | Open group DMs |
   | `users:read` | View users |
   | `app_mentions:read` | Read @mention events |
   | `reactions:read` | Read emoji reactions |
   | `reactions:write` | Add emoji reactions |
   | `pins:read` | Read pinned messages |
   | `pins:write` | Pin messages |
   | `emoji:read` | Read custom emoji |
   | `commands` | Slash commands |
   | `files:read` | Read files |
   | `files:write` | Upload files |

4. **Event Subscriptions** → toggle **Enable Events** to ON → expand **Subscribe to bot events** → add:

   | Event | Purpose |
   |-------|---------|
   | `app_mention` | When someone @mentions Michael |
   | `message.channels` | Messages in public channels |
   | `message.groups` | Messages in private channels |
   | `message.im` | Direct messages |
   | `message.mpim` | Group direct messages |
   | `reaction_added` | When someone adds a reaction |
   | `reaction_removed` | When someone removes a reaction |
   | `member_joined_channel` | When someone joins a channel |
   | `member_left_channel` | When someone leaves a channel |
   | `channel_rename` | When a channel is renamed |
   | `pin_added` | When a message is pinned |
   | `pin_removed` | When a message is unpinned |

   Click **Save Changes**.

5. **Install to Workspace** → copy the **Bot User OAuth Token** (`xoxb-...`)
6. Copy the **Signing Secret** from the **Basic Information** page
7. **Enable Socket Mode**: **Settings → Socket Mode → Enable**
   - Generate an **App-Level Token** with `connections:write` scope → copy the token (`xapp-...`)
8. Create channels: `#michael-tasks`, `#michael-approvals`, `#michael-reports`
9. Invite the Michael bot to all three channels (`/invite @Michael`)
10. Add to `.env`:
    ```
    SLACK_BOT_TOKEN=xoxb-...
    SLACK_APP_TOKEN=xapp-...
    SLACK_SIGNING_SECRET=...
    ```

> **Important**: If you later add scopes or events, you must **Reinstall to Workspace** under OAuth & Permissions and update `SLACK_BOT_TOKEN` in `.env` with the new token.

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

## 6. Deploy

Once all `.env` values are filled, follow the [Deployment Guide](deployment-guide.md) for the full procedure including Helm install, post-deploy configuration, and verification.
