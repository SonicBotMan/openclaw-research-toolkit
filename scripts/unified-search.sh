#!/bin/bash
# 统一搜索入口 - 整合本地 + 在线搜索

QUERY="$1"
MODE="${2:-auto}"  # local | online | auto

[ -z "$QUERY" ] && echo "用法: unified-search.sh <查询> [local|online|auto]" && exit 1

echo "🔍 统一搜索: $QUERY"
echo "模式: $MODE"
echo ""

# 本地搜索（QMD）
search_local() {
    echo "📁 本地搜索（QMD）..."
    qmd search "$QUERY" -c memory -n 3 2>/dev/null && return 0
    return 1
}

# 在线搜索
search_online() {
    echo "🌐 在线搜索..."
    bash ~/.openclaw/workspace/skills/search-fallback/search.sh "$QUERY"
}

# 自动模式
if [ "$MODE" = "auto" ]; then
    # 先尝试本地
    if search_local; then
        echo ""
        echo "💡 本地找到结果，还需要在线搜索吗？"
    fi
    
    echo ""
    search_online
elif [ "$MODE" = "local" ]; then
    search_local
else
    search_online
fi
