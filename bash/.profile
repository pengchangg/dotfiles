# ~/.profile
# ==================================================
# Login shell entry (cross-distro, Bash-safe)
# ==================================================

[ -n "${__PROFILE_LOADED__}" ] && return
export __PROFILE_LOADED__=1

# ---------- 基础环境 ----------
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# ---------- PATH（去重安全写法） ----------
function path_prepend {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

export PATH=$PATH:/sbin:/usr/sbin:/usr/local/nvim/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin


# ---------- Bash 才加载 bashrc ----------
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

