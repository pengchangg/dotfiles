#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# 如果存在 /etc/bash.bashrc
[[ -f /etc/bash.bashrc ]] && source /etc/bash.bashrc

# ===========================================
#   通用 Bash 配置（适用于所有 Linux / macOS）
# ===========================================

# ----- 基础设置 -----
export EDITOR=nvim
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="ls:cd:pwd:clear:exit"
shopt -s histappend     # 追加写入 history
shopt -s autocd         # 输入目录自动 cd
shopt -s cdspell        # 自动更正 cd 拼写
shopt -s checkwinsize   # 自动更新窗口大小
shopt -s extglob        # 扩展 glob
shopt -s globstar       # ** 递归匹配

# ----- PATH 优化 -----
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ----- 彩色 ls / grep -----
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# ----- 常用别名 -----
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

# ----- Git 快捷 -----
alias gs='git status'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias ga='git add .'
alias gc='git commit -m'

# vim -> nvim
alias vi='nvim'
alias vim='nvim'

# cat -> bat
alias cat='bat'

# ----- 强化提示符 PS1 -----
# ============================
# Git prompt helper
# ============================
__git_ps1_status() {
    # 不在 git 仓库中直接返回
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch status

    # 当前分支
    branch=$(git symbolic-ref --short HEAD 2>/dev/null \
        || git describe --tags --exact-match 2>/dev/null \
        || git rev-parse --short HEAD 2>/dev/null)

    # 仓库状态
    if ! git diff --quiet --ignore-submodules --cached; then
        status="+"
    elif ! git diff --quiet --ignore-submodules; then
        status="*"
    else
        status=""
    fi

    # 未跟踪文件
    if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
        status="${status}?"
    fi

    printf " (%s%s)" "$branch" "$status"
}

PS1='\[\e[1;32m\][\u@\h \W]\[\e[33m\]$(__git_ps1_status)\[\e[1;32m\]\$\[\e[0m\] '


# ----- 安全：防止 rm 覆盖 -----
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ----- 压缩／解压通用函数 -----
extract () {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "无法解压 '$1' (未知格式)" ;;
    esac
  else
    echo "'$1' 不是一个有效的文件"
  fi
}

# ----- Python / Node 优化 -----
export PYTHONWARNINGS="ignore"
export PIP_DISABLE_PIP_VERSION_CHECK=1
export NPM_CONFIG_FUND=false

# ----- 自动补全（如果存在） -----
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# -------------------------------
# 加载本地私有配置（可选）
# -------------------------------
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.git-workflow.sh ] && source ~/.git-workflow.sh
[ -f $HOME/.cargo/env ] && source  "$HOME/.cargo/env"

# alias man="~/.local/bin/colored_man.sh"
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"


alias reloadBash="source ~/.bashrc"

# tmux  alias
# 快速 attach 或新建 session
alias ta='tmux attach -t'        # 用法：ta mysession
alias tn='tmux new -s'           # 用法：tn mysession

# 列出 session
alias tls='tmux ls'

# 杀掉 session
alias tk='tmux kill-session -t'  # 用法：tk mysession

# 重载配置
alias trc='tmux source-file ~/.tmux.conf \; display-message "tmux config reloaded"'

# ===== tmux session 自动补全 =====
_tmux_sessions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(tmux ls 2>/dev/null | awk -F: '{print $1}')" -- "$cur") )
}

# 绑定到 ta / tk / tn（可扩展）
complete -F _tmux_sessions ta
complete -F _tmux_sessions tk

# rg 搜索忽略文件
alias rgs='rg --hidden --no-ignore --glob "!**/.git/**"  -n -C 2 --color=always'
alias rgl='rg --hidden --no-ignore --glob "!**/.git/**" -l'  # 只列出包含匹配内容的文件

export FZF_DEFAULT_OPTS='
--height 60%
--border
--info=inline
--preview "bat --style=numbers --color=always {} | head -500"
'

# 默认命令列出文件（fd 更快）
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'

# 文件选择并打开
fe() {
  local file
  file=$(fzf \
    --height 60% \
    --reverse \
    --border \
    --preview "bat --style=numbers --color=always {} | head -500") || return
  ${EDITOR:-vim} "$file"
}

