# ls / grep
command -v dircolors >/dev/null && eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

# vim → nvim
alias vi='nvim'
alias vim='nvim'

# cat → bat（存在才替换）
command -v bat >/dev/null && alias cat='bat'

# 安全操作
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias rm='trash-put'
alias rrm='command rm'

