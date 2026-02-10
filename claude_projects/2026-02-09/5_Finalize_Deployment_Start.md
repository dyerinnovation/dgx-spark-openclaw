# 5 — Finalize Michael Deployment

## Plan
1. **Helm Chart Fix**: Add `ANTHROPIC_SETUP_TOKEN` to secret.yaml and values.yaml
2. **Security Docs Update**: Rewrite baseline config in `docs/openclaw-security.md` to match valid OpenClaw schema
3. **Commit & Push** changes
4. **Helm Upgrade on Spark**: Pull latest, re-transfer `.env`, helm upgrade with setup token
5. **Verify**: Pod healthy, Slack connected, Anthropic auth working
6. **Slack Intro**: Send introductory message to `#michael-reports`

## Dependencies
- Steps 4-5 depend on step 3 (push)
- Step 6 depends on step 5 (pod healthy)
