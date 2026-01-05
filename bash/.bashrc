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

#  vim --> nvim
alias vi='nvim'
alias vim='nvim'

# cat -> bat
alias cat='bat'

# ----- 强化提示符 PS1 -----
if [[ $EUID == 0 ]]; then
  PS1='\[\e[1;32m\][\u@\h \W]\$\[\e[0m\] '
else
  PS1='\[\e[1;32m\][\u@\h \W]\$\[\e[0m\] '
fi

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

# alias man="~/.local/bin/colored_man.sh"
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"

