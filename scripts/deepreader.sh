#!/bin/bash
# DeepReader v2.0 - 双引擎网页读取
# 自动选择最优引擎，一个失败自动切换

URL="$1"
OUTPUT="${2:-text}"  # text | json

[ -z "$URL" ] && echo "用法: deepreader.sh <URL> [text|json]" && exit 1

# 日志
LOG="$HOME/.openclaw/workspace/logs/deepreader.log"
mkdir -p "$(dirname "$LOG")"
log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"; }

log "开始读取: $URL"

# 检测 URL 类型
is_youtube() { [[ "$URL" =~ youtube\.com|youtu\.be ]]; }
is_bilibili() { [[ "$URL" =~ bilibili\.com ]]; }
is_tiktok() { [[ "$URL" =~ tiktok\.com ]]; }
is_twitter() { [[ "$URL" =~ x\.com|twitter\.com ]]; }
is_reddit() { [[ "$URL" =~ reddit\.com ]]; }

# ============================================
# 1. 视频类 URL → yt-dlp（skilless）
# ============================================
if is_youtube || is_bilibili || is_tiktok; then
    log "检测到视频站点，使用 yt-dlp"
    cd ~/.agents/skills/skilless && source .venv/bin/activate
    result=$(python scripts/youtube.py "$URL" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$result" ]; then
        log "yt-dlp 成功"
        if [ "$OUTPUT" = "json" ]; then
            echo "{\"source\": \"ytdlp\", \"success\": true, \"content\": $(echo "$result" | jq -R .)}"
        else
            echo "✅ [yt-dlp] 视频字幕提取成功"
            echo "$result"
        fi
        exit 0
    fi
    log "yt-dlp 失败，尝试其他引擎"
fi

# ============================================
# 2. Twitter/Reddit → DeepReader（专门优化）
# ============================================
if is_twitter || is_reddit; then
    log "检测到社交站点，使用 DeepReader"
    cd ~/.openclaw/workspace/OpenClaw-DeepReeder && source .venv/bin/activate
    result=$(python -c "from deepreader_skill import run; print(run('$URL'))" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$result" ]; then
        log "DeepReader 成功"
        if [ "$OUTPUT" = "json" ]; then
            echo "{\"source\": \"deepreader\", \"success\": true}"
        else
            echo "✅ [DeepReader] 内容读取成功"
            echo "$result"
        fi
        exit 0
    fi
    log "DeepReader 失败，尝试 Jina Reader"
fi

# ============================================
# 3. 通用网页 → DeepReader 优先，Jina Reader 备用
# ============================================
log "尝试 DeepReader（Trafilatura）"

# 批量 URL 检测
urls=$(echo "$URL" | grep -oE 'https?://[^ ]+' | wc -l)
if [ $urls -gt 1 ]; then
    log "检测到 $urls 个 URL，批量处理"
fi

# 并发处理（最多 3 个并发）
cd ~/.openclaw/workspace/OpenClaw-DeepReeder && source .venv/bin/activate

# 使用并发处理多个 URL
for u in $(echo "$URL" | grep -oE 'https?://[^ ]+'); do
    (
        result=$(python -c "from deepreader_skill import run; print(run('$u'))" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$result" ]; then
            echo "✅ [DeepReader] $u"
            echo "$result" | head -20
        else
            echo "❌ [DeepReader] $u 失败，尝试 Jina Reader"
            cd ~/.agents/skills/skilless && source .venv/bin/activate
            result=$(python scripts/web.py "$u" 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$result" ]; then
                echo "✅ [Jina Reader] $u"
                echo "$result" | head -20
            else
                echo "❌ 所有引擎失败: $u"
            fi
        fi
    ) &
    
    # 限制并发数
    if [ $(jobs -r | wc -l) -ge 3 ]; then
        wait
    fi
done

wait
log "批量处理完成"
exit 0

# 单个 URL 处理（原有逻辑）
cd ~/.openclaw/workspace/OpenClaw-DeepReeder && source .venv/bin/activate
result=$(python -c "from deepreader_skill import run; print(run('$URL'))" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$result" ]; then
    log "DeepReader 成功"
    if [ "$OUTPUT" = "json" ]; then
        echo "{\"source\": \"deepreader\", \"success\": true}"
    else
        echo "✅ [DeepReader] 内容读取成功"
        echo "$result"
    fi
    exit 0
fi

# DeepReader 失败，尝试 Jina Reader
log "DeepReader 失败，尝试 Jina Reader"
cd ~/.agents/skills/skilless && source .venv/bin/activate
result=$(python scripts/web.py "$URL" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$result" ]; then
    log "Jina Reader 成功"
    if [ "$OUTPUT" = "json" ]; then
        echo "{\"source\": \"jina-reader\", \"success\": true, \"content\": $(echo "$result" | jq -R .)}"
    else
        echo "✅ [Jina Reader] 内容读取成功"
        echo "$result"
    fi
    exit 0
fi

# 全部失败
log "所有引擎都失败"
if [ "$OUTPUT" = "json" ]; then
    echo "{\"success\": false, \"error\": \"所有引擎都失败\"}"
else
    echo "❌ 读取失败，所有引擎都无法处理此 URL"
fi
exit 1
