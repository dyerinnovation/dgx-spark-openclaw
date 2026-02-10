# X Articles Pipeline

Weekly article creation pipeline for Dyer Innovation's X presence.

## Schedule
- **Monday**: Topic research + 3 topic pitches → `#michael-approvals`
- **Tuesday**: Outline generation after topic selection
- **Wed-Thu**: Refinement via Slack feedback loop
- **Friday**: Draft creation using agent team (writer + image gen + critics)
- **Weekend**: Final draft for publishing approval

## Agent Team
- **Writer**: Produces full prose from approved outline
- **Image Generator**: Creates visuals via OpenAI from image prompts
- **Prose Critic**: Reviews writing quality, clarity, engagement
- **Image Critic**: Reviews visual relevance and quality
- **Holistic Reviewer**: Final coherence check across text + images

## Files
- `topic_research.py` — Cron job for trending AI topic research
- `outline_generator.py` — Generates structured outline from selected topic
- `draft_pipeline.py` — Orchestrates agent team for full draft creation
- `slack_integration.py` — Handles approval workflow via Slack
