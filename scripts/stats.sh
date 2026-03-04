#!/bin/bash
# 搜索统计脚本 - 分析搜索性能和缓存效果

STATS_DIR="$HOME/.openclaw/workspace/logs"
STATS_FILE="$STATS_DIR/search-stats.json"
CACHE_DIR="$HOME/.openclaw/workspace/cache/search"

mkdir -p "$STATS_DIR"

echo "=== 搜索统计报告 ==="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 1. 缓存统计
if [ -d "$CACHE_DIR" ]; then
    cache_count=$(ls "$CACHE_DIR"/*.json 2>/dev/null | wc -l)
    cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    echo "📁 缓存统计:"
    echo "   - 缓存文件数: $cache_count"
    echo "   - 缓存大小: $cache_size"
    echo ""
fi

# 2. 搜索日志分析
LOG_FILE="$STATS_DIR/search-fallback.log"
if [ -f "$LOG_FILE" ]; then
    today=$(date '+%Y-%m-%d')
    total_today=$(grep "开始搜索:" "$LOG_FILE" | grep "$today" | wc -l)
    cache_hits=$(grep "缓存命中" "$LOG_FILE" | grep "$today" | wc -l)
    searxng_success=$(grep "SearXNG 成功" "$LOG_FILE" | grep "$today" | wc -l)
    exa_success=$(grep "Exa.*成功" "$LOG_FILE" | grep "$today" | wc -l)
    
    if [ $total_today -gt 0 ]; then
        hit_rate=$(echo "scale=1; $cache_hits * 100 / $total_today" | bc)
    else
        hit_rate=0
    fi
    
    echo "📊 今日统计:"
    echo "   - 总搜索次数: $total_today"
    echo "   - 缓存命中: $cache_hits ($hit_rate%)"
    echo "   - SearXNG 成功: $searxng_success"
    echo "   - Exa AI 成功: $exa_success"
    echo ""
fi

# 3. 搜索引擎可用性
echo "🔍 搜索引擎状态:"
echo -n "   - SearXNG: "
curl -s --connect-timeout 3 "http://192.168.11.147:8515/healthz" 2>/dev/null && echo "✅" || echo "❌"

echo -n "   - Exa AI: "
if [ -d ~/.agents/skills/skilless ]; then
    echo "✅ 已安装"
else
    echo "❌ 未安装"
fi

echo ""
echo "=== 报告完成 ==="
