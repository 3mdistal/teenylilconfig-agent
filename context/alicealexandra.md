# alicealexandra.com

Alice's personal portfolio and blog.

## Stack
- **Framework:** SvelteKit (Svelte 5 with Runes)
- **Hosting:** Vercel
- **Content:** Stored in separate `teenylilcontent` repo
- **Repo:** Public

## Architecture
- SvelteKit file-based routing (`src/routes/`)
- Content is pulled from the `teenylilcontent` repo (markdown or structured data)
- Design system is in progress — there are open issues for this
- Portfolio showcases Alice's writing, technical work, and creative projects

## Key Context
- Alice is a trans woman, content strategist, and technical writer at Builder.io
- The site should reflect her identity and creative voice
- Has open design system issues — check Issues tab before making design changes
- Public repo — anyone can see the code

## Working Here
```bash
./bootstrap.sh --clone alicealexandra.com --vercel
cd /home/user/workspace/alicealexandra.com
npm install  # or pnpm install
npm run dev
```

## Related Repos
- **teenylilcontent** — Content source (private). Clone separately if you need to edit content.
