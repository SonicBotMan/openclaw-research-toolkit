#!/bin/bash
# 搜索系统健康检查 v1.0

LOG="$HOME/.openclaw/workspace/logs/search-health.log"
mkdir -p "$(dirname "$LOG")"

echo "🔍 搜索系统健康检查"
echo "===================="
echo ""

FAILED=0
TOTAL=0

# 检查函数
check_source() {
    local name="$1"
    local url="$2"
    local expected="$3"
    
    ((TOTAL++))
    echo -n "检查 $name... "
    
    result=$(curl -s --connect-timeout 5 --max-time 10 "$url" 2>/dev/null)
    
    if [ $? -eq 0 ] && echo "$result" | grep -q "$expected"; then
        echo "✅ 正常"
        return 0
    else
        echo "❌ 异常"
        ((FAILED++))
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $name 失败" >> "$LOG"
        return 1
    fi
}

# 检查各搜索源
check_source "SearXNG" "http://192.168.11.147:8515/search?q=test&format=json" "results"
check_source "Exa AI (skilless)" "file://$HOME/.agents/skills/skilless/VERSION" "skilless"

# 检查本地工具
echo -n "检查 yt-dlp... "
if command -v yt-dlp &>/dev/null; then
    echo "✅ $(yt-dlp --version)"
else
    echo "❌ 未安装"
    ((FAILED++))
fi

echo -n "检查 ffmpeg... "
if command -v ffmpeg &>/dev/null; then
    echo "✅ $(ffmpeg -version | head -1 | cut -d' ' -f3)"
else
    echo "❌ 未安装"
    ((FAILED++))
fi

echo ""
echo "===================="
echo "总计: $TOTAL 项检查"
echo "失败: $FAILED 项"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "⚠️ 有 $FAILED 项检查失败，建议检查日志: $LOG"
    exit 1
else
    echo "✅ 所有检查通过"
    exit 0
fi
