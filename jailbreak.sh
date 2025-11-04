#!/bin/bash

# ==================== 第一步：创建备份（用于回滚）====================

# 设置备份目录路径，使用时间戳命名避免覆盖
BACKUP_DIR="/root/backup_before_jailbreak"

# 如果备份目录不存在，则创建并备份原始配置
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup for rollback..."
    mkdir -p "$BACKUP_DIR"
    
    # 备份SSH配置文件（用于恢复SSH设置）
    cp /etc/ssh/sshd_config "$BACKUP_DIR/sshd_config.original"
    
    # 备份原始欢迎信息
    cp /etc/motd "$BACKUP_DIR/motd.original" 2>/dev/null || echo "No original motd" > "$BACKUP_DIR/motd.original"
    
    # 备份motd.d目录下的所有文件
    mkdir -p "$BACKUP_DIR/update-motd.d"
    cp -r /etc/update-motd.d/* "$BACKUP_DIR/update-motd.d/" 2>/dev/null || true
    
    # 备份密码文件（保存原始密码哈希）
    cp /etc/shadow "$BACKUP_DIR/shadow.original"
    
    # 备份Unitree启动脚本（如果存在）
    if [ -f /unitree/var/data/deb_update/deb_update.sh ]; then
        cp /unitree/var/data/deb_update/deb_update.sh "$BACKUP_DIR/deb_update.sh.original"
    fi
    
    # 记录备份时间和系统信息
    cat > "$BACKUP_DIR/backup_info.txt" << BACKUPINFO
Backup created: $(date)
Hostname: $(hostname)
Kernel: $(uname -r)
BACKUPINFO
    
    # 创建一键恢复脚本
    cat > "$BACKUP_DIR/ROLLBACK.sh" << 'ROLLBACK'
#!/bin/bash
# 一键恢复到越狱前的状态

echo "=================================="
echo "Rolling back to pre-jailbreak state"
echo "=================================="

BACKUP_DIR="/root/backup_before_jailbreak"

# 恢复SSH配置
echo "Restoring SSH config..."
cp "$BACKUP_DIR/sshd_config.original" /etc/ssh/sshd_config

# 恢复欢迎信息
echo "Restoring MOTD..."
cp "$BACKUP_DIR/motd.original" /etc/motd
rm -rf /etc/update-motd.d/*
cp -r "$BACKUP_DIR/update-motd.d/"* /etc/update-motd.d/ 2>/dev/null || true

# 恢复密码
echo "Restoring root password..."
cp "$BACKUP_DIR/shadow.original" /etc/shadow

# 恢复Unitree启动脚本
if [ -f "$BACKUP_DIR/deb_update.sh.original" ]; then
    echo "Restoring Unitree startup script..."
    cp "$BACKUP_DIR/deb_update.sh.original" /unitree/var/data/deb_update/deb_update.sh
fi

# 重启SSH服务使配置生效
echo "Restarting SSH service..."
systemctl restart ssh

echo ""
echo "=================================="
echo "✅ Rollback completed!"
echo "=================================="
echo "System has been restored to pre-jailbreak state."
echo "You may need to reboot: sudo reboot"
ROLLBACK
    
    # 给恢复脚本添加执行权限
    chmod +x "$BACKUP_DIR/ROLLBACK.sh"
    
    echo "✅ Backup completed at: $BACKUP_DIR"
    echo "   To rollback, run: $BACKUP_DIR/ROLLBACK.sh"
fi

# ==================== 第二步：自定义欢迎信息 ====================

# 创建自定义的欢迎信息（登录时显示）
cat > /etc/motd << "EOF"
  _   _                _
 | |_| |_  ___ _ _ ___| |__  _____ _____ _ _ ___ ___   __ ___ _ __
 |  _| ' \/ -_) '_/ _ \ '_ \/ _ \ V / -_) '_(_-</ -_)_/ _/ _ \ '  \
  \__|_||_\___|_| \___/_.__/\___/\___|_| /__/\___(_)__\___/_|_|_|

     Join our Discord Channel at https://discord.gg/HjSY9JmBEE
EOF

# 删除除了00-header之外的所有motd动态脚本（清理系统默认信息）
find /etc/update-motd.d/ -type f ! -name '00-header' -delete

# ==================== 第三步：配置SSH访问 ====================

# 允许root用户通过SSH登录（修改SSH配置文件）
sed -i 's/^#*[[:space:]]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 禁用"上次登录"信息显示（让登录界面更简洁）
sed -i 's/^#*[[:space:]]*PrintLastLog[[:space:]]*.*/PrintLastLog no/' /etc/ssh/sshd_config

# ==================== 第四步：设置密码（⚠️ 这里改成你的密码）====================

# 设置root用户的新密码
# ⚠️ 把 'your_strong_password_here' 改成你自己的强密码
echo 'root:your_strong_password_here' | chpasswd

# ==================== 第五步：启动SSH服务 ====================

# 设置SSH服务开机自启
systemctl enable ssh

# 立即启动SSH服务
service ssh start

# ==================== 第六步：持久化配置（确保重启后仍有效）====================

# Unitree系统的启动脚本路径
FILE="/unitree/var/data/deb_update/deb_update.sh"

# 标记文本，用于检查是否已添加过配置
MARKER="### Custom: Enable SSH access on boot up"

# 如果启动脚本中还没有我们的配置，则添加
if ! grep -qF "$MARKER" "$FILE"; then
    # 添加标记注释
    echo "$MARKER" >> "$FILE"
    
    # 每次开机时重新设置密码（防止系统更新覆盖）
    # ⚠️ 这里的密码要和上面保持一致
    echo "echo 'root:your_strong_password_here' | chpasswd" >> "$FILE"
    
    # 每次开机时确保SSH服务启用
    echo "systemctl enable ssh" >> "$FILE"
    
    # 每次开机时启动SSH服务
    echo "service ssh start" >> "$FILE"
fi

# ==================== 第七步：添加标记文件 ====================

# 在root目录创建README文件，记录越狱信息
echo 'Jailbroken by Custom Script' >> /root/README
echo "Jailbreak date: $(date)" >> /root/README
echo "Backup location: $BACKUP_DIR" >> /root/README

# ==================== 完成 ====================

echo ""
echo "=========================================="
echo "✅ Jailbreak completed successfully!"
echo "=========================================="
echo ""
echo "📋 Configuration Summary:"
echo "   - SSH enabled and started"
echo "   - Root password changed"
echo "   - Backup created at: $BACKUP_DIR"
echo ""
echo "🔐 Important:"
echo "   - Your password: your_strong_password_here"
echo "   - To rollback: $BACKUP_DIR/ROLLBACK.sh"
echo ""
echo "⚠️  Make sure to save this information!"
echo "=========================================="
