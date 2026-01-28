#!/usr/bin/env bash
# =========================================================
# Dotfiles 管理脚本
# 功能：恢复和重置 dotfiles 配置
# 使用：./manage.sh [restore|reset|backup|status]
# =========================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置包列表
PACKAGES=("bash" "nvim" "tmux" "git-workflow" "bat")

# 全局 dry-run 标志
DRY_RUN="false"

# 脚本所在目录（dotfiles 根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/.backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_dry_run() {
    echo -e "${YELLOW}[DRY-RUN]${NC} $1"
}

log_debug() {
    if [ "${DEBUG:-false}" = true ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# 错误处理函数
handle_error() {
    local exit_code=$1
    local error_message=$2

    log_error "错误: $error_message"
    log_error "退出码: $exit_code"

    if [ "$DRY_RUN" = "false" ]; then
        log_warn "操作已终止，请检查错误信息"
    fi

    exit $exit_code
}

# 检查命令是否成功执行
check_command() {
    local command_name=$1
    local exit_code=$2

    if [ $exit_code -ne 0 ]; then
        handle_error $exit_code "命令执行失败: $command_name"
    fi
}

# 检查 stow 是否安装
check_stow() {
    if ! command -v stow &> /dev/null; then
        log_error "GNU Stow 未安装"
        echo "请先安装 stow:"
        echo "  Arch: sudo pacman -S stow"
        echo "  Debian/Ubuntu: sudo apt install stow"
        echo "  macOS: brew install stow"
        exit 1
    fi
}

# 检查 git-crypt 是否安装
check_git_crypt() {
    if ! command -v git-crypt &> /dev/null; then
        log_error "git-crypt 未安装"
        echo "请先安装 git-crypt:"
        echo "  Arch: sudo pacman -S git-crypt"
        echo "  Debian/Ubuntu: sudo apt install git-crypt"
        echo "  macOS: brew install git-crypt"
        exit 1
    fi
}

# 检查 private 目录是否存在
check_private_dir() {
    if [ ! -d "${SCRIPT_DIR}/private" ]; then
        log_warn "private/ 目录不存在"
        return 1
    fi
    return 0
}

# 检查是否需要解锁
need_unlock() {
    local private_dir="${SCRIPT_DIR}/private"
    
    # 如果 private 目录不存在，不需要解锁
    if [ ! -d "$private_dir" ]; then
        return 1
    fi
    
    # 检查是否有文件
    local file_count=$(find "$private_dir" -type f 2>/dev/null | wc -l)
    if [ "$file_count" -eq 0 ]; then
        return 1  # 目录为空，不需要解锁
    fi
    
    # 检查是否有加密文件（需要在 git 仓库根目录执行）
    (
        cd "$SCRIPT_DIR" || return 1
        local encrypted_count=0
        
        # 查找 private 目录下的所有文件并检查加密状态
        while IFS= read -r -d '' file; do
            # 获取相对于仓库根目录的路径
            local rel_path="${file#${SCRIPT_DIR}/}"
            if git-crypt status -e "$rel_path" 2>/dev/null | grep -q "encrypted"; then
                encrypted_count=$((encrypted_count + 1))
            fi
        done < <(find "$private_dir" -type f -print0 2>/dev/null || true)
        
        # 如果有加密文件，需要解锁
        [ "$encrypted_count" -gt 0 ]
    )
}

# 解锁 private 目录（解密）
unlock_private() {
    check_git_crypt

    if ! check_private_dir; then
        log_warn "private/ 目录不存在，无法执行解锁操作"
        return 1
    fi

    cd "$SCRIPT_DIR"

    # 自动判断是否需要解锁
    if need_unlock; then
        log_info "检测到加密文件，正在解锁 private/ 目录..."

        # 尝试解锁
        if git-crypt unlock 2>/dev/null; then
            # 解锁后验证状态
            local unlocked_count=0
            local total_files=0

            while IFS= read -r -d '' file; do
                total_files=$((total_files + 1))
                if ! git-crypt status -e "$file" 2>/dev/null | grep -q "encrypted"; then
                    unlocked_count=$((unlocked_count + 1))
                fi
            done < <(find private -type f -print0 2>/dev/null || true)

            log_success "private/ 目录解锁成功！"
            log_info "已解锁 $unlocked_count 个文件（共 $total_files 个文件）"
        else
            log_error "解锁 private/ 目录失败！"
            log_info "可能的原因："
            log_info "  - GPG 密钥未导入"
            log_info "  - 密钥不匹配"
            log_info "  - 文件权限问题"
            log_info "解决方法："
            log_info "  - 导入 GPG 密钥：gpg --import <key-file>"
            log_info "  - 检查密钥环：gpg --list-secret-keys"
            return 1
        fi
    else
        local file_count=$(find private -type f 2>/dev/null | wc -l)
        if [ "$file_count" -eq 0 ]; then
            log_info "private/ 目录为空，无需解锁"
        else
            log_info "private/ 目录已处于解锁状态"
        fi
    fi
}

# 锁定 private 目录（加密）
lock_private() {
    log_info "锁定 private/ 目录..."

    check_git_crypt

    if ! check_private_dir; then
        log_warn "private/ 目录不存在，无法执行锁定操作"
        return 1
    fi

    cd "$SCRIPT_DIR"

    # 检查是否有文件需要锁定
    local file_count=$(find private -type f 2>/dev/null | wc -l)
    if [ "$file_count" -eq 0 ]; then
        log_info "private/ 目录为空，无需锁定"
        return 0
    fi

    # 尝试锁定
    if git-crypt lock 2>/dev/null; then
        # 锁定后验证状态
        local encrypted_count=0

        while IFS= read -r -d '' file; do
            if git-crypt status -e "$file" 2>/dev/null | grep -q "encrypted"; then
                encrypted_count=$((encrypted_count + 1))
            fi
        done < <(find private -type f -print0 2>/dev/null || true)

        log_success "private/ 目录锁定成功！"
        log_info "已加密 $encrypted_count 个文件（共 $file_count 个文件）"
    else
        log_error "锁定 private/ 目录失败！"
        return 1
    fi
}

# 检查 git-crypt 状态
check_crypt_status() {
    log_info "检查 git-crypt 状态..."
    echo ""
    
    check_git_crypt
    
    cd "$SCRIPT_DIR"
    
    if ! check_private_dir; then
        log_warn "private/ 目录不存在"
        return 0
    fi
    
    # 检查加密状态
    echo -e "${BLUE}git-crypt 状态:${NC}"
    
    # 检查 private 目录下的文件加密状态
    local encrypted_count=0
    local not_encrypted_count=0
    local total_files=0
    
    if [ -d "private" ]; then
        # 统计文件数量
        while IFS= read -r -d '' file; do
            total_files=$((total_files + 1))
            if git-crypt status -e "$file" 2>/dev/null | grep -q "encrypted"; then
                encrypted_count=$((encrypted_count + 1))
            else
                not_encrypted_count=$((not_encrypted_count + 1))
            fi
        done < <(find private -type f -print0 2>/dev/null || true)
        
        echo "  private/ 目录文件统计:"
        if [ "$total_files" -eq 0 ]; then
            echo "    目录为空（无文件）"
        else
            echo "    总文件数: $total_files"
            echo "    已加密: $encrypted_count"
            echo "    未加密: $not_encrypted_count"
        fi
    fi
    
    # 显示 git-crypt 整体状态
    echo ""
    echo -e "${BLUE}git-crypt 配置:${NC}"
    if [ -f ".gitattributes" ]; then
        if grep -q "private/\*\*" .gitattributes; then
            echo "  ✓ private/** 已配置加密"
        else
            echo "  ✗ private/** 未配置加密"
        fi
    else
        echo "  ✗ .gitattributes 文件不存在"
    fi
    
    echo ""
}

# 检查文件是否为符号链接
is_symlink() {
    [ -L "$1" ]
}

# 检查文件是否存在
file_exists() {
    [ -e "$1" ]
}

# 备份现有配置
backup_config() {
    local package=$1
    local target_path=$2

    if ! file_exists "$target_path"; then
        return 0  # 文件不存在，无需备份
    fi

    if is_symlink "$target_path"; then
        log_info "$target_path 是符号链接，跳过备份"
        return 0
    fi

    local backup_path="${BACKUP_DIR}/${package}/${TIMESTAMP}"
    local filename=$(basename "$target_path")

    if [ "$DRY_RUN" = "true" ]; then
        if [ -d "$target_path" ]; then
            log_dry_run "将备份目录: $target_path -> $backup_path/"
        else
            log_dry_run "将备份文件: $target_path -> $backup_path/$filename"
        fi
        return 0
    fi

    mkdir -p "$backup_path"

    # 如果是目录，需要特殊处理
    if [ -d "$target_path" ]; then
        log_info "备份目录: $target_path -> $backup_path/"
        cp -r "$target_path" "$backup_path/"
    else
        log_info "备份文件: $target_path -> $backup_path/$filename"
        cp "$target_path" "$backup_path/$filename"
    fi

    log_success "已备份到: $backup_path"

    # 清理旧备份
    cleanup_old_backups "$package"
}

# 备份轮换配置
MAX_BACKUPS=7

# 清理旧备份
cleanup_old_backups() {
    local package=$1
    local package_backup_dir="${BACKUP_DIR}/${package}"

    if [ ! -d "$package_backup_dir" ]; then
        return
    fi

    # 使用 find 安全获取所有备份目录并排序（处理特殊字符）
    local backup_dirs=()
    while IFS= read -r -d '' dir; do
        backup_dirs+=("$(basename "$dir")")
    done < <(find "$package_backup_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z -r)

    if [ ${#backup_dirs[@]} -gt $MAX_BACKUPS ]; then
        local backups_to_remove=("${backup_dirs[@]:$MAX_BACKUPS}")

        for backup in "${backups_to_remove[@]}"; do
            local backup_path="${package_backup_dir}/${backup}"

            if [ "$DRY_RUN" = "true" ]; then
                log_dry_run "将删除旧备份: $backup_path"
            else
                log_info "删除旧备份: $backup_path"
                rm -rf "$backup_path"
            fi
        done
    fi
}

# 备份所有可能冲突的配置
backup_all() {
    log_info "开始备份现有配置..."

    if [ "$DRY_RUN" = "true" ]; then
        log_dry_run "将创建备份目录: $BACKUP_DIR"
    else
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Bash 配置
    [ -f "$HOME/.bashrc" ] && backup_config "bash" "$HOME/.bashrc"
    [ -f "$HOME/.profile" ] && backup_config "bash" "$HOME/.profile"
    [ -d "$HOME/.bashrc.d" ] && backup_config "bash" "$HOME/.bashrc.d"
    
    # Neovim 配置
    [ -f "$HOME/.config/nvim/init.lua" ] && backup_config "nvim" "$HOME/.config/nvim/init.lua"
    [ -d "$HOME/.config/nvim" ] && backup_config "nvim" "$HOME/.config/nvim"
    
    # Tmux 配置
    [ -f "$HOME/.tmux.conf" ] && backup_config "tmux" "$HOME/.tmux.conf"
    
    # Git 配置
    [ -f "$HOME/.gitconfig" ] && backup_config "git-workflow" "$HOME/.gitconfig"
    [ -f "$HOME/.git-workflow.sh" ] && backup_config "git-workflow" "$HOME/.git-workflow.sh"
    
    # Bat 配置
    [ -f "$HOME/.config/bat/config" ] && backup_config "bat" "$HOME/.config/bat/config"
    [ -d "$HOME/.config/bat" ] && backup_config "bat" "$HOME/.config/bat"
    
    log_success "备份完成！备份位置: $BACKUP_DIR"
}

# 恢复配置（安装）
restore_config() {
    log_info "开始恢复 dotfiles 配置..."
    
    check_stow
    
    # 先备份现有配置
    backup_all
    
    # 切换到 dotfiles 目录
    cd "$SCRIPT_DIR"
    
    # 自动解锁 private 目录（如果需要）
    if [ "$DRY_RUN" = "true" ]; then
        log_dry_run "将尝试解锁 private/ 目录"
        unlock_private || true  # dry-run 模式下忽略失败
    else
        if ! unlock_private; then
            log_warn "解锁 private/ 目录失败"
            echo ""
            read -p "是否继续安装配置？[y/N]: " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "操作已取消"
                exit 0
            fi
        fi
    fi
    
    # 安装所有配置包
    local failed_packages=()
    for package in "${PACKAGES[@]}"; do
        if [ ! -d "$package" ]; then
            log_warn "配置包 $package 不存在，跳过"
            continue
        fi
        
        log_info "安装配置包: $package"
        
        if [ "$DRY_RUN" = "true" ]; then
            log_dry_run "将安装配置包: $package"
            stow -n "$package" 2>&1 | grep -E "(LINK:|WARNING:)" || true
        else
            if stow -v "$package" 2>&1 | grep -q "WARNING"; then
                log_warn "$package 安装时出现警告，但继续执行"
            fi
            
            if stow "$package"; then
                log_success "$package 安装成功"
            else
                log_error "$package 安装失败"
                failed_packages+=("$package")
            fi
        fi
    done
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "dry-run 模式：以上操作仅显示，未实际执行"
        return 0
    fi
    
    if [ ${#failed_packages[@]} -eq 0 ]; then
        log_success "所有配置恢复成功！"
        source ~/.bashrc
        tmux source-file ~/.tmux.conf
        echo ""
        echo "提示："
        echo "  - 已重新加载 shell: source ~/.bashrc"
        echo "  - 已重新加载 tmux: tmux source-file ~/.tmux.conf"
    else
        log_error "以下配置包安装失败: ${failed_packages[*]}"
        exit 1
    fi
}

# 重置配置（卸载）
reset_config() {
    log_info "开始重置 dotfiles 配置..."
    
    check_stow
    
    # 确认操作（dry-run 模式下跳过）
    if [ "$DRY_RUN" != "true" ]; then
        echo ""
        log_warn "这将删除所有 dotfiles 的符号链接"
        read -p "确定要继续吗？[y/N]: " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "操作已取消"
            exit 0
        fi
    fi
    
    # 切换到 dotfiles 目录
    cd "$SCRIPT_DIR"
    
    # 卸载所有配置包
    local failed_packages=()
    for package in "${PACKAGES[@]}"; do
        if [ ! -d "$package" ]; then
            log_warn "配置包 $package 不存在，跳过"
            continue
        fi
        
        log_info "卸载配置包: $package"
        
        if [ "$DRY_RUN" = "true" ]; then
            log_dry_run "将卸载配置包: $package"
            stow -D -n "$package" 2>&1 | grep -E "(UNLINK:|WARNING:)" || true
        else
            if stow -D -v "$package"; then
                log_success "$package 卸载成功"
            else
                log_error "$package 卸载失败"
                failed_packages+=("$package")
            fi
        fi
    done
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "dry-run 模式：以上操作仅显示，未实际执行"
        return 0
    fi
    
    if [ ${#failed_packages[@]} -eq 0 ]; then
        log_success "所有配置重置成功！"
    else
        log_error "以下配置包卸载失败: ${failed_packages[*]}"
        exit 1
    fi
}

# 检查配置状态
check_status() {
    log_info "检查 dotfiles 配置状态..."
    echo ""
    
    cd "$SCRIPT_DIR"
    
    for package in "${PACKAGES[@]}"; do
        if [ ! -d "$package" ]; then
            continue
        fi
        
        echo -e "${BLUE}配置包: $package${NC}"
        
        # 检查 stow 管理的文件
        local stowed_files=$(stow -n "$package" 2>&1 | grep "LINK:" | awk '{print $2}' || true)
        
        if [ -z "$stowed_files" ]; then
            # 尝试检查实际文件
            case $package in
                bash)
                    [ -L "$HOME/.bashrc" ] && echo "  ✓ .bashrc (符号链接)"
                    [ -L "$HOME/.profile" ] && echo "  ✓ .profile (符号链接)"
                    [ -L "$HOME/.bashrc.d" ] && echo "  ✓ .bashrc.d (符号链接)"
                    ;;
                nvim)
                    [ -L "$HOME/.config/nvim/init.lua" ] && echo "  ✓ .config/nvim/init.lua (符号链接)"
                    ;;
                tmux)
                    [ -L "$HOME/.tmux.conf" ] && echo "  ✓ .tmux.conf (符号链接)"
                    ;;
                git-workflow)
                    [ -L "$HOME/.gitconfig" ] && echo "  ✓ .gitconfig (符号链接)"
                    [ -L "$HOME/.git-workflow.sh" ] && echo "  ✓ .git-workflow.sh (符号链接)"
                    ;;
                bat)
                    [ -L "$HOME/.config/bat/config" ] && echo "  ✓ .config/bat/config (符号链接)"
                    ;;
            esac
        else
            echo "$stowed_files" | while read -r line; do
                local target=$(echo "$line" | sed 's|.* -> ||')
                if [ -L "$target" ]; then
                    echo "  ✓ $target (符号链接)"
                else
                    echo "  ✗ $target (未链接)"
                fi
            done
        fi
        
        echo ""
    done
    
    # 显示备份信息
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(find "$BACKUP_DIR" -mindepth 2 -type d | wc -l)
        if [ "$backup_count" -gt 0 ]; then
            echo -e "${BLUE}备份信息:${NC}"
            echo "  备份目录: $BACKUP_DIR"
            echo "  备份数量: $backup_count"
            echo ""
        fi
    fi
    
    # 显示 git-crypt 状态
    check_crypt_status
}

# 显示帮助信息
show_help() {
    cat << EOF
Dotfiles 管理脚本

用法:
    $0 [--dry-run|-n] [命令]

命令:
    restore      恢复/安装所有 dotfiles 配置（会自动解锁 private/）
    reset        重置/卸载所有 dotfiles 配置
    backup       备份现有配置（不安装）
    status       检查配置状态（包括 git-crypt 状态）
    unlock       解锁 private/ 目录（解密）
    lock         锁定 private/ 目录（加密）
    crypt-status 检查 git-crypt 加密状态
    help         显示此帮助信息

选项:
    --dry-run, -n  模拟执行，显示将要执行的操作但不实际执行

示例:
    $0 restore              # 安装所有配置并解锁 private/
    $0 --dry-run restore    # 模拟安装，显示将要执行的操作
    $0 restore --dry-run    # 同上（两种写法都支持）
    $0 reset                # 卸载所有配置
    $0 --dry-run reset      # 模拟卸载，显示将要删除的链接
    $0 status               # 查看配置状态
    $0 unlock                # 解锁 private/ 目录
    $0 lock                  # 锁定 private/ 目录
    $0 crypt-status         # 查看加密状态

EOF
}

# 主函数
main() {
    local command=${1:-help}
    
    case "$command" in
        restore)
            restore_config
            ;;
        reset)
            reset_config
            ;;
        backup)
            backup_all
            ;;
        status)
            check_status
            ;;
        unlock)
            unlock_private
            ;;
        lock)
            lock_private
            ;;
        crypt-status)
            check_crypt_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 解析命令行参数，提取 --dry-run 标志
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n)
            DRY_RUN="true"
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

# 执行主函数
main "${ARGS[@]}"
