#!/bin/bash

# Dotfiles 依赖软件包安装脚本
# 自动检测操作系统并安装所需的软件包

set -euo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

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

# 必需软件包列表
REQUIRED_PACKAGES=(
    "stow"
    "git"
    "bash-completion"
    "neovim"
    "tmux"
    "bat"
    "fzf"
    "fd"
)

# 可选软件包列表
OPTIONAL_PACKAGES=(
    "git-crypt"
    "gnupg"
    "go"
)

# 检测操作系统
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="${ID:-unknown}"
        OS_VERSION_ID="${VERSION_ID:-}"
    elif [[ "$(uname)" == "Darwin" ]]; then
        OS_ID="macos"
    else
        OS_ID="unknown"
    fi
    
    log_info "检测到操作系统: ${OS_ID}"
}

# 检测包管理器
detect_package_manager() {
    if command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        PKG_INSTALL="apt install -y"
        PKG_UPDATE="apt update"
    elif command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        PKG_INSTALL="apt-get install -y"
        PKG_UPDATE="apt-get update"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="dnf install -y"
        PKG_UPDATE="dnf check-update || true"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_INSTALL="yum install -y"
        PKG_UPDATE="yum check-update || true"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="pacman -S --noconfirm"
        PKG_UPDATE="pacman -Sy"
    elif command -v brew &> /dev/null; then
        PKG_MANAGER="brew"
        PKG_INSTALL="brew install"
        PKG_UPDATE="brew update"
    else
        log_error "未找到支持的包管理器"
        exit 1
    fi
    
    log_info "检测到包管理器: ${PKG_MANAGER}"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 包名映射（处理不同发行版的包名差异）
declare -A PACKAGE_MAPPINGS
PACKAGE_MAPPINGS["debian.fd"]="fd-find"
PACKAGE_MAPPINGS["ubuntu.fd"]="fd-find"
PACKAGE_MAPPINGS["almalinux.fd"]="fd-find"
PACKAGE_MAPPINGS["rhel.fd"]="fd-find"
PACKAGE_MAPPINGS["centos.fd"]="fd-find"
PACKAGE_MAPPINGS["fedora.fd"]="fd-find"

# 获取包名
get_package_name() {
    local pkg="$1"
    local mapping_key="${OS_ID}.${pkg}"

    # 检查是否有特定的包名映射
    if [[ -n "${PACKAGE_MAPPINGS[$mapping_key]+_}" ]]; then
        echo "${PACKAGE_MAPPINGS[$mapping_key]}"
    else
        echo "$pkg"
    fi
}

# 安装单个包
install_package() {
    local pkg="$1"
    local cmd_name="$2"

    # 检查命令是否已存在
    if command_exists "$cmd_name"; then
        log_warn "$cmd_name 已安装，跳过"
        return 0
    fi

    local pkg_name=$(get_package_name "$pkg")

    if [ "$DRY_RUN" = "true" ]; then
        log_info "将安装: $pkg_name"
        return 0
    fi

    log_info "正在安装: $pkg_name"

    case "$PKG_MANAGER" in
        apt|apt-get)
            if ! sudo $PKG_INSTALL "$pkg_name"; then
                log_error "安装 $pkg_name 失败"
                return 1
            fi
            ;;
        dnf|yum)
            if ! sudo $PKG_INSTALL "$pkg_name"; then
                log_error "安装 $pkg_name 失败"
                return 1
            fi
            ;;
        pacman)
            if ! sudo $PKG_INSTALL "$pkg_name"; then
                log_error "安装 $pkg_name 失败"
                return 1
            fi
            ;;
        brew)
            if ! $PKG_INSTALL "$pkg_name"; then
                log_error "安装 $pkg_name 失败"
                return 1
            fi
            ;;
    esac

    log_success "$pkg_name 安装成功"
}

# 通用安装函数
install_packages() {
    local os_type="$1"

    case "$os_type" in
        debian|ubuntu|rhel|centos|fedora|almalinux|arch|manjaro)
            log_info "使用 $PKG_MANAGER 安装软件包"

            # 更新包列表
            log_info "更新包列表..."
            if [ "$DRY_RUN" = "false" ]; then
                if [[ "$os_type" == "macos" ]]; then
                    $PKG_UPDATE
                else
                    sudo $PKG_UPDATE || true
                fi
            else
                log_info "将更新包列表"
            fi
            ;;
        macos)
            log_info "使用 Homebrew 安装软件包"

            # 检查 Homebrew 是否安装
            if ! command_exists brew; then
                log_error "未找到 Homebrew，请先安装: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi

            log_info "更新包列表..."
            $PKG_UPDATE
            ;;
    esac

    # 安装必需包
    local total_packages=${#REQUIRED_PACKAGES[@]}
    local installed_count=0
    local skipped_count=0

    log_info "正在安装必需软件包 ($total_packages 个)..."

    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        local cmd_name="$pkg"

        case "$pkg" in
            bash-completion)
                cmd_name="bash_completion"
                ;;
            fd)
                cmd_name="fd"
                ;;
        esac

        if install_package "$pkg" "$cmd_name"; then
            installed_count=$((installed_count + 1))
        else
            skipped_count=$((skipped_count + 1))
        fi
    done

    # 安装可选包
    if [[ "$INSTALL_OPTIONAL" == "true" ]]; then
        local optional_total=${#OPTIONAL_PACKAGES[@]}
        local optional_installed=0
        local optional_skipped=0

        log_info "正在安装可选软件包 ($optional_total 个)..."

        for pkg in "${OPTIONAL_PACKAGES[@]}"; do
            if [[ "$pkg" == "rust" ]]; then
                if ! command_exists rustc; then
                    log_info "Rust 建议通过 rustup 安装: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
                fi
                optional_skipped=$((optional_skipped + 1))
            else
                if install_package "$pkg" "$pkg"; then
                    optional_installed=$((optional_installed + 1))
                else
                    optional_skipped=$((optional_skipped + 1))
                fi
            fi
        done

        log_info "可选包安装完成: 已安装 $optional_installed 个，已跳过 $optional_skipped 个"
    fi

    log_info "必需包安装完成: 已安装 $installed_count 个，已跳过 $skipped_count 个"
}

# 主函数
main() {
    INSTALL_OPTIONAL="false"
    DRY_RUN="false"

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --optional)
                INSTALL_OPTIONAL="true"
                shift
                ;;
            --dry-run|-n)
                DRY_RUN="true"
                shift
                ;;
            -h|--help)
                echo "用法: $0 [选项]"
                echo ""
                echo "选项:"
                echo "  --optional    安装可选软件包（git-crypt, gnupg, go, rust）"
                echo "  --dry-run, -n 模拟执行，显示将要执行的操作但不实际安装"
                echo "  -h, --help    显示此帮助信息"
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                echo "使用 -h 或 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done
    
    log_info "开始安装 dotfiles 依赖软件包..."
    
    # 检测操作系统
    detect_os
    
    # 检测包管理器
    detect_package_manager
    
    # 根据操作系统调用相应的安装函数
    case "$OS_ID" in
        debian|ubuntu|almalinux|rhel|centos|fedora|arch|manjaro|macos)
            install_packages "$OS_ID"
            ;;
        *)
            log_error "不支持的操作系统: $OS_ID"
            exit 1
            ;;
    esac
    
    log_success "安装完成！"
    
    # 显示安装摘要
    echo ""
    log_info "安装摘要:"
    echo "  操作系统: $OS_ID"
    echo "  包管理器: $PKG_MANAGER"
    if [[ "$INSTALL_OPTIONAL" == "true" ]]; then
        echo "  已安装: 必需包 + 可选包"
    else
        echo "  已安装: 必需包"
        echo "  提示: 使用 --optional 参数可安装可选包"
    fi
}

# 执行主函数
main "$@"
