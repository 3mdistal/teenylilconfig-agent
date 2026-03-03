# Coding Style

Alice's coding conventions across repos.

## Language

- **TypeScript** for all new projects unless there's a specific reason not to
- Strict mode enabled (`"strict": true` in tsconfig)
- Prefer `type` over `interface` unless extending

## Formatting

- **Prettier** with default config (no .prettierrc needed unless overriding)
- No semicolons is fine if the project is already set up that way, otherwise keep Prettier defaults
- 2-space indentation (Prettier default)

## Imports & Exports

- Named exports over default exports
- Group imports: external libs → internal modules → types → relative
- Use path aliases when available (`$lib/`, `@/`, etc.)

## Async

- `async/await` over `.then()` chains
- Always handle errors — don't swallow promises silently
- Use `Promise.all()` for independent parallel work

## Functions

- Arrow functions for callbacks and short utilities
- Named function declarations for top-level module exports
- Descriptive names — no abbreviations except well-known ones (`req`, `res`, `ctx`)

## Types

- Avoid `any` — use `unknown` and narrow
- Zod for runtime validation (especially in bwrb and API routes)
- Prefer discriminated unions over optional fields for state

## Framework-Specific

### Svelte (alicealexandra.com)
- SvelteKit with file-based routing
- `+page.svelte`, `+page.ts`, `+layout.svelte` conventions
- Runes API for reactivity (Svelte 5)

### Next.js (julielmoore.com)
- App Router (not Pages)
- Server Components by default, `"use client"` only when needed
- Payload CMS integration — check `payload.config.ts` for collection schemas

### CLI / Node (bwrb, ralph)
- Commander.js for CLI argument parsing
- Zod schemas for config validation
- Tests via Vitest (`npm test`)

## Comments

- Write comments for "why", not "what"
- JSDoc for public API functions
- TODO comments with context: `// TODO(alice): reason — issue #123`
