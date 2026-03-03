#!/usr/bin/env bash
#
# Bootstrap script for Perplexity Computer sessions
#
# Usage:
#   ./bootstrap.sh --decrypt                     # Decrypt secrets only
#   ./bootstrap.sh --clone <repo> [--vercel]     # Clone a repo (optionally link Vercel)
#   ./bootstrap.sh --clone-all                   # Clone all active repos
#   ./bootstrap.sh --tools-only                  # Install tools without decrypting
#   ./bootstrap.sh --status                      # Show what's set up
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="$SCRIPT_DIR/secrets/agent-env.sops.yaml"
DECRYPTED_FILE="/tmp/agent-secrets.sh"
AGE_BIN="/tmp/age/age"
AGE_KEYGEN_BIN="/tmp/age/age-keygen"
SOPS_BIN="/tmp/sops"
WORKSPACE="/home/user/workspace"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}==> ${NC}$1"; }
success() { echo -e "${GREEN}==> ${NC}$1"; }
warn()    { echo -e "${YELLOW}==> ${NC}$1"; }
error()   { echo -e "${RED}==> ${NC}$1"; }

# ── Install tools ────────────────────────────────────

install_age() {
  if [[ -x "$AGE_BIN" ]]; then
    return
  fi
  info "Installing age..."
  curl -sL https://github.com/FiloSottile/age/releases/download/v1.2.1/age-v1.2.1-linux-amd64.tar.gz -o /tmp/age.tar.gz
  tar -xzf /tmp/age.tar.gz -C /tmp/
  chmod +x /tmp/age/age /tmp/age/age-keygen
  rm /tmp/age.tar.gz
  success "age installed"
}

install_sops() {
  if [[ -x "$SOPS_BIN" ]]; then
    return
  fi
  info "Installing sops..."
  curl -sL https://github.com/getsops/sops/releases/download/v3.9.4/sops-v3.9.4.linux.amd64 -o "$SOPS_BIN"
  chmod +x "$SOPS_BIN"
  success "sops installed"
}

install_vercel() {
  if command -v vercel &>/dev/null; then
    success "Vercel CLI already installed"
    return
  fi
  info "Installing Vercel CLI..."
  npm install -g vercel@latest 2>/dev/null
  success "Vercel CLI installed"
}

install_gh() {
  if command -v gh &>/dev/null; then
    return
  fi
  info "Installing GitHub CLI..."
  curl -sL https://github.com/cli/cli/releases/download/v2.67.0/gh_2.67.0_linux_amd64.tar.gz -o /tmp/gh.tar.gz
  tar -xzf /tmp/gh.tar.gz -C /tmp/
  cp /tmp/gh_2.67.0_linux_amd64/bin/gh /usr/local/bin/gh 2>/dev/null || cp /tmp/gh_2.67.0_linux_amd64/bin/gh /tmp/gh
  rm -rf /tmp/gh.tar.gz /tmp/gh_2.67.0_linux_amd64
  success "gh CLI installed"
}

install_tools() {
  install_age
  install_sops
  install_vercel
  install_gh
  success "All tools installed"
}

# ── Decrypt secrets ──────────────────────────────────

decrypt_secrets() {
  if [[ -f "$DECRYPTED_FILE" ]]; then
    success "Secrets already decrypted"
    source "$DECRYPTED_FILE"
    return
  fi

  if [[ ! -f "$SECRETS_FILE" ]]; then
    error "Secrets file not found: $SECRETS_FILE"
    return 1
  fi

  install_age
  install_sops

  # Get the age private key
  local age_key="${AGENT_AGE_KEY:-}"

  if [[ -z "$age_key" ]]; then
    echo ""
    info "Paste the age private key (AGE-SECRET-KEY-1...) and press Enter:"
    read -r age_key
  fi

  if [[ ! "$age_key" =~ ^AGE-SECRET-KEY- ]]; then
    error "Invalid age key format. Must start with AGE-SECRET-KEY-"
    return 1
  fi

  # Write key to temp file for sops
  local keyfile="/tmp/agent-age-key.txt"
  echo "$age_key" > "$keyfile"
  chmod 600 "$keyfile"

  # Decrypt with sops
  info "Decrypting secrets..."
  local decrypted
  decrypted=$(SOPS_AGE_KEY_FILE="$keyfile" "$SOPS_BIN" -d "$SECRETS_FILE" 2>/dev/null)

  if [[ $? -ne 0 || -z "$decrypted" ]]; then
    rm -f "$keyfile"
    error "Decryption failed. Is the age key correct?"
    return 1
  fi

  # Parse YAML and write as shell exports
  # Simple parser for flat key: "value" YAML
  echo "# Agent secrets — decrypted at $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$DECRYPTED_FILE"
  echo "# This file is ephemeral and lives only in /tmp" >> "$DECRYPTED_FILE"
  echo "$decrypted" | grep -E '^[A-Z_]+:' | while IFS=': ' read -r key value; do
    # Strip quotes
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    echo "export ${key}=\"${value}\"" >> "$DECRYPTED_FILE"
  done

  chmod 600 "$DECRYPTED_FILE"
  rm -f "$keyfile"

  # Source the secrets
  source "$DECRYPTED_FILE"
  success "Secrets decrypted and loaded"
}

# ── Configure git ────────────────────────────────────

setup_git() {
  if [[ -z "${GITHUB_PAT:-}" ]]; then
    warn "GITHUB_PAT not set — git clone of private repos won't work"
    return
  fi

  git config --global user.name "Alice Alexandra"
  git config --global user.email "alice@alicealexandra.com"
  git config --global url."https://${GITHUB_PAT}@github.com/".insteadOf "https://github.com/"
  success "Git configured (Alice Alexandra)"
}

# ── Clone a repo ─────────────────────────────────────

clone_repo() {
  local repo="$1"
  local dest="$WORKSPACE/$repo"

  if [[ -d "$dest" ]]; then
    success "$repo already cloned at $dest"
    return
  fi

  info "Cloning $repo..."
  git clone "https://github.com/3mdistal/${repo}.git" "$dest"
  success "Cloned $repo → $dest"
}

setup_vercel_project() {
  local dir="$1"
  local orig_dir="$(pwd)"

  cd "$dir"

  if [[ -z "${VERCEL_TOKEN:-}" ]]; then
    warn "VERCEL_TOKEN not set — skipping Vercel setup"
    cd "$orig_dir"
    return
  fi

  info "Linking Vercel project for $(basename "$dir")..."
  if npx vercel link --token="$VERCEL_TOKEN" --yes 2>/dev/null; then
    npx vercel env pull .env.local --token="$VERCEL_TOKEN" 2>/dev/null || true
    success "Vercel linked + env vars pulled for $(basename "$dir")"
  else
    warn "No Vercel project found for $(basename "$dir") (that's fine)"
  fi

  cd "$orig_dir"
}

install_deps() {
  local dir="$1"
  local orig_dir="$(pwd)"

  cd "$dir"

  if [[ -f "pnpm-lock.yaml" ]]; then
    npm install -g pnpm 2>/dev/null || true
    pnpm install
  elif [[ -f "package-lock.json" ]]; then
    npm install
  elif [[ -f "yarn.lock" ]]; then
    npm install -g yarn 2>/dev/null || true
    yarn install
  elif [[ -f "package.json" ]]; then
    npm install
  fi

  success "Dependencies installed for $(basename "$dir")"
  cd "$orig_dir"
}

# ── Clone all active repos ───────────────────────────

clone_all() {
  # Read active repos from repos.yaml (simple grep approach)
  local repos=(
    julielmoore.com
    alicealexandra.com
    bwrb
    teenylilconfig
  )

  for repo in "${repos[@]}"; do
    clone_repo "$repo"
  done

  success "All active repos cloned"
}

# ── Status ───────────────────────────────────────────

show_status() {
  echo ""
  info "teenylilconfig-agent status"
  echo "─────────────────────────────────"

  # Secrets
  if [[ -f "$DECRYPTED_FILE" ]]; then
    echo -e "  Secrets:    ${GREEN}decrypted${NC}"
  else
    echo -e "  Secrets:    ${YELLOW}not decrypted${NC}"
  fi

  # Env vars
  for var in GITHUB_PAT VERCEL_TOKEN OPENAI_API_KEY; do
    if [[ -n "${!var:-}" ]]; then
      echo -e "  $var: ${GREEN}set${NC} (${!var:0:8}...)"
    else
      echo -e "  $var: ${YELLOW}not set${NC}"
    fi
  done

  # Tools
  for tool in git vercel gh; do
    if command -v "$tool" &>/dev/null; then
      echo -e "  $tool:       ${GREEN}installed${NC}"
    else
      echo -e "  $tool:       ${YELLOW}not installed${NC}"
    fi
  done

  # Cloned repos
  echo ""
  info "Cloned repos in $WORKSPACE:"
  for dir in "$WORKSPACE"/*/; do
    if [[ -d "$dir/.git" ]]; then
      local name="$(basename "$dir")"
      local branch="$(cd "$dir" && git branch --show-current 2>/dev/null || echo '?')"
      echo "  $name ($branch)"
    fi
  done

  echo ""
}

# ── Main ─────────────────────────────────────────────

main() {
  if [[ $# -eq 0 ]]; then
    echo "Usage:"
    echo "  ./bootstrap.sh --decrypt                   Decrypt secrets + install tools"
    echo "  ./bootstrap.sh --clone <repo> [--vercel]   Clone a repo"
    echo "  ./bootstrap.sh --clone-all                 Clone all active repos"
    echo "  ./bootstrap.sh --tools-only                Install tools only"
    echo "  ./bootstrap.sh --status                    Show current status"
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --decrypt)
        install_tools
        decrypt_secrets
        setup_git
        shift
        ;;
      --clone)
        shift
        if [[ -z "${1:-}" ]]; then
          error "Specify a repo name: ./bootstrap.sh --clone <repo>"
          exit 1
        fi
        local repo="$1"
        shift
        clone_repo "$repo"
        if [[ "${1:-}" == "--vercel" ]]; then
          setup_vercel_project "$WORKSPACE/$repo"
          install_deps "$WORKSPACE/$repo"
          shift
        fi
        ;;
      --clone-all)
        clone_all
        shift
        ;;
      --tools-only)
        install_tools
        shift
        ;;
      --status)
        show_status
        shift
        ;;
      *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
  done
}

main "$@"
