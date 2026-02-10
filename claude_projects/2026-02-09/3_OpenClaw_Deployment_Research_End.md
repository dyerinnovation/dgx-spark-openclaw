# OpenClaw Deployment Research - Complete Findings

## 1. `openclaw.json` Configuration Schema - All Valid Top-Level Keys

The config file lives at `~/.openclaw/openclaw.json` (JSON5 format - comments and trailing commas allowed). If missing, safe defaults apply.

**All valid top-level keys:**

| Key | Purpose |
|-----|---------|
| `agents` | Agent defaults, multi-agent routing, identity, sandbox config |
| `channels` | WhatsApp, Telegram, Discord, Slack, Signal, iMessage, Google Chat, Mattermost |
| `models` | Custom provider definitions and model catalog |
| `session` | Session scoping, reset policies, identity linking |
| `messages` | Inbound/outbound prefixes, ack reactions, TTS |
| `tools` | Tool allowlists, sandbox policies, elevated access |
| `gateway` | Server port, auth, restart behavior, mode |
| `logging` | Log paths, console styling, redaction patterns |
| `auth` | OAuth profile metadata and provider rotation |
| `browser` | Chromium/CDP browser configuration |
| `skills` | Bundled skill allowlists and per-skill overrides |
| `plugins` | Extension discovery and per-plugin config |
| `web` | WhatsApp web channel runtime settings |
| `talk` | Voice configuration for Talk mode |
| `commands` | Chat command handling across channels |
| `wizard` | Metadata from CLI wizards (lastRunAt, lastRunVersion, etc.) |
| `env` | Environment variable loading and substitution |

**Strict validation**: Unknown keys, malformed types, or invalid values **prevent startup**. Use `openclaw doctor` to diagnose and `openclaw doctor --fix` to auto-migrate.

**Config includes**: Split configs with `$include` directive (up to 10 levels deep).

**Env var substitution**: Use `${VAR_NAME}` syntax in config strings (uppercase only). Missing vars throw errors.

---

## 2. Gateway Configuration (`gateway.mode=local`)

```json5
{
  gateway: {
    mode: "local",           // "local" or "remote"
    port: 18789,             // WS + HTTP multiplex
    bind: "loopback",        // "loopback" for local, "0.0.0.0" for network access
    controlUi: {
      enabled: true,
      basePath: "/openclaw"
    },
    auth: {
      mode: "token",
      token: "your-gateway-token",
      allowTailscale: true
    },
    tailscale: {
      mode: "off"            // "off" | "serve" | "funnel"
    },
    reload: {
      mode: "hybrid",
      debounceMs: 300
    }
  }
}
```

**For Docker/K8s**: Set `bind: "0.0.0.0"` so the gateway is accessible outside the container.

**Remote mode** (client connecting to gateway elsewhere):
```json5
{
  gateway: {
    mode: "remote",
    remote: {
      url: "ws://gateway.tailnet:18789",
      token: "your-token",
      password: "your-password"
    }
  }
}
```

---

## 3. Docker Deployment Approach

### Official Docker Setup (USE THIS - do NOT build custom images)

OpenClaw has an official Docker workflow in their repository:

**Quick start:**
```bash
./docker-setup.sh
```
This script:
1. Builds the gateway image from official Dockerfile
2. Runs the onboarding wizard
3. Starts the gateway via Docker Compose
4. Generates a gateway token to `.env`

**Manual approach:**
```bash
docker build -t openclaw:local -f Dockerfile .
docker compose run --rm openclaw-cli onboard
docker compose up -d openclaw-gateway
```

### docker-compose.yml Structure

```yaml
services:
  openclaw-gateway:
    image: ${OPENCLAW_IMAGE:-openclaw:local}
    init: true
    restart: unless-stopped
    ports:
      - "18789:18789"   # Gateway
      - "18790:18790"   # Bridge
    environment:
      - HOME
      - TERM
      - OPENCLAW_GATEWAY_TOKEN
      - CLAUDE_AI_SESSION_KEY
      - CLAUDE_WEB_SESSION_KEY
      - CLAUDE_WEB_COOKIE
    volumes:
      - ./config:/home/node/.openclaw    # Config + workspace
    command: node dist/index.js  # with gateway mode and bind settings

  openclaw-cli:
    image: ${OPENCLAW_IMAGE:-openclaw:local}
    environment:
      - HOME
      - TERM
      - OPENCLAW_GATEWAY_TOKEN
      - BROWSER=echo
    volumes:
      - ./config:/home/node/.openclaw
    stdin_open: true
    tty: true
    entrypoint: node dist/index.js
```

### Official Images
- **`openclaw-sandbox:bookworm-slim`** - Default sandbox image
- **`openclaw-sandbox-common:bookworm-slim`** - Includes Node, Go, Rust, build tools

### Build-time Environment Variables
- `OPENCLAW_DOCKER_APT_PACKAGES` - Install extra system packages
- `OPENCLAW_EXTRA_MOUNTS` - Extra host bind mounts (comma-separated)
- `OPENCLAW_HOME_VOLUME` - Persist `/home/node` in a named volume

---

## 4. JavaScript Heap Out of Memory Fix

The official Docker setup uses `NODE_ENV=production` in the Dockerfile. The docs do **not** document a specific `NODE_OPTIONS` setting for heap size. However, based on standard Node.js practices and the container environment:

**Recommended fix** - add to your Docker environment or Kubernetes pod spec:
```yaml
env:
  - name: NODE_OPTIONS
    value: "--max-old-space-size=4096"
```

For Raspberry Pi / low-memory systems, the docs recommend:
- Check memory with `free -h`
- Increase swap space
- Reduce concurrent services

**For our DGX Spark Helm chart**, add `NODE_OPTIONS` to the container env in the deployment template.

---

## 5. Slack Integration Configuration

Slack uses **Socket Mode exclusively** (no HTTP webhook needed).

### Minimal Config
```json5
{
  channels: {
    slack: {
      enabled: true,
      appToken: "xapp-...",    // or use SLACK_APP_TOKEN env var
      botToken: "xoxb-...",    // or use SLACK_BOT_TOKEN env var
    }
  }
}
```

### Full Slack Schema
```json5
{
  channels: {
    slack: {
      enabled: true,
      botToken: "xoxb-...",
      appToken: "xapp-...",
      dm: {
        enabled: true,
        policy: "pairing",       // pairing | allowlist | open | disabled
        allowFrom: ["U123", "U456"],
        groupEnabled: false,
        groupChannels: ["G123"]
      },
      channels: {
        "C123": { allow: true, requireMention: true, allowBots: false },
        "#general": {
          allow: true,
          requireMention: true,
          allowBots: false,
          users: ["U123"],
          skills: ["docs"],
          systemPrompt: "Short answers only."
        }
      },
      historyLimit: 50,
      allowBots: false,
      reactionNotifications: "own",  // off | own | all | allowlist
      reactionAllowlist: ["U123"],
      replyToMode: "off",           // off | first | all
      thread: {
        historyScope: "thread",      // thread | channel
        inheritParent: false
      },
      actions: {
        reactions: true,
        messages: true,
        pins: true,
        memberInfo: true,
        emojiList: true
      },
      slashCommand: {
        enabled: true,
        name: "openclaw",
        sessionPrefix: "slack:slash",
        ephemeral: true
      },
      textChunkLimit: 4000,
      chunkMode: "length",
      mediaMaxMb: 20
    }
  }
}
```

**Environment variable alternative** (recommended for security):
- `SLACK_APP_TOKEN` = `xapp-...`
- `SLACK_BOT_TOKEN` = `xoxb-...`

---

## 6. `openclaw onboard --non-interactive` Command

The onboard command runs the initial setup wizard. In non-interactive mode, all required values must be provided as flags.

**Common flags:**
```bash
openclaw onboard --non-interactive \
  --mode local \
  --auth-choice <provider>-api-key \
  --<provider>-api-key "$API_KEY"
```

**Provider-specific examples:**

```bash
# Anthropic/Claude
openclaw onboard --non-interactive \
  --mode local \
  --auth-choice anthropic-api-key \
  --anthropic-api-key "$ANTHROPIC_API_KEY"

# Together AI
openclaw onboard --non-interactive \
  --mode local \
  --auth-choice together-api-key \
  --together-api-key "$TOGETHER_API_KEY"

# OpenAI
openclaw onboard --non-interactive \
  --openai-api-key "$OPENAI_API_KEY"

# Z.AI
openclaw onboard --non-interactive \
  --zai-api-key "$ZAI_API_KEY"

# Venice
openclaw onboard --non-interactive \
  --auth-choice venice-api-key \
  --venice-api-key "$VENICE_API_KEY"
```

**Key flags:**
- `--non-interactive` - Skip wizard prompts
- `--mode local` - Set gateway mode to local
- `--auth-choice <choice>` - Select auth provider
- `--<provider>-api-key <key>` - Provide API key

The wizard writes metadata to the `wizard` section of config: `lastRunAt`, `lastRunVersion`, `lastRunCommit`, `lastRunCommand`, `lastRunMode`.

**In Docker:**
```bash
docker compose run --rm openclaw-cli onboard --non-interactive \
  --mode local \
  --auth-choice anthropic-api-key \
  --anthropic-api-key "$ANTHROPIC_API_KEY"
```

---

## 7. Required Environment Variables for Gateway Startup

**Minimum required:**
- `OPENCLAW_GATEWAY_TOKEN` - Gateway authentication token (generated during onboard/setup)

**Auth provider (one of):**
- `ANTHROPIC_API_KEY` - For Claude
- `OPENAI_API_KEY` - For OpenAI
- `TOGETHER_API_KEY` - For Together AI
- (or configured in openclaw.json via onboard)

**Slack (if using Slack channel):**
- `SLACK_APP_TOKEN` - Socket Mode app token (`xapp-...`)
- `SLACK_BOT_TOKEN` - Bot token (`xoxb-...`)

**Optional Docker-specific:**
- `OPENCLAW_IMAGE` - Override Docker image (default: `openclaw:local`)
- `OPENCLAW_DOCKER_APT_PACKAGES` - Extra apt packages
- `OPENCLAW_EXTRA_MOUNTS` - Extra volume mounts
- `OPENCLAW_HOME_VOLUME` - Named volume for home dir
- `NODE_OPTIONS` - Node.js runtime options (e.g., `--max-old-space-size=4096`)

**Environment variable loading order:**
1. Process-level env vars (highest priority)
2. `.env` in current directory
3. `~/.openclaw/.env` (fallback)

Config-level `env.vars` only apply if the variable is not already set.

---

## Recommendations for Our Helm Chart

Based on these findings, our `charts/openclaw/` Helm chart should:

1. **Use official Docker image build** rather than a custom Dockerfile -- clone the OpenClaw repo and build with their Dockerfile
2. **Run onboard non-interactively** as an init container:
   ```bash
   openclaw onboard --non-interactive --mode local --auth-choice anthropic-api-key --anthropic-api-key "$ANTHROPIC_API_KEY"
   ```
3. **Mount `openclaw.json`** via ConfigMap with gateway bind set to `0.0.0.0`
4. **Set `NODE_OPTIONS=--max-old-space-size=4096`** in pod environment to prevent heap OOM
5. **Use environment variables** for Slack tokens rather than hardcoding in config
6. **Expose port 18789** via the K8s Service / NGINX Ingress

---

## Work Remaining
- Update Helm chart templates based on these findings
- Test onboard in Docker with Anthropic API key
- Validate Slack Socket Mode connectivity from within K8s pod
- Determine if sandbox mode is needed or should be `off` for our use case
