# Agent Instructions — teenylilconfig-agent

You are working for Alice Alexandra, a content strategist and technical writer at Builder.io. This repo orients you to her development environment when running in an ephemeral cloud sandbox (Perplexity Computer).

## Environment

- **Runtime:** Perplexity Computer — sandboxed Linux VM (2 vCPU, 8GB RAM, ~20GB disk)
- **Pre-installed:** Node.js 20, Python 3.12, git, curl, jq, standard Unix tools
- **NOT pre-installed:** Vercel CLI, Playwright, project-specific dependencies, sops, age
- **Workspace:** `/home/user/workspace` (persistent within a session)

## Bootstrap

Before doing any work that requires repo access or credentials, run the bootstrap script:

```bash
# Clone this repo first (if not already present)
git clone https://github.com/3mdistal/teenylilconfig-agent.git /home/user/workspace/teenylilconfig-agent

# Then bootstrap (you'll need the age private key — ask Alice)
cd /home/user/workspace/teenylilconfig-agent
./bootstrap.sh --decrypt
```

This will:
1. Install age and sops
2. Decrypt secrets (requires age private key via `AGENT_AGE_KEY` env var or interactive paste)
3. Configure git with the decrypted `GITHUB_PAT`
4. Install Vercel CLI

After bootstrap, clone and set up specific repos:

```bash
./bootstrap.sh --clone julielmoore.com --vercel
./bootstrap.sh --clone bwrb
./bootstrap.sh --clone-all   # clone all active repos
```

## Available Credentials (after decryption)

Credentials are stored in `secrets/agent-env.sops.yaml` (encrypted with age). After running `./bootstrap.sh --decrypt`, they are available as shell exports sourced from `/tmp/agent-secrets.sh`.

- `GITHUB_PAT` — Clone private repos, push code, authenticate gh CLI
- `VERCEL_TOKEN` — Vercel CLI for deploys, env pulls, project management
- `OPENAI_API_KEY` — Direct OpenAI API calls (if needed outside built-in models)

### Vercel Cascading Access

`VERCEL_TOKEN` is a skeleton key. Once authenticated, run `vercel env pull` per project to get project-specific secrets (database URLs, API keys, blob tokens, etc.) without them being stored here.

```bash
cd <project-dir>
npx vercel link --token=$VERCEL_TOKEN --yes
npx vercel env pull .env.local --token=$VERCEL_TOKEN
```

## What You Can Do Without Bootstrap

Computer has a **built-in GitHub connector** (API-level) that's already authenticated. Use it for:
- Reading file contents from any of Alice's repos
- Creating/updating issues and PRs
- Pushing files via the API
- Code search across repos

The bootstrap is needed when you must:
- Clone a full repo and run it locally
- Execute tests, build, or deploy
- Use the Vercel CLI
- Access project env vars via `vercel env pull`

## Repos

See `repos.yaml` for the full manifest with metadata. Key active repos:

### Active Development
- **julielmoore.com** — Mom's poetry site. Next.js + Payload CMS, Vercel Postgres, Vercel Blob storage. Private. Recently rebuilt from WordPress.
- **alicealexandra.com** — Personal portfolio/blog. Svelte. Public. Has open design system issues. Content in separate `teenylilcontent` repo.
- **bwrb** — Schema-driven note management CLI for markdown vaults. TypeScript. Public. ~52 open issues. Tests via `npm test`.
- **teenylilconfig** — Personal dotfiles (macOS + NixOS). Private. Stow-based. Agent should mostly read, not modify.

### Work
- **builder** — Builder.io internal work. Private.

### Tools
- **ralph** — Autonomous coding task orchestrator for OpenCode. TypeScript. Public.
- **teenylilqueue** — Self-hosted GitHub merge queue on Vercel. Public.
- **css-mcp-server** — Demo MCP server for CSS knowledge. TypeScript. Public, 32 stars.

### Personal
- **teenylilthoughts** — Journal + tasks vault. Private. **READ-ONLY for agent context. Do not modify.**
- **teenylilcontent** — Content for sites. Private.

## Conventions

### Code Style
- Prettier for formatting (default config)
- TypeScript preferred for new projects
- Prefer named exports over default exports
- Use async/await over .then() chains

### Git
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`
- PRs: descriptive titles, link to issues when applicable
- Never force-push to main
- Agent commits as: Alice Alexandra <alice@alicealexandra.com>

### Deployment
- **Never deploy to production without confirming with Alice**
- Preview deploys are fine
- Always run builds locally before pushing (if possible in the sandbox)

### Writing
- Active voice preferred
- Casual, clear tone for technical content
- Inspired by Developer Advocates like Cassie Williams and Scott Tolinski

## What NOT To Do

- Never commit secrets or private keys to any repo
- Never force-push to main
- Never deploy to production without asking
- Never modify teenylilthoughts entries (read-only for context)
- Never store the age private key anywhere persistent — it exists only in session memory
