# julielmoore.com

Julie L. Moore's poetry website — Alice's mom.

## Stack
- **Framework:** Next.js (App Router)
- **CMS:** Payload CMS (embedded, not headless-only)
- **Database:** Vercel Postgres
- **Media:** Vercel Blob storage
- **Hosting:** Vercel
- **Repo:** Private

## Architecture
- Payload is integrated directly into the Next.js app (not a separate service)
- Collection schemas live in `payload.config.ts` / `src/collections/`
- Content is managed through Payload's admin panel at `/admin`
- Frontend renders poems, books, events, and biographical content

## Key Context
- Recently rebuilt from WordPress — some content may still be migrating
- Julie is a published poet — the site showcases her books, individual poems, events, and bio
- Design should be elegant, readable, literary — not flashy tech
- Alice cares deeply about this project (it's for her mom)

## Working Here
```bash
./bootstrap.sh --clone julielmoore.com --vercel
cd /home/user/workspace/julielmoore.com
# .env.local now has DATABASE_URL, BLOB_READ_WRITE_TOKEN, PAYLOAD_SECRET, etc.
npm install
npm run dev
```

## Gotchas
- Payload's admin panel needs a running database — `npm run dev` won't fully work without env vars
- Image uploads go to Vercel Blob, not local filesystem
- Build can be slow due to Payload + Next.js compilation
