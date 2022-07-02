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
#echo  "$MODDIR"  >> $MODDIR/service.log


