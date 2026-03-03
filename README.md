# teenylilconfig-agent

Portable agent environment configuration for [Perplexity Computer](https://www.perplexity.ai/hub/blog/introducing-perplexity-computer) sessions. The companion to [teenylilconfig](https://github.com/3mdistal/teenylilconfig) (human machine setup), optimized for ephemeral cloud sandboxes.

## What This Is

A lightweight repo that orients an AI agent to your development environment:
- **AGENTS.md** — tells the agent who you are, what repos exist, and what conventions to follow
- **repos.yaml** — structured manifest of all your GitHub repos with metadata
- **bootstrap.sh** — sets up credentials, tools, and repo access in a fresh sandbox
- **secrets/** — SOPS-encrypted credentials (GitHub PAT, Vercel token, etc.)
- **conventions/** — coding style and git workflow docs
- **context/** — per-project architecture notes and gotchas

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  Perplexity Computer Session                        │
│                                                     │
│  1. Clone teenylilconfig-agent                      │
│  2. Paste age key → bootstrap.sh --decrypt          │
│     ├── Installs age, sops, vercel CLI, gh          │
│     ├── Decrypts secrets → /tmp/agent-secrets.sh    │
│     └── Configures git with GITHUB_PAT              │
│  3. bootstrap.sh --clone <repo> --vercel            │
│     ├── Clones the repo                             │
│     ├── Links Vercel project                        │
│     ├── Pulls project env vars (.env.local)         │
│     └── Installs dependencies                       │
│  4. Agent does the actual work                      │
└─────────────────────────────────────────────────────┘
```

**Key insight:** `VERCEL_TOKEN` is a skeleton key — once authenticated, `vercel env pull` cascades into per-project database URLs, API keys, and blob tokens without storing them here.

## Setup (One-Time)

### 1. Generate an age keypair

Already done. The public key is in `.sops.yaml`. The private key is:

```
AGE-SECRET-KEY-1... (stored securely offline — never committed)
```

### 2. Add your real secrets

```bash
# Decrypt the placeholder file
sops secrets/agent-env.sops.yaml

# Replace placeholders with real values:
#   GITHUB_PAT: "ghp_..."     ← GitHub fine-grained PAT
#   VERCEL_TOKEN: "..."       ← Vercel account token
#   OPENAI_API_KEY: "sk-..."  ← OpenAI key

# sops auto-encrypts on save
```

### 3. Create the tokens

**GitHub PAT:**
- Go to: Settings → Developer settings → Fine-grained personal access tokens
- Name: `perplexity-computer`
- Repository access: All repositories
- Permissions: Contents (R/W), Issues (R/W), Pull requests (R/W), Metadata (Read)

**Vercel Token:**
- Go to: Account Settings → Tokens → Create
- Name: `perplexity-computer`
- Scope: Full Account

## Usage (Each Session)

At the start of a Computer session that needs repo/deploy access:

```
Paste this age key and run bootstrap:
AGE-SECRET-KEY-1...

Then: ./bootstrap.sh --decrypt
```

The agent handles the rest.

## Maintenance

| When | Do |
|------|----||
| New repo | Add entry to `repos.yaml`, optionally add `context/<name>.md` |
| Rotate token | `sops secrets/agent-env.sops.yaml`, update value, commit |
| New secret | Same as rotate, add the new key, update AGENTS.md |
| Change conventions | Update files in `conventions/` |

## Relationship to teenylilconfig

| | teenylilconfig | teenylilconfig-agent |
|--|--|--|
| **For** | Human (macOS/NixOS machine setup) | AI agent (ephemeral Linux sandbox) |
| **Secrets** | SOPS + age (personal keys) | SOPS + age (separate agent key) |
| **Config** | Stow packages, Brewfile, Nix flake | AGENTS.md, repos.yaml, bootstrap.sh |
| **Scope** | Full OS configuration | Credentials + orientation only |
