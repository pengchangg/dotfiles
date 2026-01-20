# ~/.bashrc
# ==================================================
# Interactive Bash ONLY
# ==================================================
unset __BASHRC_LOADED__

# 非交互 shell 立即退出（防止卡死），但tmux环境下允许加载
if [[ $- != *i* ]] && [ -z "${TMUX:-}" ]; then
    return
fi

# 重新加载bashrc的函数（必须在检查之前定义，以便可以调用）
function reloadBash {
    export __FORCE_RELOAD_BASHRC__=1
    unset __BASHRC_LOADED__
    source ~/.bashrc
}

# 防止递归加载
# 如果已经加载过且不是通过 reloadBash 强制重新加载，则跳过
if [ -n "${__BASHRC_LOADED__}" ] && [ -z "${__FORCE_RELOAD_BASHRC__}" ]; then
    return
fi
unset __FORCE_RELOAD_BASHRC__
export __BASHRC_LOADED__=1

# 发行版兼容：Debian / Ubuntu
if [[ -f /etc/bash.bashrc ]]; then
    source /etc/bash.bashrc
fi

# 模块化加载
if [ -d "$HOME/.bashrc.d" ]; then
    # 按文件名排序加载，确保顺序一致
    for f in "$HOME/.bashrc.d/"*.sh; do
        # 检查文件是否存在（通配符可能没有匹配到文件）
        [ -e "$f" ] || continue
        if [ -r "$f" ]; then
            # 使用 source 加载，如果出错会继续加载其他文件
            source "$f" 2>/dev/null || :
        fi
    done
else
    # 如果目录不存在，尝试使用符号链接的实际路径
    if [ -L "$HOME/.bashrc.d" ]; then
        real_path=$(readlink -f "$HOME/.bashrc.d" 2>/dev/null)
        if [ -d "$real_path" ]; then
            for f in "$real_path"/*.sh; do
                [ -e "$f" ] || continue
                if [ -r "$f" ]; then
                    source "$f" 2>/dev/null || :
                fi
            done
        fi
    fi
fi

# 私有配置（不进 Git）
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi



