#!/bin/bash
# 调研报告自动上传到 WebDAV
# 用法: upload-report.sh <本地文件路径>

REPORT_FILE="$1"

# WebDAV 配置
WEBDAV_URL="http://192.168.11.147:5005/openclaw/reports/"
WEBDAV_USER="h523034406"
WEBDAV_PASS="He5845211314"

[ -z "$REPORT_FILE" ] && echo "用法: upload-report.sh <文件路径>" && exit 1
[ ! -f "$REPORT_FILE" ] && echo "❌ 文件不存在: $REPORT_FILE" && exit 1

# 获取文件名
FILENAME=$(basename "$REPORT_FILE")

echo "📤 上传报告到 WebDAV..."
echo "   文件: $FILENAME"
echo "   目标: $WEBDAV_URL$FILENAME"

# 创建目录（如果不存在）
curl -s -u "$WEBDAV_USER:$WEBDAV_PASS" \
    --connect-timeout 5 \
    --max-time 10 \
    -X MKCOL "$WEBDAV_URL" 2>/dev/null || true

# 上传文件
HTTP_CODE=$(curl -s -u "$WEBDAV_USER:$WEBDAV_PASS" \
    --connect-timeout 10 \
    --max-time 30 \
    -T "$REPORT_FILE" \
    -w "%{http_code}" \
    -o /tmp/webdav-upload.log \
    "$WEBDAV_URL$FILENAME" 2>/dev/null)

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "204" ]; then
    echo "✅ 上传成功"
    echo "   访问: $WEBDAV_URL$FILENAME"
    exit 0
else
    echo "❌ 上传失败 (HTTP $HTTP_CODE)"
    exit 1
fi
