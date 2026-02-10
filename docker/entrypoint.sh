#!/bin/bash
set -e

# Create ~/.openclaw if it doesn't exist (PVC may be empty on first run)
mkdir -p ~/.openclaw
chmod 700 ~/.openclaw

# Copy mounted config into ~/.openclaw/ (OpenClaw reads from here)
if [ -f /etc/openclaw/openclaw.json ]; then
    cp /etc/openclaw/openclaw.json ~/.openclaw/openclaw.json
    chmod 600 ~/.openclaw/openclaw.json
fi

# Copy soul document
if [ -f /etc/openclaw/soul.md ]; then
    cp /etc/openclaw/soul.md ~/.openclaw/soul.md
fi

# Run non-interactive onboard if not already done
if [ ! -f ~/.openclaw/.onboarded ]; then
    openclaw onboard --non-interactive \
        --mode local \
        --auth-choice anthropic-api-key \
        --anthropic-api-key "$ANTHROPIC_API_KEY" || echo "Onboard completed with warnings"
    touch ~/.openclaw/.onboarded
fi

exec "$@"
