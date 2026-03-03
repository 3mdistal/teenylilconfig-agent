# Git Conventions

## Commits

[Conventional Commits](https://www.conventionalcommits.org/) format:

```
type(scope): description

[optional body]
```

### Types
- `feat:` — New feature
- `fix:` — Bug fix
- `docs:` — Documentation only
- `chore:` — Maintenance, deps, config
- `refactor:` — Code change that doesn't fix or add
- `test:` — Adding or updating tests
- `style:` — Formatting, whitespace (not CSS)

### Scope (optional)
Use the component or area: `feat(cms):`, `fix(auth):`, `docs(readme):`

### Examples
```
feat(cms): add image gallery block to Payload
fix: resolve hydration mismatch on poem pages
chore: update dependencies
docs: add deployment instructions to README
```

## Branches

- `main` — production-ready, always deployable
- Feature branches: `feat/description` or `fix/description`
- No long-lived branches — merge or close within days

## Pull Requests

- Descriptive title (same format as commits)
- Link related issues: `Closes #123` or `Relates to #45`
- Keep PRs focused — one logical change per PR
- Agent-created PRs should note they were created by the agent

## Rules

- **Never force-push to main**
- **Never deploy to production without confirming with Alice**
- Preview deploys are fine and encouraged
- Always run builds locally before pushing when possible
- Rebase or squash merge to keep history clean

## Agent Identity

When committing as the agent:

```
git config user.name "Alice Alexandra"
git config user.email "alice@alicealexandra.com"
```

The bootstrap script handles this automatically.
