```bash
#!/bin/bash

# 定义颜色代码
INFO='\033[0;36m'  # 青色
BANNER='\033[0;35m' # 洋红色
YELLOW='\033[0;33m' # 黄色
RED='\033[0;31m'    # 红色
GREEN='\033[0;32m'  # 绿色
BLUE='\033[0;34m'   # 蓝色
CYAN='\033[0;36m'   # 青色
NC='\033[0m'        # 无颜色

# 手动显示社交详情和频道信息的大文字
echo "========================================"
echo -e "${YELLOW} 本脚本由 CRYTONODEHINDI 制作 ${NC}"
echo -e "-------------------------------------"

# BANNER颜色的大字幕
echo -e "${BANNER}  CCCCC  RRRRR   Y   Y  PPPP   TTTTT  OOO      N   N   OOO   DDDD  EEEEE      H   H  III  N   N  DDDD   III${NC}"
echo -e "${BANNER} C       R   R    Y Y   P  P     T   O   O     NN  N  O   O  D   D E          H   H   I   NN  N  D   D   I ${NC}"
echo -e "${BANNER} C       RRRRR     Y    PPPP     T   O   O     N N N  O   O  D   D EEEE       HHHHH   I   N N N  D   D   I ${NC}"
echo -e "${BANNER} C       R   R     Y     P       T   O   O     N  NN  O   O  D   D E          H   H   I   N  NN  D   D   I ${NC}"
echo -e "${BANNER}  CCCCC  R    R    Y     P       T    OOO      N   N   OOO   DDDD  EEEEE      H   H  III  N   N  DDDD   III${NC}"

echo "============================================"

# 使用不同颜色使每个链接更加显眼
echo -e "${YELLOW}Telegram: ${GREEN}https://t.me/cryptonodehindi${NC}"
echo -e "${YELLOW}Twitter: ${GREEN}@CryptonodeHindi${NC}"
echo -e "${YELLOW}YouTube: ${GREEN}https://www.youtube.com/@CryptonodesHindi${NC}"
echo -e "${YELLOW}Medium: ${CYAN}https://medium.com/@cryptonodehindi${NC}"

echo "============================================="

# 请求输入URL
read -p "PIPE-URL: " PIPE_URL
read -p "DCDND-URL: " DCDND_URL

# 1. 创建目录
sudo mkdir -p /opt/dcdn

# 2. 从提供的URL下载Pipe工具的二进制文件
if ! sudo curl -L "$PIPE_URL" -o /opt/dcdn/pipe-tool; then
    echo -e "${RED}下载PIPE工具时出现错误！退出...${NC}"
    exit 1
fi

# 3. 从提供的URL下载DCDND二进制文件
if ! sudo curl -L "$DCDND_URL" -o /opt/dcdn/dcdnd; then
    echo -e "${RED}下载DCDND工具时出现错误！退出...${NC}"
    exit 1
fi

# 4. 使二进制文件可执行
sudo chmod +x /opt/dcdn/pipe-tool
sudo chmod +x /opt/dcdn/dcdnd

# 5. 登录以生成访问令牌
echo "请登录以生成访问令牌。请按照以下说明操作:"
/opt/dcdn/pipe-tool login --node-registry-url="https://rpc.pipedev.network"
echo "登录完成。现在您可以进行下一步."

# 6. 生成注册令牌
/opt/dcdn/pipe-tool generate-registration-token --node-registry-url="https://rpc.pipedev.network"

# 7. 创建systemd服务文件
echo "创建systemd服务文件..."
sudo tee /etc/systemd/system/dcdnd.service << 'EOF'
[Unit]
Description=DCDN Node Service
After=network.target
Wants=network-online.target

[Service]
ExecStart=/opt/dcdn/dcdnd \
                --grpc-server-url=0.0.0.0:8002 \
                --http-server-url=0.0.0.0:8003 \
                --node-registry-url="https://rpc.pipedev.network" \
                --cache-max-capacity-mb=1024 \
                --credentials-dir=/root/.permissionless \
                --allow-origin=*
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node
WorkingDirectory=/opt/dcdn

[Install]
WantedBy=multi-user.target
EOF



根据需要在 [Service] 部分更新凭证路径：
sudo nano /etc/systemd/system/dcdnd.service # 打开服务文件
--credentials-dir=/home/dcdn-svc-user/.permissionless \ # 需要更新的行

将之前生成的注册令牌移动到服务用户的主文件夹：
mv /root/.permissionless/registration_token.json /home/dcdn-svc-user/.permissionless

# 8. 打开所需端口
if command -v ufw &>/dev/null; then
    sudo ufw allow 8002/tcp
    sudo ufw allow 8003/tcp
else
    echo -e "${RED}ufw未安装！跳过防火墙配置。${NC}"
fi

# 9. 启动节点服务
sudo systemctl daemon-reload
sudo systemctl enable dcdnd
sudo systemctl start dcdnd

# 10. 生成并注册钱包
echo "生成并注册钱包（由 Cryptonodehindi 制作）..."
/opt/dcdn/pipe-tool generate-wallet --node-registry-url="https://rpc.pipedev.network"
echo "保存您的钱包短语和keypair.json文件以备份（由 Cryptonodehindi 制作）."
/opt/dcdn/pipe-tool link-wallet --node-registry-url="https://rpc.pipedev.network"

# 11. 检查节点是否运行
echo "检查节点状态（由 Cryptonodehindi 制作）..."
/opt/dcdn/pipe-tool list-nodes --node-registry-url="https://rpc.pipedev.network"

echo "脚本成功完成（由 Cryptonodehindi 制作）."

# 显示感谢消息
echo "========================================"
echo -e "${YELLOW} 感谢使用本脚本 ${NC}"
echo -e "-------------------------------------"

# 使用不同颜色使每个链接更加显眼
echo -e "${YELLOW}Telegram: ${GREEN}https://t.me/cryptonodehindi${NC}"
echo -e "${YELLOW}Twitter: ${GREEN}@CryptonodeHindi${NC}"
echo -e "${YELLOW}YouTube: ${GREEN}https://www.youtube.com/@CryptonodesHindi${NC}"
echo -e "${YELLOW}Medium: ${CYAN}https://medium.com/@cryptonodehindi${NC}"

echo "============================================="
```