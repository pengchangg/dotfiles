#!/usr/bin/env bash
# check.sh — verify dotfiles are deployed correctly
# Usage: cd ~/.dotfiles && ./check.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
FAILS=0
WARNS=0
CHECKS=0

pass() { echo -e "  ${GREEN}✓${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*"; FAILS=$((FAILS + 1)); }
warn() { echo -e "  ${YELLOW}⚠${NC}  $*"; WARNS=$((WARNS + 1)); }

# ── Helper: resolve symlink to absolute path (cross-platform) ─
resolve() {
    # Returns absolute path of symlink target, or empty string on failure.
    # Does NOT trigger set -e on broken links.
    local result
    if command -v realpath &>/dev/null; then
        result=$(realpath "$1" 2>/dev/null) && echo "$result"
    else
        result=$(readlink -f "$1" 2>/dev/null) && echo "$result"
    fi
}

# ── Helper: check symlink exists and points to correct target ─
check_link() {
    local target="$1"    # expected absolute path (e.g. /root/.bashrc)
    local source="$2"    # expected source in dotfiles (e.g. /root/.dotfiles/bash/.bashrc)
    local actual
    CHECKS=$((CHECKS + 1))
    if [[ -L "$target" ]]; then
        actual=$(resolve "$target") || actual="<broken>"
        if [[ "$actual" == "$source" ]]; then
            pass "$target"
        else
            fail "$target → $actual (expected $source)"
        fi
    elif [[ -e "$target" ]]; then
        fail "$target exists but is not a symlink (stow not applied)"
    else
        fail "$target missing"
    fi
}

# ── Helper: check binary in PATH ─────────────────────────────
check_bin() {
    local bin="$1"
    local pkg="${2:-}"
    CHECKS=$((CHECKS + 1))
    if command -v "$bin" &>/dev/null; then
        pass "$bin"
    else
        local hint=""
        [[ -n "$pkg" ]] && hint=" ($pkg)"
        fail "$bin not found$hint"
    fi
}

# ── Helper: check file permission ────────────────────────────
check_perm() {
    local path="$1"
    local expected="$2"
    local actual
    CHECKS=$((CHECKS + 1))
    if [[ -e "$path" ]]; then
        actual=$(stat -c '%a' "$path" 2>/dev/null || stat -f '%Lp' "$path" 2>/dev/null) || actual="???"
        if [[ "$actual" == "$expected" ]]; then
            pass "$path ($expected)"
        else
            warn "$path perms=$actual (expected $expected)"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
echo ""
echo "  🔍  dotfiles health check"
echo "  ────────────────────────"
echo ""

# Detect active shell
if [[ "$SHELL" == */zsh ]]; then
    SHELL_PKG="zsh"
else
    SHELL_PKG="bash"
fi

# ── git ───────────────────────────────────────────────────────
echo "  git"
check_link "$HOME/.gitconfig"   "$DOTFILES/git/.gitconfig"

# ── gnupg ───────────────────────────────────────────────────────
echo "  gnupg"
check_link "$HOME/.gnupg/gpg.conf"       "$DOTFILES/gnupg/.gnupg/gpg.conf"
check_link "$HOME/.gnupg/gpg-agent.conf" "$DOTFILES/gnupg/.gnupg/gpg-agent.conf"
check_link "$HOME/.gnupg/common.conf"    "$DOTFILES/gnupg/.gnupg/common.conf"

# ── shell (bash or zsh) ────────────────────────────────────────
echo "  $SHELL_PKG"
case "$SHELL_PKG" in
    bash)
        check_link "$HOME/.bashrc"                   "$DOTFILES/bash/.bashrc"
        check_link "$HOME/.bash_profile"             "$DOTFILES/bash/.bash_profile"
        check_link "$HOME/.profile"                  "$DOTFILES/bash/.profile"
        check_link "$HOME/.config/bash/bashrc"       "$DOTFILES/bash/.config/bash/bashrc"
        check_link "$HOME/.config/bash/fzf.sh"       "$DOTFILES/bash/.config/bash/fzf.sh"
        check_link "$HOME/.config/bash/profile"      "$DOTFILES/bash/.config/bash/profile"
        ;;
    zsh)
        check_link "$HOME/.zshrc"                    "$DOTFILES/zsh/.zshrc"
        check_link "$HOME/.zshenv"                   "$DOTFILES/zsh/.zshenv"
        check_link "$HOME/.config/zsh/zshrc"         "$DOTFILES/zsh/.config/zsh/zshrc"
        check_link "$HOME/.config/zsh/zshenv"        "$DOTFILES/zsh/.config/zsh/zshenv"
        check_link "$HOME/.config/zsh/fzf.zsh"       "$DOTFILES/zsh/.config/zsh/fzf.zsh"
        ;;
esac
check_link "$HOME/.config/starship.toml" "$DOTFILES/$SHELL_PKG/.config/starship.toml"

# ── lf ────────────────────────────────────────────────────────
echo "  lf"
check_link "$HOME/.config/lf/lfrc"  "$DOTFILES/lf/.config/lf/lfrc"
check_link "$HOME/.config/lf/pv.sh" "$DOTFILES/lf/.config/lf/pv.sh"

# ── tmux ──────────────────────────────────────────────────────
echo "  tmux"
check_link "$HOME/.tmux.conf" "$DOTFILES/tmux/.tmux.conf"

# ── nvim ──────────────────────────────────────────────────────
echo "  nvim"
check_link "$HOME/.config/nvim/init.lua" "$DOTFILES/nvim/.config/nvim/init.lua"

# ── ssh ───────────────────────────────────────────────────────
echo "  ssh"
if [[ -d "$HOME/.ssh" ]]; then
    check_perm "$HOME/.ssh" "700"
    # Check a few key files exist (not checking symlinks — ssh may use real files)
    for f in "$HOME/.ssh/config" "$HOME/.ssh/id_ed25519"; do
        CHECKS=$((CHECKS + 1))
        if [[ -f "$f" ]]; then
            pass "$f"
        else
            # Not all machines have all key types; warn but don't fail
            warn "$f not present (may be intentional)"
        fi
    done
else
    warn "~/.ssh not found (git-crypt may not be unlocked)"
fi

# ── Dependencies ──────────────────────────────────────────────
echo ""
echo "  📦  dependencies"
check_bin "git"
check_bin "gpg"        "gnupg"
check_bin "stow"
check_bin "git-crypt"
check_bin "starship"
check_bin "fzf"
check_bin "rg"         "ripgrep"
check_bin "fd"
check_bin "bat"
check_bin "glow"
check_bin "lf"
check_bin "tmux"
check_bin "nvim"       "neovim"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "  ────────────────────────"
if (( FAILS == 0 && WARNS == 0 )); then
    echo -e "  ${GREEN}✔${NC}  All ${CHECKS} checks passed."
elif (( FAILS == 0 )); then
    echo -e "  ${YELLOW}⚠${NC}   ${CHECKS} checks: ${WARNS} warnings, ${FAILS} failures."
else
    echo -e "  ${RED}✗${NC}  ${CHECKS} checks: ${WARNS} warnings, ${FAILS} failures."
    echo "  Run: cd ~/.dotfiles && ./bootstrap.sh"
fi
echo ""
