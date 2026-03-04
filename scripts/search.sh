#!/bin/bash
# 智能搜索 Fallback 机制 - v2.1
# 优先级：SearXNG > Exa（AI语义搜索）> MiniMax MCP > DuckDuckGo > 36Kr
# 新增：彩色输出 + 进度显示

QUERY="$1"
OUTPUT_FORMAT="${2:-text}"  # text | json

[ -z "$QUERY" ] && echo "用法: search.sh <查询词> [text|json]" && exit 1

# 彩色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

progress() {
    echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"
}

# 日志文件
LOG_FILE="$HOME/.openclaw/workspace/logs/search-fallback.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 缓存机制（10 分钟 TTL）
CACHE_DIR="$HOME/.openclaw/workspace/cache/search"
CACHE_TTL=600  # 10 分钟

cache_get() {
    local key=$(echo "$1" | md5sum | cut -d' ' -f1)
    local cache_file="$CACHE_DIR/$key.json"
    
    if [ -f "$cache_file" ]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        if [ $age -lt $CACHE_TTL ]; then
            log "缓存命中: $1 (age: ${age}s)"
            cat "$cache_file"
            return 0
        fi
    fi
    return 1
}

cache_set() {
    local key=$(echo "$1" | md5sum | cut -d' ' -f1)
    local cache_file="$CACHE_DIR/$key.json"
    mkdir -p "$CACHE_DIR"
    echo "$2" > "$cache_file"
    log "缓存保存: $1"
}

# 输出结果
output_result() {
    local source="$1"
    local result="$2"
    
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        echo "{\"source\": \"$source\", \"success\": true, \"results\": $result}"
    else
        echo "✅ [$source] 搜索成功"
        echo "$result"
    fi
}

output_error() {
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        echo "{\"source\": \"fallback\", \"success\": false, \"error\": \"所有搜索源都失败\"}"
    else
        echo "❌ 所有搜索源都失败"
    fi
}

# URL 编码
urlencode() {
    echo "$1" | jq -sRr @uri
}

# 重试函数（失败自动重试 3 次）
retry() {
    local max_attempts=3
    local delay=2
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        "$@" && return 0
        log "重试 $attempt/$max_attempts 失败，等待 ${delay}s..."
        sleep $delay
        ((attempt++))
        delay=$((delay * 2))  # 指数退避
    done
    return 1
}

ENCODED_QUERY=$(urlencode "$QUERY")

log "开始搜索: $QUERY"

# ============================================
# 1. SearXNG（最可靠，优先使用）
# ============================================
search_searxng() {
    log "尝试 SearXNG..."
    
    # 检查缓存
    local cached
    cached=$(cache_get "searxng:$QUERY")
    if [ $? -eq 0 ]; then
        if [ "$OUTPUT_FORMAT" = "json" ]; then
            echo "$cached"
        else
            echo "✅ [SearXNG] 搜索成功（缓存）"
            echo "$cached" | jq -r '.results[:5][] | "【\(.title | .[0:50])】\n链接: \(.url)\n摘要: \(.content | .[0:100])...\n来源: \(.engines | join(", "))\n"'
        fi
        return 0
    fi
    
    local result
    result=$(curl -s --connect-timeout 8 --max-time 15 \
        "http://192.168.11.147:8515/search?q=$ENCODED_QUERY&format=json&language=zh-CN" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        local count=$(echo "$result" | jq '.results | length' 2>/dev/null)
        if [ "$count" -gt 0 ]; then
            log "SearXNG 成功，找到 $count 条结果"
            cache_set "searxng:$QUERY" "$result"
            
            if [ "$OUTPUT_FORMAT" = "json" ]; then
                echo "$result" | jq '{"source": "searxng", "success": true, "results": .results[:5]}'
            else
                echo "✅ [SearXNG] 搜索成功"
                echo "$result" | jq -r '.results[:5][] | "【\(.title | .[0:50])】\n链接: \(.url)\n摘要: \(.content | .[0:100])...\n来源: \(.engines | join(", "))\n"'
            fi
            return 0
        fi
    fi
    log "SearXNG 失败"
    return 1
}

# ============================================
# 2. Exa AI 语义搜索（skilless，免费无需Key）
# ============================================
search_exa() {
    log "尝试 Exa AI 搜索..."
    local result
    local skilless_dir="$HOME/.agents/skills/skilless"

    if [ ! -d "$skilless_dir" ]; then
        log "Exa: skilless 未安装"
        return 1
    fi

    result=$(cd "$skilless_dir" && source .venv/bin/activate && \
        python scripts/search.py "$QUERY" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$result" ]; then
        log "Exa AI 搜索成功"

        if [ "$OUTPUT_FORMAT" = "json" ]; then
            echo "{\"source\": \"exa-ai\", \"success\": true, \"results\": $(echo "$result" | jq -R .)}"
        else
            echo "✅ [Exa AI] 语义搜索成功"
            echo "$result" | head -50
        fi
        return 0
    fi
    log "Exa AI 搜索失败"
    return 1
}

# ============================================
# 3. MiniMax MCP（备用）
# ============================================
search_minimax() {
    log "尝试 MiniMax MCP..."
    local result
    result=$(mcporter call minimax-coding-plan.web_search query="$QUERY" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ] && [ "$result" != "null" ]; then
        log "MiniMax MCP 成功"
        
        if [ "$OUTPUT_FORMAT" = "json" ]; then
            echo "{\"source\": \"minimax-mcp\", \"success\": true, \"results\": $result}"
        else
            echo "✅ [MiniMax MCP] 搜索成功"
            echo "$result"
        fi
        return 0
    fi
    log "MiniMax MCP 失败"
    return 1
}

# ============================================
# 3. DuckDuckGo（公共接口）
# ============================================
search_duckduckgo() {
    log "尝试 DuckDuckGo..."
    local result
    result=$(curl -s --connect-timeout 10 --max-time 20 \
        "https://api.duckduckgo.com/?q=$ENCODED_QUERY&format=json&no_html=1" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        local abstract=$(echo "$result" | jq -r '.Abstract // empty' 2>/dev/null)
        local related=$(echo "$result" | jq -r '.RelatedTopics[:3] | map(.Text) | join("\n")' 2>/dev/null)
        
        if [ -n "$abstract" ] || [ -n "$related" ]; then
            log "DuckDuckGo 成功"
            
            if [ "$OUTPUT_FORMAT" = "json" ]; then
                echo "{\"source\": \"duckduckgo\", \"success\": true, \"abstract\": \"$abstract\", \"related\": \"$related\"}"
            else
                echo "✅ [DuckDuckGo] 搜索成功"
                [ -n "$abstract" ] && echo "摘要: $abstract"
                [ -n "$related" ] && echo "相关: $related"
            fi
            return 0
        fi
    fi
    log "DuckDuckGo 失败"
    return 1
}

# ============================================
# 4. 36Kr（中文科技资讯备用）
# ============================================
search_36kr() {
    log "尝试 36Kr..."
    local result
    result=$(curl -s --connect-timeout 10 --max-time 15 \
        "https://www.36kr.com/search/api/search/term?keyword=$ENCODED_QUERY" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        local items=$(echo "$result" | jq '.data.items[:5] | map({title: .title, url: .url})' 2>/dev/null)
        local count=$(echo "$items" | jq 'length' 2>/dev/null)
        
        if [ "$count" -gt 0 ]; then
            log "36Kr 成功，找到 $count 条结果"
            
            if [ "$OUTPUT_FORMAT" = "json" ]; then
                echo "{\"source\": \"36kr\", \"success\": true, \"results\": $items}"
            else
                echo "✅ [36Kr] 搜索成功"
                echo "$items" | jq -r '.[] | "• \(.title)\n  \(.url)"'
            fi
            return 0
        fi
    fi
    log "36Kr 失败"
    return 1
}

# ============================================
# 主流程：按优先级尝试
# ============================================
if [ "$OUTPUT_FORMAT" != "json" ]; then
    echo -e "${GREEN}🔍 搜索:${NC} $QUERY"
    echo ""
fi

# 按优先级尝试（SearXNG 本地最快优先，Exa AI语义搜索次之）
progress "尝试 SearXNG..."
search_searxng && exit 0

progress "尝试 Exa AI..."
search_exa && exit 0

progress "尝试 MiniMax MCP..."
search_minimax && exit 0

progress "尝试 DuckDuckGo..."
search_duckduckgo && exit 0

progress "尝试 36Kr..."
search_36kr && exit 0

# 全部失败
log "所有搜索源都失败"
output_error
exit 1
