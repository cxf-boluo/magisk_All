#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
# More info in the main Magisk thread
setenforce  0
fs -D & >> $MODDIR/service.log
android_server & >> $MODDIR/service.log
touch $MODDIR/service.log
echo "Hello World !"  >> $MODDIR/service.log
#!/bin/bash

# 定义日志文件路径
LOGFILE="$MODDIR/service.log"

# 移动证书文件
echo "正在将证书从 /data/misc/user/0/cacerts-added/ 移动到 $MODDIR/system/etc/security/cacerts" >> $LOGFILE
mv -f /data/misc/user/0/cacerts-added/* $MODDIR/system/etc/security/cacerts
if [ $? -eq 0 ]; then
    echo "证书移动成功。" >> $LOGFILE
else
    echo "证书移动失败。" >> $LOGFILE
fi

# 更改文件所有权
echo "正在将 $MODDIR/system/etc/security/cacerts 的所有权更改为 root:root" >> $LOGFILE
chown -R 0:0 $MODDIR/system/etc/security/cacerts
if [ $? -eq 0 ]; then
    echo "所有权更改成功。" >> $LOGFILE
else
    echo "所有权更改失败。" >> $LOGFILE
fi

# 设置默认的 SELinux 安全上下文
default_selinux_context=u:object_r:system_file:s0
echo "默认 SELinux 上下文为 $default_selinux_context" >> $LOGFILE

# 获取现有 SELinux 安全上下文
echo "正在获取 /system/etc/security/cacerts 的当前 SELinux 上下文" >> $LOGFILE
selinux_context=$(ls -Zd /system/etc/security/cacerts | awk '{print $1}')
echo "当前 SELinux 上下文为 $selinux_context" >> $LOGFILE

# 根据安全上下文设置文件的 SELinux 上下文
if [ -n "$selinux_context" ] && [ "$selinux_context" != "?" ]; then
    echo "正在将 $MODDIR/system/etc/security/cacerts 的 SELinux 上下文设置为 $selinux_context" >> $LOGFILE
    chcon -R $selinux_context $MODDIR/system/etc/security/cacerts
    if [ $? -eq 0 ]; then
        echo "SELinux 上下文设置成功为 $selinux_context。" >> $LOGFILE
    else
        echo "SELinux 上下文设置失败为 $selinux_context。" >> $LOGFILE
    fi
else
    echo "正在将 $MODDIR/system/etc/security/cacerts 的 SELinux 上下文设置为默认 $default_selinux_context" >> $LOGFILE
    chcon -R $default_selinux_context $MODDIR/system/etc/security/cacerts
    if [ $? -eq 0 ]; then
        echo "SELinux 上下文设置成功为默认 $default_selinux_context。" >> $LOGFILE
    else
        echo "SELinux 上下文设置失败为默认 $default_selinux_context。" >> $LOGFILE
    fi
fi




