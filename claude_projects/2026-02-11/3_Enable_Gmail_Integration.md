# Future: Enable Gmail Integration for Michael

## Steps (when ready)
1. Set up Gmail API credentials (OAuth or service account)
2. Add Gmail secrets to `.env` and Helm `--set` flags
3. Update `charts/openclaw/values.yaml` to enable Gmail plugin
4. Update `BOOTSTRAP.md` to add email monitoring tasks back to active list
5. Update `TOOLS.md` to reflect Gmail as available
6. Redeploy via `upgrade.sh`
7. Test: ask Michael to check emails
