#!/bin/bash
YELLOW='\033[33m'
NC='\033[0m'
CLAW_DIR="$HOME/.openclaw"
CONFIG_FILE="${CLAW_DIR}/openclaw.json"

echo -e "=============================="
echo -e "#   ${YELLOW}OpenClaw Key Update${NC}"
echo -e "=============================="

if [ ! -f "$CONFIG_FILE" ]; then
  echo "错误：OpenClaw未配置"
  exit 1
fi

baseUrl=$(jq -r '.models.providers.sjtu.baseUrl' "$CONFIG_FILE")

if [ "$baseUrl" = "null" ] || [ -z "$baseUrl" ]; then
    echo "错误：未获取到 sjtu.baseUrl 字段"
    exit 1
fi

TARGET="models.sjtu.edu.cn"
if ! [[ "$baseUrl" == *"$TARGET"* ]]; then
    echo "错误：不匹配的 sjtu.baseUrl 设置"
    exit 1
fi

read -p "$(echo -e "# ${YELLOW}请输入新的apiKey：${NC}")" apiKey

if [[ -z "$baseUrl" || -z "$apiKey" ]]; then
    echo -e "${YELLOW}错误：baseUrl/apiKey 均不能为空！${NC}"
    exit 1
fi

echo -e "\n===== 您的配置信息如下 ======="
echo "# baseUrl: $baseUrl"
echo "# apiKey: $apiKey"
echo "=============================="

read -p "$(echo -e "${YELLOW}是否更新配置？\
(y/Y 确认知晓，其他任意键取消)：${NC}")" confirm

case "$confirm" in
    y|Y)
	echo -e "\n${YELLOW}更新成功。${NC}\n"
        ;;
    *)
        echo -e "\n${YELLOW}取消更新。${NC}"
        exit 0
        ;;
esac

TMPFILE=$(mktemp)
cp "$CONFIG_FILE" "$TMPFILE"

jq --arg apiKey "$apiKey" \
	'.models.providers.sjtu.apiKey = $apiKey' $TMPFILE > $CONFIG_FILE

rm -rf $TMPFILE

