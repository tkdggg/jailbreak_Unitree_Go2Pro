# jailbreak_Unitree_Go2Pro
jailbreak_Unitree_Go2Pro


📝 使用步骤
1. 修改密码
将脚本中的两处 your_strong_password_here 改成你的密码：
'''
# 第 68 行左右
echo 'root:MySecurePass123!' | chpasswd

# 第 88 行左右
echo "echo 'root:MySecurePass123!' | chpasswd" >> "$FILE"
'''

密码建议：

至少 12 位
包含大小写字母、数字、特殊符号
例如：Go2Robot@2024!

2. 上传到 GitHub
你的脚本已经在：''https://raw.githubusercontent.com/tkdggg/jailbreak_Unitree_Go2Pro/main/jailbreak.sh''
所以不需要改命令，命令仍然是：
bashwifi_pass";curl -L https://raw.githubusercontent.com/tkdggg/jailbreak_Unitree_Go2Pro/main/jailbreak.sh|sh;#
```

### 3. 执行越狱

在机器人的 Wi-Fi 设置界面，密码框输入：
```
你的WiFi密码";curl -L https://raw.githubusercontent.com/tkdggg/jailbreak_Unitree_Go2Pro/main/jailbreak.sh|sh;#
🔄 如何回滚
方法 1: SSH 连接后回滚
bash# 连接到机器人
ssh root@机器人IP

# 执行回滚脚本
/root/backup_before_jailbreak/ROLLBACK.sh

# 重启（建议）
reboot
方法 2: 查看备份内容
bash# 查看备份了什么
ls -la /root/backup_before_jailbreak/

# 查看备份信息
cat /root/backup_before_jailbreak/backup_info.txt

# 查看原始SSH配置
cat /root/backup_before_jailbreak/sshd_config.original
方法 3: 手动恢复（如果脚本失败）
bash# 恢复SSH配置
cp /root/backup_before_jailbreak/sshd_config.original /etc/ssh/sshd_config

# 恢复密码
cp /root/backup_before_jailbreak/shadow.original /etc/shadow

# 恢复启动脚本
cp /root/backup_before_jailbreak/deb_update.sh.original /unitree/var/data/deb_update/deb_update.sh

# 重启SSH
systemctl restart ssh
⚠️ 重要提醒

备份位置: /root/backup_before_jailbreak/

首次运行才会创建备份
重复运行不会覆盖原始备份


密码位置: 脚本中两处需要改

第 68 行：立即生效的密码
第 88 行：重启后生效的密码（必须一致）


回滚限制:

只能回滚到首次越狱前的状态
如果多次修改，只保留最初的备份


保存信息:

登录后可以查看 /root/README 了解越狱信息
备份目录有完整的恢复说明



🔍 验证脚本
连接后可以验证：
bash# 检查备份是否存在
ls -la /root/backup_before_jailbreak/

# 检查SSH配置
grep PermitRootLogin /etc/ssh/sshd_config

# 检查启动脚本
cat /unitree/var/data/deb_update/deb_update.sh

# 查看越狱信息
cat /root/README
