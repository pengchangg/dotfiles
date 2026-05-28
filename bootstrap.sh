#!/usr/bin/env bash
# bootstrap.sh — 一键部署 dotfiles
# Usage: cd ~/.dotfiles && ./bootstrap.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
PACKAGES=(git gnupg bash lf tmux ssh)

step()  { echo -e "${GREEN}==>${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $*"; }
error() { echo -e "${RED}✗${NC}  $*"; exit 1; }

echo ""
echo "  🏠  dotfiles bootstrap"
echo "  ─────────────────────"
echo ""

# ── 1. Check working directory ──────────────────────────────
if [[ ! -d "$DOTFILES/.git" ]]; then
    error "$DOTFILES is not a git repo. Clone dotfiles first:"
    echo "  git clone <repo-url> $DOTFILES && cd $DOTFILES && ./bootstrap.sh"
fi
cd "$DOTFILES"
step "Working directory: $DOTFILES"

# ── 2. Check dependencies ───────────────────────────────────
step "Checking dependencies..."
MISSING=()
for cmd in stow git-crypt gpg; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
    fi
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
    error "Missing: ${MISSING[*]}"
    echo "  pacman -S stow git-crypt gnupg"
fi
echo "  all dependencies found"

# ── 3. Import GPG key ──────────────────────────────────────
step "GPG key setup"
if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q '^sec'; then
    echo "  GPG key already present:"
    gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep '^uid' | sed 's/^/  /'
else
    warn "No GPG secret key found."
    read -rp "  Path to GPG backup file (e.g. ~/gpg-backup.asc): " KEYFILE
    [[ -f "$KEYFILE" ]] || error "File not found: $KEYFILE"

    gpg --import "$KEYFILE"
    FPRINT=$(gpg --list-secret-keys --with-colons 2>/dev/null | grep '^fpr:' | head -1 | cut -d: -f10)
    echo "${FPRINT}:6:" | gpg --import-ownertrust
    step "GPG key imported: ${FPRINT:0:16}..."
fi

# ── 4. Unlock git-crypt ────────────────────────────────────
step "Decrypting secrets (git-crypt unlock)..."
if git-crypt status &>/dev/null; then
    if git-crypt status 2>&1 | grep -q 'not encrypted'; then
        echo "  repository is not encrypted — skipping"
    else
        echo "  already unlocked"
    fi
else
    error "git-crypt unlock failed. Is the GPG key trusted?"
fi

# ── 5. Deploy via stow ─────────────────────────────────────
step "Deploying packages..."
for pkg in "${PACKAGES[@]}"; do
    if [[ -d "$DOTFILES/$pkg" ]]; then
        printf "  %-10s " "$pkg"
        if stow "$pkg" 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${YELLOW}(already linked or no files)${NC}"
        fi
    else
        echo "  ${pkg}      ${YELLOW}(package not found, skipped)${NC}"
    fi
done

# ── 6. Fix SSH permissions ─────────────────────────────────
if [[ -d "$HOME/.ssh" ]]; then
    step "Fixing SSH permissions..."
    chmod 700 "$HOME/.ssh"
    find "$HOME/.ssh" -type f ! -name '*.pub' ! -name 'known_hosts*' ! -name 'config' -exec chmod 600 {} \; 2>/dev/null || true
    find "$HOME/.ssh" -name '*.pub' -o -name 'known_hosts*' -o -name 'config' | while read -r f; do
        chmod 644 "$f" 2>/dev/null || true
    done
    echo "  done"
fi

# ── 7. Done ────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}✔${NC}  Bootstrap complete."
echo ""
echo "  Next steps:"
echo "    source ~/.bashrc          # reload shell config"
echo "    gpg --import gpg-backup.asc  # (if not done above)"
echo ""
