#!/bin/bash
# OpenClaw Research Toolkit - 功能测试脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OpenClaw Research Toolkit - 功能测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 检查依赖
echo "1️⃣ 检查依赖"
command -v curl >/dev/null 2>&1 && pass "curl 已安装" || fail "curl 未安装"
command -v jq >/dev/null 2>&1 && pass "jq 已安装" || fail "jq 未安装"
command -v python3 >/dev/null 2>&1 && pass "python3 已安装" || fail "python3 未安装"
echo ""

# 2. 检查脚本文件
echo "2️⃣ 检查脚本文件"
SKILLS_DIR="$HOME/.openclaw/workspace/skills"

[ -f "$SKILLS_DIR/search-fallback/search.sh" ] && pass "search.sh 存在" || fail "search.sh 缺失"
[ -f "$SKILLS_DIR/deepreader/deepreader.sh" ] && pass "deepreader.sh 存在" || fail "deepreader.sh 缺失"
[ -f "$SKILLS_DIR/research-workflow/research.sh" ] && pass "research.sh 存在" || fail "research.sh 缺失"
[ -f "$HOME/.local/bin/research" ] && pass "统一命令已创建" || warn "统一命令未创建"
echo ""

# 3. 测试搜索引擎
echo "3️⃣ 测试搜索引擎"
echo -n "SearXNG: "
if curl -s --connect-timeout 3 "http://192.168.11.147:8515/healthz" >/dev/null 2>&1; then
    pass "可用"
else
    warn "不可用（将使用备用引擎）"
fi

echo -n "Exa AI (skilless): "
if [ -d "$HOME/.agents/skills/skilless" ]; then
    pass "已安装"
else
    warn "未安装（可选）"
fi
echo ""

# 4. 测试搜索功能
echo "4️⃣ 测试搜索功能"
echo -n "基础搜索: "
if bash "$SKILLS_DIR/search-fallback/search.sh" "test" >/dev/null 2>&1; then
    pass "成功"
else
    fail "失败"
fi

echo -n "缓存测试: "
bash "$SKILLS_DIR/search-fallback/search.sh" "cache test" >/dev/null 2>&1
if bash "$SKILLS_DIR/search-fallback/search.sh" "cache test" 2>&1 | grep -q "缓存"; then
    pass "缓存工作正常"
else
    warn "缓存未命中"
fi
echo ""

# 5. 测试网页读取
echo "5️⃣ 测试网页读取"
echo -n "DeepReader: "
if bash "$SKILLS_DIR/deepreader/deepreader.sh" "https://example.com" >/dev/null 2>&1; then
    pass "成功"
else
    warn "失败（可能需要 Jina Reader 备用）"
fi
echo ""

# 6. 测试研究工作流
echo "6️⃣ 测试研究工作流"
echo -n "L1 快速研究: "
if bash "$SKILLS_DIR/research-workflow/research.sh" "test" 1 >/dev/null 2>&1; then
    pass "成功"
else
    fail "失败"
fi
echo ""

# 7. 测试统计和清理
echo "7️⃣ 测试维护功能"
echo -n "统计: "
if bash "$SKILLS_DIR/search-fallback/stats.sh" >/dev/null 2>&1; then
    pass "成功"
else
    fail "失败"
fi

echo -n "缓存清理: "
rm -rf "$HOME/.openclaw/workspace/cache/search/*" 2>/dev/null && pass "成功" || fail "失败"
echo ""

# 总结
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试完成！"
echo ""
echo "使用方法:"
echo "  research search \"关键词\""
echo "  research read \"URL\""
echo "  research research \"主题\" 3"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
