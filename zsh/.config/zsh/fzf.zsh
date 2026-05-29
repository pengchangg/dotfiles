# ~/.config/zsh/fzf.zsh — fzf integration for zsh
# Uses fzf --zsh (fzf >= 0.48): cross-platform, path-agnostic

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# File preview for Ctrl+T
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers,header {} 2>/dev/null || cat {}"'

# Load official fzf key bindings and completion
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi
