#!/bin/bash
# 视频字幕提取器 v1.0
# 支持：YouTube、B站、抖音、TikTok 等 1700+ 站点

URL="$1"
OUTPUT="${2:-text}"  # text | json | file

[ -z "$URL" ] && echo "用法: video-extract.sh <URL> [text|json|file]" && exit 1

# 检测平台
detect_platform() {
    local url="$1"
    case "$url" in
        *youtube.com*|*youtu.be*) echo "youtube" ;;
        *bilibili.com*|*b23.tv*) echo "bilibili" ;;
        *douyin.com*) echo "douyin" ;;
        *tiktok.com*) echo "tiktok" ;;
        *twitter.com*|*x.com*) echo "twitter" ;;
        *) echo "other" ;;
    esac
}

PLATFORM=$(detect_platform "$URL")
echo "🎬 平台: $PLATFORM"
echo "📺 URL: $URL"
echo ""

cd ~/.agents/skills/skilless && source .venv/bin/activate

# 提取字幕
result=$(timeout 30 python scripts/youtube.py "$URL" 2>&1)

if [ $? -eq 0 ] && [ -n "$result" ]; then
    if [ "$OUTPUT" = "json" ]; then
        echo "$result" | jq -R .
    elif [ "$OUTPUT" = "file" ]; then
        OUTPUT_FILE="$HOME/.openclaw/workspace/memory/inbox/video-$(date +%Y%m%d-%H%M%S).md"
        echo "# 视频字幕提取" > "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "**URL:** $URL" >> "$OUTPUT_FILE"
        echo "**平台:** $PLATFORM" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "$result" >> "$OUTPUT_FILE"
        echo "✅ 保存到: $OUTPUT_FILE"
    else
        echo "$result"
    fi
    exit 0
fi

echo "❌ 提取失败"
exit 1
