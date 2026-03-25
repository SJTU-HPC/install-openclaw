#!/bin/bash
YELLOW='\033[33m'
NC='\033[0m'
CLAW_DIR="$HOME/.openclaw"
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
CONFIG_FILE="${SCRIPT_DIR}/.openclaw.json"
OUTPUT_FILE="${CLAW_DIR}/openclaw.json"

echo -e "=============================="
echo -e "#   ${YELLOW}OpenClaw Config 飞书版${NC}"
echo -e "=============================="

if [ ! -f "$CONFIG_FILE" ]; then
  echo "错误：模板文件不存在"
  exit 1
fi

if [ -f "${CLAW_DIR}/openclaw.json" ]; then
  echo -e "错误：存在已有的OpenClaw配置文件"
  read -p "$(echo -e "${YELLOW}是否重新配置？该操作会重置OpenClaw配置！！！(y/Y 确认，其他任意键取消)：${NC}")" confirm
  case "$confirm" in
      y|Y)
	  rm -rf ${CLAW_DIR}/openclaw.json
	  rm -rf ${CLAW_DIR}/extensions/openclaw-lark
          ;;
      *)
          echo -e "\n${YELLOW}您已取消配置，脚本退出。${NC}"
          exit 0
          ;;
  esac
fi

baseUrl=${baseUrl:-https://models.sjtu.edu.cn/api/v1}
name=${name:-minimax-m2.5}

echo -e "${YELLOW}您将使用默认配置${NC}"
read -p "$(echo -e "# ${YELLOW}请输入apiKey：${NC}")" apiKey

if [[ -z "$baseUrl" || -z "$apiKey" || -z "$name" ]]; then
    echo -e "${YELLOW}错误：baseUrl/apiKey/ID 均不能为空！${NC}"
    exit 1
fi

echo -e "\n===== 您的配置信息如下 ======="
echo "# baseUrl: $baseUrl"
echo "# apiKey: $apiKey"
echo "# name: $name"
echo "=============================="

read -p "$(echo -e "${YELLOW}注意：后续配置将使用飞书APP创建机器人，\
请下载软件并登录飞书账号。用于创建机器人的账号需为个人账号，\
不能绑定已认证的企业，否则可能会导致机器人创建失败。\
(y/Y 确认知晓，其他任意键取消)：${NC}")" confirm

case "$confirm" in
    y|Y)
	echo -e "\n${YELLOW}您已确认同意配置，运行中...${NC}\n"
        ;;
    *)
        echo -e "\n${YELLOW}取消部署。${NC}"
        exit 0
        ;;
esac

if [ ! -d "$CLAW_DIR" ]; then
  mkdir -p $CLAW_DIR/
  # ln -fs ~/openclaw-browser/browser/ $CLAW_DIR/browser
fi

token=$(uuidgen)
workspace=${CLAW_DIR}/workspace

jq --arg baseUrl "$baseUrl" --arg apiKey "$apiKey" --arg name "$name" \
	--arg pname "sjtu/$name" --arg token "$token" --arg workspace "$workspace" \
	'.models.providers.sjtu.baseUrl = $baseUrl |
	.models.providers.sjtu.apiKey = $apiKey |
	.models.providers.sjtu.models[0] |= (.id = $name | .name = $name) |
	.agents.defaults.model.primary = $pname |
	.agents.defaults.workspace = $workspace |
	.gateway.auth.token = $token' $CONFIG_FILE > $OUTPUT_FILE

npm cache clean --force
npx -y @larksuite/openclaw-lark-tools install
