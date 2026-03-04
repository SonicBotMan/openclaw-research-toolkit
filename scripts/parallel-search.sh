#!/bin/bash
# 并行搜索 - 同时查询多个引擎
# 大幅提升搜索速度

QUERY="$1"
[ -z "$QUERY" ] && echo "用法: parallel-search.sh <查询>" && exit 1

ENCODED=$(echo "$QUERY" | jq -sRr @uri)
RESULTS_FILE="/tmp/parallel-search-$$.json"

echo "🚀 并行搜索: $QUERY"
echo ""

# 并行执行
(
    # SearXNG
    curl -s --connect-timeout 5 --max-time 10 \
        "http://192.168.11.147:8515/search?q=$ENCODED&format=json&language=zh-CN" \
        | jq -c '.results[:3][] | {engine: "searxng", title, url, content: (.content[:100])}' \
        >> "$RESULTS_FILE" 2>/dev/null
) &

(
    # Exa AI
    cd ~/.agents/skills/skilless && source .venv/bin/activate
    timeout 15 python scripts/search.py "$QUERY" 2>/dev/null | head -10 \
        | jq -Rc '{engine: "exa", title: .}' >> "$RESULTS_FILE" 2>/dev/null
) &

# 等待所有任务完成
wait

# 合并去重
if [ -f "$RESULTS_FILE" ] && [ -s "$RESULTS_FILE" ]; then
    count=$(wc -l < "$RESULTS_FILE")
    echo "✅ 找到 $count 条结果"
    echo ""
    
    # 去重并按相关性排序
    sort -u "$RESULTS_FILE" | head -10 | while read line; do
        title=$(echo "$line" | jq -r '.title')
        url=$(echo "$line" | jq -r '.url // "N/A"')
        engine=$(echo "$line" | jq -r '.engine')
        
        echo "【$engine】$title"
        [ "$url" != "null" ] && [ "$url" != "N/A" ] && echo "  $url"
        echo ""
    done
else
    echo "❌ 未找到结果"
fi

rm -f "$RESULTS_FILE"
