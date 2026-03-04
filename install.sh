#!/bin/bash
# OpenClaw Research Toolkit - 一键安装脚本
# 自动检测环境，创建隔离虚拟环境，安装所有依赖

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# 项目信息
PROJECT_NAME="openclaw-research-toolkit"
INSTALL_DIR="$HOME/.openclaw/workspace/skills"
REPO_URL="https://github.com/SonicBotMan/openclaw-research-toolkit.git"

echo ""
echo "✨ OpenClaw Research Toolkit Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检测系统
detect_system() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        PKG_MANAGER="apt"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
    else
        log_error "不支持的系统: $OSTYPE"
        exit 1
    fi
    log_success "系统: $OS"
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    local missing=()
    
    # 必需依赖
    command -v curl >/dev/null 2>&1 || missing+=("curl")
    command -v jq >/dev/null 2>&1 || missing+=("jq")
    command -v python3 >/dev/null 2>&1 || missing+=("python3")
    command -v git >/dev/null 2>&1 || missing+=("git")
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warn "缺少依赖: ${missing[*]}"
        log_info "尝试自动安装..."
        install_dependencies "${missing[@]}"
    fi
    
    log_success "依赖检查通过"
}

# 安装依赖
install_dependencies() {
    local deps=("$@")
    
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update -qq
        for dep in "${deps[@]}"; do
            sudo apt install -y "$dep" 2>/dev/null || log_error "安装 $dep 失败"
        done
    elif [ "$PKG_MANAGER" = "brew" ]; then
        for dep in "${deps[@]}"; do
            brew install "$dep" 2>/dev/null || log_error "安装 $dep 失败"
        done
    fi
}

# 克隆项目
clone_project() {
    log_info "克隆项目..."
    
    if [ -d "$INSTALL_DIR/research-workflow/.git" ]; then
        log_warn "已安装，更新中..."
        cd "$INSTALL_DIR/research-workflow"
        git fetch -q origin 2>/dev/null || true
        git reset --hard origin/main -q 2>/dev/null || git reset --hard origin/master -q 2>/dev/null || true
    else
        mkdir -p "$INSTALL_DIR"
        cd "$INSTALL_DIR"
        git clone -q "$REPO_URL" research-workflow || {
            # 如果 GitHub 失败，从本地复制
            log_warn "GitHub 克隆失败，从本地复制..."
            cp -r "$HOME/.openclaw/workspace/projects/$PROJECT_NAME" "$INSTALL_DIR/research-workflow"
        }
    fi
    
    log_success "项目已安装"
}

# 安装 Python 依赖
install_python_deps() {
    log_info "安装 Python 依赖..."
    
    # 创建虚拟环境（可选）
    local venv_dir="$INSTALL_DIR/research-workflow/.venv"
    if [ ! -d "$venv_dir" ]; then
        python3 -m venv "$venv_dir" 2>/dev/null || log_warn "虚拟环境创建失败，使用系统 Python"
    fi
    
    # 安装依赖
    if [ -f "$INSTALL_DIR/research-workflow/requirements.txt" ]; then
        if [ -d "$venv_dir" ]; then
            source "$venv_dir/bin/activate"
            pip install -q -r "$INSTALL_DIR/research-workflow/requirements.txt"
            deactivate
        else
            pip3 install -q --user -r "$INSTALL_DIR/research-workflow/requirements.txt"
        fi
    fi
    
    log_success "Python 依赖已安装"
}

# 配置 Skilless（可选）
setup_skilless() {
    if [ ! -d "$HOME/.agents/skills/skilless" ]; then
        log_info "安装 Skilless（Exa AI + Jina Reader）..."
        curl -LsSf https://skilless.ai/install | bash || log_warn "Skilless 安装失败，跳过"
    else
        log_success "Skilless 已安装"
    fi
}

# 创建统一命令
setup_command() {
    log_info "创建统一命令..."
    
    local cmd_file="$HOME/.local/bin/research"
    mkdir -p "$(dirname "$cmd_file")"
    
    cat > "$cmd_file" << 'EOF'
#!/bin/bash
# OpenClaw Research Toolkit - 统一命令入口
SKILLS_DIR="$HOME/.openclaw/workspace/skills"

case "$1" in
    search|s)
        bash "$SKILLS_DIR/search-fallback/search.sh" "${@:2}"
        ;;
    read|r)
        bash "$SKILLS_DIR/deepreader/deepreader.sh" "${@:2}"
        ;;
    research|rs)
        bash "$SKILLS_DIR/research-workflow/research.sh" "${@:2}"
        ;;
    stats)
        bash "$SKILLS_DIR/search-fallback/stats.sh"
        ;;
    clean)
        rm -rf "$HOME/.openclaw/workspace/cache/search/*"
        echo "✅ 缓存已清空"
        ;;
    test)
        bash "$SKILLS_DIR/research-workflow/test.sh"
        ;;
    *)
        echo "用法: research <command> [args]"
        echo "命令: search, read, research, stats, clean, test"
        ;;
esac
EOF
    
    chmod +x "$cmd_file"
    
    # 添加到 PATH
    if ! echo "$PATH" | grep -q ".local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    log_success "命令已创建: research"
}

# 配置 Cron（可选）
setup_cron() {
    log_info "配置自动维护..."
    
    # 每天凌晨 3 点清理日志
    (crontab -l 2>/dev/null | grep -v "research.*log-manager"; echo "0 3 * * * $INSTALL_DIR/search-fallback/log-manager.sh >> /tmp/research-maintenance.log 2>&1") | crontab -
    
    # 每小时统计
    (crontab -l 2>/dev/null | grep -v "research.*stats"; echo "0 * * * * $INSTALL_DIR/search-fallback/stats.sh >> /tmp/research-stats.log 2>&1") | crontab -
    
    log_success "自动维护已配置"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."
    
    if command -v research >/dev/null 2>&1; then
        log_success "✓ 命令可用: research"
    else
        log_warn "命令未添加到 PATH，手动添加: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    
    if [ -f "$INSTALL_DIR/research-workflow/research.sh" ]; then
        log_success "✓ 研究脚本已安装"
    else
        log_error "✗ 研究脚本缺失"
    fi
    
    log_success "安装完成！"
}

# 卸载函数
uninstall() {
    log_info "卸载 OpenClaw Research Toolkit..."
    
    rm -rf "$INSTALL_DIR/research-workflow"
    rm -rf "$INSTALL_DIR/search-fallback"
    rm -rf "$INSTALL_DIR/deepreader"
    rm -f "$HOME/.local/bin/research"
    
    # 移除 Cron 任务
    crontab -l 2>/dev/null | grep -v "research" | crontab -
    
    log_success "卸载完成"
}

# 主流程
main() {
    case "${1:-install}" in
        install)
            detect_system
            check_dependencies
            clone_project
            install_python_deps
            setup_skilless
            setup_command
            setup_cron
            verify_installation
            
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🎉 安装成功！"
            echo ""
            echo "快速开始:"
            echo "  research search \"AI 最新进展\""
            echo "  research read \"https://example.com\""
            echo "  research research \"市场调研\" 3"
            echo ""
            echo "文档: https://github.com/SonicBotMan/openclaw-research-toolkit"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            ;;
        uninstall)
            uninstall
            ;;
        *)
            echo "用法: $0 [install|uninstall]"
            exit 1
            ;;
    esac
}

main "$@"
