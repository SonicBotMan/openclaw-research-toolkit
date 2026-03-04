#!/bin/bash
# 研究工作流 v3.0 - 整合 deep-analysis + skilless + Exa AI
# 支持 L1/L2/L3 分级，自动选择搜索引擎

QUERY="$1"
LEVEL="${2:-auto}"  # auto | 1 | 2 | 3
OUTPUT="${3:-markdown}"  # markdown | json

[ -z "$QUERY" ] && echo "用法: research.sh <查询> [level] [output]" && exit 1

# 日志
LOG="$HOME/.openclaw/workspace/logs/research.log"
mkdir -p "$(dirname "$LOG")"
log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"; }

log "开始研究: $QUERY (level=$LEVEL)"

# URL 编码
urlencode() { echo "$1" | jq -sRr @uri; }
ENCODED=$(urlencode "$QUERY")

# ============================================
# 搜索引擎
# ============================================

# 1. SearXNG
search_searxng() {
    local q="$1"
    local result
    result=$(curl -s --connect-timeout 8 --max-time 15 \
        "http://192.168.11.147:8515/search?q=$(urlencode "$q")&format=json&language=zh-CN" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        local count=$(echo "$result" | jq '.results | length' 2>/dev/null)
        if [ "$count" -gt 0 ]; then
            echo "$result" | jq -c '.results[:5]'
            return 0
        fi
    fi
    return 1
}

# 2. Exa AI
search_exa() {
    local q="$1"
    local skilless_dir="$HOME/.agents/skills/skilless"
    
    if [ ! -d "$skilless_dir" ]; then
        return 1
    fi
    
    cd "$skilless_dir" && source .venv/bin/activate
    local result
    result=$(python scripts/search.py "$q" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        echo "$result"
        return 0
    fi
    return 1
}

# ============================================
# L1: 快速查询
# ============================================
research_l1() {
    log "L1: 快速查询"
    echo "## L1 快速查询: $QUERY"
    echo ""
    
    # 尝试 SearXNG
    local results
    results=$(search_searxng "$QUERY")
    
    if [ $? -eq 0 ] && [ -n "$results" ]; then
        echo "### 搜索结果 (SearXNG)"
        echo ""
        echo "$results" | jq -r '.[] | "- **\(.title | .[0:60])**\n  \(.url)\n  \(.content | .[0:100])...\n"'
        echo ""
        log "L1 完成: SearXNG"
        return 0
    fi
    
    # 尝试 Exa
    results=$(search_exa "$QUERY")
    if [ $? -eq 0 ] && [ -n "$results" ]; then
        echo "### 搜索结果 (Exa AI)"
        echo ""
        echo "$results" | head -50
        log "L1 完成: Exa"
        return 0
    fi
    
    echo "❌ 搜索失败"
    return 1
}

# ============================================
# L2: 专题研究
# ============================================
research_l2() {
    log "L2: 专题研究"
    echo "## L2 专题研究: $QUERY"
    echo ""
    
    # 多维度搜索
    local dimensions=("最新" "官方" "媒体" "技术")
    local all_results=""
    
    for dim in "${dimensions[@]}"; do
        local q="$QUERY $dim"
        log "L2: 搜索维度 - $dim"
        local results
        results=$(search_searxng "$q")
        if [ $? -eq 0 ] && [ -n "$results" ]; then
            all_results+="### 维度: $dim\n\n"
            all_results+=$(echo "$results" | jq -r '.[] | "- **\(.title | .[0:50])**\n  \(.url)\n"')
            all_results+="\n"
        fi
    done
    
    if [ -n "$all_results" ]; then
        echo -e "$all_results"
        echo "---"
        echo "✅ L2 研究完成"
        log "L2 完成"
        return 0
    fi
    
    echo "❌ 研究失败"
    return 1
}

# ============================================
# L3: 深度调查
# ============================================
research_l3() {
    log "L3: 深度调查"
    
    # 报告文件
    REPORT_DIR="$HOME/.openclaw/workspace/reports"
    REPORT_FILE="$REPORT_DIR/research-$(echo "$QUERY" | md5sum | cut -c1-8)-$(date +%Y%m%d-%H%M%S).md"
    PROGRESS_FILE="$REPORT_DIR/.progress-$(echo "$QUERY" | md5sum | cut -c1-8).json"
    
    mkdir -p "$REPORT_DIR"
    
    # 检查是否有未完成的任务
    if [ -f "$PROGRESS_FILE" ]; then
        echo "🔄 检测到未完成的任务，继续..."
        completed=$(jq -r '.completed // []' "$PROGRESS_FILE" 2>/dev/null)
    else
        completed="[]"
        echo '{}' > "$PROGRESS_FILE"
    fi
    
    echo "## L3 深度调查: $QUERY" | tee "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    echo "报告保存到: $REPORT_FILE"
    echo ""
    
    # 创建任务列表
    echo "### 📋 研究任务列表" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    
    local tasks=(
        "时间维度：最新动态 + 历史背景"
        "来源维度：官方 + 媒体 + 社区"
        "角度维度：商业 + 技术 + 竞争"
        "深度维度：原因 + 未来 + 风险"
        "交叉验证：关键数据 2-3 源"
    )
    
    local total=${#tasks[@]}
    local done=0
    
    for i in "${!tasks[@]}"; do
        echo "- [ ] $((i+1)). ${tasks[$i]}" | tee -a "$REPORT_FILE"
    done
    echo "" | tee -a "$REPORT_FILE"
    
    # 完整多维度搜索
    local templates=(
        "最新 新闻" "近期 发展" "历史 背景"
        "官方 公告" "媒体 报道" "社区 讨论"
        "商业 影响" "技术 原理" "竞争对手"
        "原因 为什么" "未来 趋势" "风险 挑战"
    )
    
    local dim_index=0
    local all_results=""
    
    for template in "${templates[@]}"; do
        local q="$QUERY $template"
        log "L3: 搜索 - $template"
        
        # 更新进度
        echo "{\"last\": \"$template\", \"total\": ${#templates[@]}, \"done\": $dim_index}" > "$PROGRESS_FILE"
        
        echo "🔄 进度: $((dim_index + 1))/${#templates[@]} - $template"
        
        local results
        results=$(search_searxng "$q")
        
        if [ $? -eq 0 ] && [ -n "$results" ]; then
            local count=$(echo "$results" | jq 'length')
            all_results+="### [$template] ($count 条结果)\n\n"
            all_results+=$(echo "$results" | jq -r '.[:3][] | "- **\(.title | .[0:50])**\n  \(.url)\n"')
            all_results+="\n"
        fi
        
        ((dim_index++))
        
        # 每 4 个维度输出一次进度
        if [ $((dim_index % 4)) -eq 0 ]; then
            echo "🔄 已完成 $dim_index / ${#templates[@]} 个维度"
        fi
    done
    
    echo ""
    echo "---"
    echo "### 研究结果汇总" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    echo -e "$all_results" | tee -a "$REPORT_FILE"
    
    echo ""
    echo "### 📊 研究统计" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    echo "- 搜索维度: ${#templates[@]} 个" | tee -a "$REPORT_FILE"
    echo "- 数据来源: SearXNG + Exa AI" | tee -a "$REPORT_FILE"
    echo "- 报告文件: \`$REPORT_FILE\`" | tee -a "$REPORT_FILE"
    echo "- 建议下一步: 阅读完整页面，交叉验证关键数据" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    echo "✅ L3 深度研究完成" | tee -a "$REPORT_FILE"
    
    # 清理进度文件
    rm -f "$PROGRESS_FILE"
    
    log "L3 完成，报告保存到: $REPORT_FILE"
    return 0
}

# ============================================
# 自动判断级别
# ============================================
auto_detect_level() {
    local q="$1"
    
    # L3 关键词
    if [[ "$q" =~ 研究|调查|深度|分析|对比|评估|市场|竞争 ]]; then
        echo "3"
        return
    fi
    
    # L2 关键词
    if [[ "$q" =~ 怎么|如何|为什么|哪个|比较|教程|指南 ]]; then
        echo "2"
        return
    fi
    
    # 默认 L1
    echo "1"
}

# ============================================
# 主流程
# ============================================
if [ "$LEVEL" = "auto" ]; then
    LEVEL=$(auto_detect_level "$QUERY")
    log "自动检测级别: L$LEVEL"
fi

case "$LEVEL" in
    1) research_l1 ;;
    2) research_l2 ;;
    3) research_l3 ;;
    *) echo "❌ 无效级别: $LEVEL"; exit 1 ;;
esac
