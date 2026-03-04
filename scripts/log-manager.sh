#!/bin/bash
# 日志管理脚本 - 日志分级、轮转、错误追踪

LOG_DIR="$HOME/.openclaw/workspace/logs"
ARCHIVE_DIR="$LOG_DIR/archive"
RETENTION_DAYS=7

mkdir -p "$LOG_DIR" "$ARCHIVE_DIR"

echo "=== 日志管理 ==="

# 1. 日志轮转（保留最近 7 天）
echo "📦 日志轮转..."
find "$LOG_DIR" -name "*.log" -mtime +$RETENTION_DAYS -exec mv {} "$ARCHIVE_DIR/" \; 2>/dev/null
archived=$(ls "$ARCHIVE_DIR"/*.log 2>/dev/null | wc -l)
echo "   - 已归档: $archived 个日志文件"

# 2. 压缩旧日志
echo "🗜️ 压缩旧日志..."
gzip "$ARCHIVE_DIR"/*.log 2>/dev/null
compressed=$(ls "$ARCHIVE_DIR"/*.gz 2>/dev/null | wc -l)
echo "   - 已压缩: $compressed 个文件"

# 3. 错误统计
echo ""
echo "📊 错误统计（最近 24h）:"

ERROR_LOG="$LOG_DIR/search-fallback.log"
if [ -f "$ERROR_LOG" ]; then
    errors=$(grep "失败\|错误\|ERROR" "$ERROR_LOG" | grep "$(date '+%Y-%m-%d')" | wc -l)
    echo "   - 搜索失败: $errors 次"
    
    # 显示最近 5 个错误
    if [ $errors -gt 0 ]; then
        echo ""
        echo "   最近错误:"
        grep "失败\|错误" "$ERROR_LOG" | tail -5 | while read line; do
            echo "   - $line"
        done
    fi
fi

# 4. 日志大小
echo ""
echo "📁 日志大小:"
du -sh "$LOG_DIR" 2>/dev/null | awk '{print "   - 总大小: " $1}'

echo ""
echo "✅ 日志管理完成"
