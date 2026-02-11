# Fix Auth Format — Proper auth-profiles.json Generation

## Date: 2026-02-11

## Problem
Michael (OpenClaw agent) fails with "No API key found for provider anthropic" on every Slack message. The manually-created `auth-profiles.json` is missing the `type` field required by OpenClaw's `coerceLegacyStore()` parser, causing the entry to be silently skipped.

## Root Cause
1. We have a setup token (`sk-ant-oat01-...` in `ANTHROPIC_SETUP_TOKEN`), not an API key
2. The auth-profiles.json was missing `type: "token"` field — OpenClaw requires this
3. The file also lacked the `version: 1` + `profiles` wrapper expected by `coerceAuthStore()`

## Plan
1. Add `ANTHROPIC_SETUP_TOKEN` to Helm secret and values
2. Update init-config container to generate auth-profiles.json from env var with correct format
3. Add `envFrom: secretRef` to init-config container so it can read the token
4. Deploy via git push + helm upgrade on Spark
5. Verify via pod logs and Slack test message

## Files Modified
- `charts/openclaw/templates/secret.yaml` — add ANTHROPIC_SETUP_TOKEN
- `charts/openclaw/values.yaml` — add anthropicSetupToken field
- `charts/openclaw/templates/deployment.yaml` — generate auth-profiles.json in init-config
