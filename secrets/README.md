# Secrets (sops + age)

Encrypted secrets for agent sessions. The agent decrypts these at session start using a single age private key.

## Files

- `agent-env.sops.yaml` — Encrypted credentials (committed)
- `agent-env.yaml.example` — Unencrypted template showing the structure

## How It Works

1. Alice pastes the age private key at the start of a Computer session
2. `bootstrap.sh --decrypt` uses sops to decrypt `agent-env.sops.yaml`
3. Decrypted values are written to `/tmp/agent-secrets.sh` (ephemeral, never persisted)
4. The bootstrap script sources those exports into the shell

## Editing Secrets

To add or rotate a secret:

```bash
# You need the age private key available
export SOPS_AGE_KEY="AGE-SECRET-KEY-1..."

# Edit interactively (decrypts → opens editor → re-encrypts)
sops secrets/agent-env.sops.yaml

# Or decrypt, edit, re-encrypt manually
sops -d secrets/agent-env.sops.yaml > /tmp/plain.yaml
$EDITOR /tmp/plain.yaml
sops -e /tmp/plain.yaml > secrets/agent-env.sops.yaml
rm /tmp/plain.yaml
```

## Adding New Secrets

1. Decrypt the file
2. Add the new `KEY: "value"` line (flat YAML, all caps, no nesting)
3. Re-encrypt
4. Commit the encrypted file
5. Update AGENTS.md to document the new variable

## Security Notes

- The age private key is never committed, stored on disk, or persisted across sessions
- Decrypted values exist only in `/tmp/` which is ephemeral to the sandbox session
- The encrypted file is safe to commit (AES-256-GCM encryption)
