# Typefully

Social media scheduling and publishing via the Typefully API. Used for managing Alice's posts across X, LinkedIn, Threads, Bluesky, and Mastodon.

## Credential

`TYPEFULLY_API_KEY` — stored in `secrets/agent-env.sops.yaml`, available after `./bootstrap.sh --decrypt`. Obtain from https://typefully.com/?settings=api.

## Official Agent Skill

Repo: https://github.com/typefully/agent-skills

Install into a session:

```bash
# CLI
npx skills add typefully/agent-skills

# Manual
git clone https://github.com/typefully/agent-skills.git /tmp/typefully-skills
cp -r /tmp/typefully-skills/skills/typefully .claude/skills/typefully
```

After install, the skill handles drafting, scheduling, and publishing. It reads `TYPEFULLY_API_KEY` from the environment.

## API v2 Quick Reference

Base URL: `https://api.typefully.com/v2`
Auth header: `Authorization: Bearer $TYPEFULLY_API_KEY`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v2/social-sets` | GET | List connected social accounts |
| `/v2/social-sets/{id}/drafts` | POST | Create a draft |
| `/v2/social-sets/{id}/drafts` | GET | List drafts (query: `status=draft\|scheduled\|published`) |

### Draft payload

```json
{
  "platforms": {
    "x": {
      "enabled": true,
      "posts": [{ "text": "Post content here" }]
    }
  },
  "publish_at": "next-free-slot"
}
```

`publish_at` accepts: ISO 8601 datetime, `"next-free-slot"`, or `"now"`.

## Safety

- Always confirm with Alice before using `publish_at: "now"`
- Scheduling (`"next-free-slot"` or a future datetime) is safe to do without confirmation
- Never log or echo the raw API key
