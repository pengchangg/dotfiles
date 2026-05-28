# ~/.config/bash/fzf.sh — fzf configuration and keybindings

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# File preview for Ctrl+T
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers,header {} 2>/dev/null || cat {}"'

if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
    # Ctrl+T — file selector (official fzf method)
    __fzf_select() {
        FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
        FZF_DEFAULT_OPTS="--reverse --walker=file,dir,follow,hidden --scheme=path ${FZF_CTRL_T_OPTS-} -m" \
        FZF_DEFAULT_OPTS_FILE='' fzf "$@" | while read -r item; do
            printf '%q ' "$item"
        done
    }

    fzf-file-widget() {
        local selected
        selected=$(__fzf_select "$@")
        READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
        READLINE_POINT=$((READLINE_POINT + ${#selected}))
    }

    # Ctrl+R — history search (official fzf method)
    __fzf_history() {
        local output
        output=$(HISTTIMEFORMAT= fc -lnr 1 2>/dev/null |
            FZF_DEFAULT_OPTS="--reverse --scheme=history ${FZF_CTRL_R_OPTS-} --query=${READLINE_LINE:+--query=}$READLINE_LINE" \
            FZF_DEFAULT_OPTS_FILE='' fzf +s --tac)
        READLINE_LINE=${output#*$'\t'}
        [[ -z $READLINE_LINE ]] || {
            READLINE_LINE=${READLINE_LINE#*$'\t'}
            READLINE_POINT=${#READLINE_LINE}
            return 0
        }
    }

    # Alt+C — cd (uses macro approach from official fzf to avoid bind -x issues)
    __fzf_cd() {
        local dir
        dir=$(FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
            FZF_DEFAULT_OPTS="--reverse --walker=dir,follow,hidden --scheme=path ${FZF_ALT_C_OPTS-} +m" \
            FZF_DEFAULT_OPTS_FILE='' fzf) || return
        [[ -n $dir ]] && printf 'builtin cd -- %q' "$dir"
    }

    # Bind with -m emacs-standard to avoid completion keymap conflicts
    bind -m emacs-standard -x '"\C-t": fzf-file-widget'
    bind -m vi-insert -x '"\C-t": fzf-file-widget'
    bind -m emacs-standard -x '"\C-r": __fzf_history'
    bind -m vi-insert -x '"\C-r": __fzf_history'
    # Alt+C uses macro (not bind -x) to avoid the [ error
    bind -m emacs-standard '"\ec": " \C-b\C-k \C-u`__fzf_cd`\e\C-e\e\C-a\C-y\C-h\C-e \C-y\ey\C-x\C-x\C-d\C-y\ey\C-_"'
    bind -m vi-insert '"\ec": "\C-z\ec\C-z"'
fi
