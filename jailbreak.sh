#!/bin/bash
# 自定义越狱脚本

# 自定义 MOTD（可选，删除这部分如果不需要）
cat > /etc/motd << "EOF"
Welcome to My Custom Jailbreak!
EOF

# 清理动态 MOTD
find /etc/update-motd.d/ -type f ! -name '00-header' -delete

# 配置 SSH
sed -i 's/^#*[[:space:]]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*[[:space:]]*PrintLastLog[[:space:]]*.*/PrintLastLog no/' /etc/ssh/sshd_config

# 设置你的密码
echo 'root:mysecret123' | chpasswd
systemctl enable ssh
service ssh start

# 持久化
FILE="/unitree/var/data/deb_update/deb_update.sh"
MARKER="### MyCustom: Enable SSH on boot"
if ! grep -qF "$MARKER" "$FILE"; then
    echo "$MARKER" >> "$FILE"
    echo "echo 'root:mysecret123' | chpasswd" >> "$FILE"
    echo "systemctl enable ssh" >> "$FILE"
    echo "service ssh start" >> "$FILE"
fi

echo 'Jailbroken by Me!' >> /root/README
