#!/usr/bin/env bash
# bootstrap.sh — 一键部署 dotfiles
# Usage: cd ~/.dotfiles && ./bootstrap.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Platform detection
OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      error "Unsupported OS: $OS" ;;
esac

# ── 1.5 Shell selection ─────────────────────────────────────
if [[ "$PLATFORM" == "macos" ]]; then
    DEFAULT_SHELL="zsh"
else
    DEFAULT_SHELL="bash"
fi

echo ""
echo "  🐚  Select shell for this machine:"
echo "      1) bash"
echo "      2) zsh"
echo "      default: $DEFAULT_SHELL"
echo ""

if [[ -n "${DOTFILES_SHELL:-}" ]]; then
    SHELL_CHOICE="$DOTFILES_SHELL"
elif [[ -t 0 ]]; then
    read -rp "  Choice [1/2, Enter=$DEFAULT_SHELL]: " SHELL_CHOICE
fi

case "${SHELL_CHOICE:-}" in
    1|bash|Bash|BASH) SHELL_PKG="bash"; SHELL_RC="~/.bashrc" ;;
    2|zsh|Zsh|ZSH)     SHELL_PKG="zsh";  SHELL_RC="~/.zshrc"  ;;
    "")  SHELL_PKG="$DEFAULT_SHELL"; SHELL_RC="~/.${DEFAULT_SHELL}rc" ;;
    *)   error "Invalid choice: $SHELL_CHOICE (enter 1 or 2)" ;;
esac

# Stow packages (shell-dependent)
PACKAGES=(git gnupg "$SHELL_PKG" lf tmux nvim ssh)

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
    if [[ "$PLATFORM" == "macos" ]]; then
        echo "  brew install ${MISSING[*]}"
        echo "  (or: brew bundle --file=$DOTFILES/Brewfile to install everything)"
    else
        echo "  pacman -S ${MISSING[*]}"
        echo "  (or: pacman -S --needed - < $DOTFILES/packages.txt to install everything)"
    fi
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
step "Deploying packages (shell: $SHELL_PKG)..."
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

    set +e  # best-effort: some files may fail (broken symlinks, permission denied, etc.)
    find "$HOME/.ssh" -type f ! -name '*.pub' ! -name 'known_hosts*' ! -name 'config' -exec chmod 600 {} + 2>/dev/null
    find "$HOME/.ssh" -type f \( -name '*.pub' -o -name 'known_hosts*' -o -name 'config' \) -exec chmod 644 {} + 2>/dev/null
    set -e

    echo "  done"
fi

# ── 7. Done ────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}✔${NC}  Bootstrap complete."
echo ""
echo "  Next steps:"
echo "    source $SHELL_RC          # reload shell config"
echo "    gpg --import gpg-backup.asc  # (if not done above)"

# Shell switch hint (if chosen shell differs from current login shell)
case "$SHELL_PKG" in
    bash)
        if [[ "$PLATFORM" == "macos" ]]; then
            # macOS: need brew bash (system bash is 3.2)
            BREW_PREFIX="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
            TARGET_SHELL="$BREW_PREFIX/bin/bash"
        else
            TARGET_SHELL="$(command -v bash)"
        fi
        ;;
    zsh)
        TARGET_SHELL="$(command -v zsh)"
        ;;
esac

CURRENT_SHELL_NAME="$(basename "${SHELL:-}")"

if [[ "$CURRENT_SHELL_NAME" != "$SHELL_PKG" && -n "$TARGET_SHELL" ]]; then
    echo ""
    echo "  💡  To make $SHELL_PKG your default login shell:"
    echo "      chsh -s $TARGET_SHELL"
fi

echo ""
