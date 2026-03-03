# Project Templates

Common patterns for setting up new work in Alice's repos.

## Starting Work on a Repo

### With Vercel (julielmoore.com, teenylilqueue, etc.)

```bash
./bootstrap.sh --decrypt
./bootstrap.sh --clone julielmoore.com --vercel
cd /home/user/workspace/julielmoore.com
# .env.local is now populated with project secrets
npm run dev  # or pnpm dev
```

### Without Vercel (bwrb, css-mcp-server, etc.)

```bash
./bootstrap.sh --decrypt
./bootstrap.sh --clone bwrb
cd /home/user/workspace/bwrb
npm install
npm test
```

### Read-Only Context (teenylilthoughts)

```bash
./bootstrap.sh --clone teenylilthoughts
# Read files for context, but NEVER modify or commit
```

## New Project Checklist

When Alice asks you to start a new project:

1. Ask about the tech stack (usually TypeScript + one of: SvelteKit, Next.js, or plain Node)
2. Initialize with the appropriate package manager (check if Alice has a preference for the project)
3. Set up:
   - `tsconfig.json` with strict mode
   - `.prettierrc` (or use defaults)
   - `.gitignore` (node_modules, .env*, .vercel, dist, .next, .svelte-kit)
   - Basic README.md
4. If it's a web project:
   - Link to Vercel: `npx vercel link --token=$VERCEL_TOKEN --yes`
   - Set up environment variables via Vercel dashboard (confirm with Alice)
5. First commit: `chore: initial project setup`

## Common Tasks

### Run Tests
```bash
npm test          # Most repos use Vitest
```

### Build Check
```bash
npm run build     # Verify before pushing
```

### Deploy Preview
```bash
npx vercel --token=$VERCEL_TOKEN    # Preview deploy (safe)
npx vercel --prod --token=$VERCEL_TOKEN  # ⚠️ PRODUCTION — ask Alice first
```

### Pull Latest Env Vars
```bash
npx vercel env pull .env.local --token=$VERCEL_TOKEN
```
