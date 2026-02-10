# Plan: Enable Claude Code Agent Team Mode

## Objective
Enable the experimental agent teams feature in Claude Code so multiple Claude instances can work in parallel as a coordinated team using tmux.

## Steps
1. Install tmux via Homebrew (`brew install tmux`)
2. Edit `~/.claude/settings.json` to add `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var and `teammateMode: "tmux"`
3. Restart Claude Code and verify teammates can be spawned

## Files Modified
- `~/.claude/settings.json` — added env var and teammateMode
- `claude_projects/2026-02-07/1_Enable_Agent_Team_Mode_Start.md` — this file
- `claude_projects/2026-02-07/1_Enable_Agent_Team_Mode_End.md` — summary

## Notes
- Agent teams use significantly more tokens than single sessions
- Each teammate is a fully separate session with its own context window
- Teammates inherit permissions, CLAUDE.md, MCP servers, and skills from the lead
- Avoid assigning same files to multiple teammates to prevent conflicts
- Use `Shift+Up/Down` to navigate between teammates
