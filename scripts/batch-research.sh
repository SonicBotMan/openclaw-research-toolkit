#!/bin/bash
# 批量研究脚本 v1.0
# 从文件读取多个主题，批量执行研究

TOPICS_FILE="$1"
LEVEL="${2:-1}"

[ ! -f "$TOPICS_FILE" ] && echo "用法: batch-research.sh <主题文件> [level]" && exit 1

OUTPUT_DIR="$HOME/.openclaw/workspace/reports/batch-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

TOTAL=$(wc -l < "$TOPICS_FILE")
CURRENT=0

echo "📊 批量研究任务"
echo "主题数: $TOTAL"
echo "级别: L$LEVEL"
echo "输出: $OUTPUT_DIR"
echo ""

while IFS= read -r topic; do
    [ -z "$topic" ] && continue
    [ "${topic:0:1}" = "#" ] && continue  # 跳过注释
    
    ((CURRENT++))
    echo "[$CURRENT/$TOTAL] 研究: $topic"
    
    bash ~/.openclaw/workspace/skills/research-workflow/report-generator.sh "$topic" markdown "$LEVEL" 2>/dev/null
    
    # 移动报告到批量输出目录
    mv ~/.openclaw/workspace/reports/report-*-*.md "$OUTPUT_DIR/" 2>/dev/null
    
    echo ""
done < "$TOPICS_FILE"

echo "✅ 批量研究完成！"
echo "📁 报告目录: $OUTPUT_DIR"
echo "📊 总计: $CURRENT 个主题"
