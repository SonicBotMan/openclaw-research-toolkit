#!/bin/bash
# 研究报告生成器 v1.0
# 支持：Markdown / HTML / JSON 输出

QUERY="$1"
FORMAT="${2:-markdown}"  # markdown | html | json
LEVEL="${3:-2}"          # 1 | 2 | 3

[ -z "$QUERY" ] && echo "用法: report-generator.sh <主题> [format] [level]" && exit 1

OUTPUT_DIR="$HOME/.openclaw/workspace/reports"
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SAFE_QUERY=$(echo "$QUERY" | tr ' ' '-' | tr -cd '[:alnum:]-')

echo "📊 生成研究报告: $QUERY"
echo "格式: $FORMAT | 级别: L$LEVEL"
echo ""

# 执行研究
RESULTS=$(bash ~/.openclaw/workspace/skills/research-workflow/research.sh "$QUERY" "$LEVEL" 2>/dev/null)

if [ -z "$RESULTS" ]; then
    echo "❌ 研究失败"
    exit 1
fi

# 生成报告
case "$FORMAT" in
    markdown)
        REPORT_FILE="$OUTPUT_DIR/report-$SAFE_QUERY-$TIMESTAMP.md"
        
        cat > "$REPORT_FILE" << EOF
# 研究报告: $QUERY

**生成时间:** $(date '+%Y-%m-%d %H:%M:%S')
**研究级别:** L$LEVEL
**工具:** research-workflow v3.0

---

## 研究结果

$RESULTS

---

*报告由小茹自动生成*
EOF
        echo "✅ Markdown 报告: $REPORT_FILE"
        ;;
        
    html)
        REPORT_FILE="$OUTPUT_DIR/report-$SAFE_QUERY-$TIMESTAMP.html"
        
        cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>研究报告: $QUERY</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .meta { color: #666; font-size: 14px; margin-bottom: 20px; }
        .result { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0; }
        a { color: #007bff; }
    </style>
</head>
<body>
    <h1>研究报告: $QUERY</h1>
    <div class="meta">
        生成时间: $(date '+%Y-%m-%d %H:%M:%S') | 研究级别: L$LEVEL
    </div>
    <div class="result">
        <pre>$RESULTS</pre>
    </div>
    <hr>
    <p><em>报告由小茹自动生成</em></p>
</body>
</html>
EOF
        echo "✅ HTML 报告: $REPORT_FILE"
        ;;
        
    json)
        REPORT_FILE="$OUTPUT_DIR/report-$SAFE_QUERY-$TIMESTAMP.json"
        
        cat > "$REPORT_FILE" << EOF
{
    "query": "$QUERY",
    "timestamp": "$(date -Iseconds)",
    "level": $LEVEL,
    "results": $(echo "$RESULTS" | jq -Rs .)
}
EOF
        echo "✅ JSON 报告: $REPORT_FILE"
        ;;
esac

# 显示报告路径
echo ""
echo "📁 报告已保存到: $OUTPUT_DIR"
