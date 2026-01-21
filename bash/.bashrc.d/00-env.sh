# History
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="ls:cd:pwd:clear:exit"
shopt -s histappend

# Shell 行为
shopt -s autocd cdspell checkwinsize extglob globstar
#set -o vi

# Tmux 环境检测和 TERM 处理
if [ -n "$TMUX" ]; then
    # 在 tmux 中，确保 TERM 设置为 tmux-256color 或 screen-256color
    if [ -z "$TERM" ] || [ "$TERM" = "screen" ] || [ "$TERM" = "xterm" ]; then
        # 检查 terminfo 是否支持 tmux-256color
        if infocmp tmux-256color >/dev/null 2>&1; then
            export TERM=tmux-256color
        elif infocmp screen-256color >/dev/null 2>&1; then
            export TERM=screen-256color
        fi
    fi
fi

# Python / Node
export PYTHONWARNINGS=ignore
export PIP_DISABLE_PIP_VERSION_CHECK=1
export NPM_CONFIG_FUND=false

export PATH=$PATH:/sbin:/usr/sbin:/usr/local/nvim/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin

export EDITOR=nvim
export VISUAL=nvim
