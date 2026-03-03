# bwrb

Schema-driven note management CLI for markdown vaults.

## Stack
- **Language:** TypeScript
- **Runtime:** Node.js
- **Testing:** Vitest
- **CLI Framework:** Commander.js
- **Validation:** Zod
- **Repo:** Public

## What It Does
- Manages markdown notes with structured frontmatter schemas
- Validates notes against Zod schemas
- Provides CLI commands for creating, listing, searching, and organizing notes
- Designed for use with Obsidian-style markdown vaults (like teenylilthoughts)

## Architecture
- CLI entry point: `src/index.ts` or `src/cli.ts`
- Schemas define the shape of frontmatter for different note types
- Commands use Commander.js for argument parsing
- ~52 open issues — active development

## Working Here
```bash
./bootstrap.sh --clone bwrb
cd /home/user/workspace/bwrb
npm install
npm test        # Run the test suite
npm run build   # Compile TypeScript
```

## Key Context
- This is Alice's personal tool — she uses it for her own note-taking workflow
- Pairs with teenylilthoughts (the vault) but is a standalone CLI
- Tests are important — always run `npm test` before committing
- Check open issues before starting work to avoid duplicating effort
