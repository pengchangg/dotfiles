#!/usr/bin/env bash
# bootstrap.sh — 一键部署 dotfiles
# Usage: cd ~/.dotfiles && ./bootstrap.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
# DOTFILES_NO_SECRETS=1  ./bootstrap.sh   # skip git-crypt + SSH permissions

# Platform / distro detection
OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
    PLATFORM="macos"
    DISTRO="macos"
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    PLATFORM="linux"
    case "${ID:-}" in
        arch)                       DISTRO="arch" ;;
        debian|ubuntu|linuxmint)    DISTRO="debian" ;;
        rhel|centos|fedora|almalinux|rocky) DISTRO="rhel" ;;
        *)
            case "${ID_LIKE:-}" in
                *debian*)       DISTRO="debian" ;;
                *rhel*|*fedora*) DISTRO="rhel" ;;
                *)              DISTRO="${ID:-unknown}" ;;
            esac
            ;;
    esac
else
    PLATFORM="linux"
    DISTRO="unknown"
fi

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
PACKAGES=(git gnupg "$SHELL_PKG" starship lf tmux nvim ssh)

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
for cmd in stow; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
    fi
done
# git-crypt + gpg only required when secrets are enabled
if [[ -z "${DOTFILES_NO_SECRETS:-}" ]]; then
    for cmd in git-crypt gpg; do
        if ! command -v "$cmd" &>/dev/null; then
            MISSING+=("$cmd")
        fi
    done
fi
if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo -e "  ${RED}✗${NC}  Missing: ${MISSING[*]}"
    case "$PLATFORM" in
        macos)
            echo "  brew install ${MISSING[*]}"
            echo "  (or: brew bundle --file=$DOTFILES/Brewfile)"
            ;;
        linux)
            case "$DISTRO" in
                arch)
                    echo "  pacman -S ${MISSING[*]}"
                    echo "  (or: pacman -S --needed - < $DOTFILES/packages.arch.txt)"
                    ;;
                debian)
                    echo "  apt-get install -y ${MISSING[*]}"
                    echo "  (or: xargs -a $DOTFILES/packages.debian.txt apt-get install -y)"
                    ;;
                rhel)
                    echo "  dnf install -y epel-release  # if EPEL not already enabled"
                    echo "  dnf install -y ${MISSING[*]}"
                    echo "  (or: dnf install -y \$(cat $DOTFILES/packages.rhel.txt))"
                    ;;
                *)
                    echo "  install ${MISSING[*]} with your package manager"
                    ;;
            esac
            ;;
    esac
    exit 1
fi
echo "  all dependencies found"

# ── 3. Import GPG key ──────────────────────────────────────
if [[ -n "${DOTFILES_NO_SECRETS:-}" ]]; then
    echo ""
    :  # skip — secrets disabled
elif gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q '^sec'; then
    step "GPG key setup"
    gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep '^uid' | sed 's/^/  /'
else
    step "GPG key setup"
    warn "No GPG secret key found."
    read -rp "  Path to GPG backup file (e.g. ~/gpg-backup.asc): " KEYFILE
    [[ -f "$KEYFILE" ]] || error "File not found: $KEYFILE"

    gpg --import "$KEYFILE"
    FPRINT=$(gpg --list-secret-keys --with-colons 2>/dev/null | grep '^fpr:' | head -1 | cut -d: -f10)
    echo "${FPRINT}:6:" | gpg --import-ownertrust
    step "GPG key imported: ${FPRINT:0:16}..."
fi

# ── 4. Unlock git-crypt ────────────────────────────────────
if [[ -n "${DOTFILES_NO_SECRETS:-}" ]]; then
    warn "DOTFILES_NO_SECRETS is set — skipping secrets"
elif git-crypt status &>/dev/null; then
    step "Decrypting secrets (git-crypt unlock)..."
    if git-crypt status 2>&1 | grep -q 'not encrypted'; then
        echo "  repository is not encrypted — skipping (no secrets to unlock)"
    else
        echo "  already unlocked"
    fi
else
    warn "git-crypt unlock failed — GPG key not available"
    if [[ -t 0 ]]; then
        read -rp "  Skip secrets and continue? [y/N]: " SKIP
        if [[ ! "$SKIP" =~ ^[Yy] ]]; then
            error "Aborted. Import GPG key first, or: DOTFILES_NO_SECRETS=1 ./bootstrap.sh"
        fi
        warn "Proceeding without secrets"
    else
        echo "  (non-interactive: skipping secrets; set DOTFILES_NO_SECRETS=1 to silence this warning)"
    fi
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
if [[ -n "${DOTFILES_NO_SECRETS:-}" ]]; then
    :  # secrets disabled — skip SSH permissions fix
elif [[ -d "$HOME/.ssh" ]]; then
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
