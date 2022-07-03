#自定义安装过程
#声明SKIPUNZIP=1
SKIPUNZIP=1
#初始化busybox
ASH_STANDALONE=1
setenforce  0
check_magisk_version() {
  ui_print "- Magisk version: $MAGISK_VER"
  if [ "$MAGISK_VER_CODE" -lt 24000 ]; then
    ui_print "*********************************************************"
    ui_print "! Please install Magisk v24.0+ (24000+)"
    abort    "*********************************************************"
  fi
}

chooseport() {
  # Original idea by chainfire and ianmacd @xda-developers
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false 
  while true; do
    local count=0
    while true; do
     # timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events &
      sleep 0.5; count=$((count + 1))
      if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
        return 0
      elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
        return 1
      fi
      [ $count -gt 15 ] && break
    done
    if $error; then
      # abort "未检测到音量键!"
      echo "未检测到音量键。 默认模式"
      
      return 0
    else
      error=true
      echo "- 未检测到音量键。再试一次。"
    fi
  done
}

ui_print "- 芯片架构: $ARCH"
#install_module
ui_print "- 路径: $MODPATH"

# 将 $ZIPFILE 提取到 $MODPATH
ui_print "- 解压模块文件"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

# MODPATH (path):你的模块应该被安装到的路径
# TMPDIR (path):一个你可以临时存储文件的路径
# TMPDIR (path):一个你可以临时存储文件的路径

# 建立配置文件
# mkdir $MODPATH/modol
# mkdir /sdcard/magisk_hook
# config_dir=/sdcard/magisk_hook
# #wget https://github.com/LSPosed/LSPosed/releases/download/v1.8.3/LSPosed-v1.8.3-6552-zygisk-release.zip 
# ui_print "选择是否安装lsposed"
# ui_print "  音量+ = 安装lsposed"
# ui_print "  音量– = 不安装"
# lspd_url=https://github.com/LSPosed/LSPosed/releases/download/v1.8.3/LSPosed-v1.8.3-6552-zygisk-release.zip
# Shamiko_url=https://github.com/LSPosed/LSPosed.github.io/releases/download/shamiko-115/Shamiko-v0.5.1-115-release.zip
# if chooseport; then
#   ui_print "已选择安装lsposed"
#   echo $lspd_url  >> $config_dir/hook_config.txt
#   wget  $lspd_url -O $config_dir/lsposed.zip 
#   magisk --install-module $config_dir/lsposed.zip & 
# else
#   ui_print "不安装"
# fi

# ui_print "选择是否安装Shamiko"
# ui_print "  音量+ = 安装Shamiko"
# ui_print "  音量– = 不安装"
# if chooseport; then
#   ui_print "已选择安装Shamiko"
#   echo $Shamiko_url  >> $config_dir/hook_config.txt
#   wget  $Shamiko_url -O $config_dir/Shamiko.zip 
#   magisk --install-module $config_dir/Shamiko.zip & 
# else 
#   ui_print "不安装"
# fi

ui_print "检查——安装应用"
results="bin.mt.plus cn.wankkoree.xposed.enablewebviewdebugging com.guoshi.httpcanary io.github.trojan_gfw.igniter.debug mobi.acpm.sslunpinning org.proxydroid"
for pag_name in $results
do
    # ui_print $i
    res=$(pm list packages -3 | cut -d':' -f2 |grep $pag_name)
    if [ $res = $pag_name ]; 
    then
      echo "$pag_name ，已安装"
    else
      echo "$pag_name  安装中**"
      pm install $MODPATH/apks/$pag_name.apk
     fi 
done

#安装应用
# pm install $MODPATH/apks/HttpCanary.apk
# pm install $MODPATH/apks/igniter.apk
# pm install $MODPATH/apks/Proxydroid.apk
# pm install $MODPATH/apks/sslping.apk
# pm install $MODPATH/apks/webview.apk
# pm install $MODPATH/apks/MT.apk

安装常用模块
ui_print "安装常用模块"
magisk --install-module $MODPATH/modle/LSPosed.zip 
magisk --install-module $MODPATH/modle/Shamiko.zip 

#建立环境目录
mkdir $MODPATH/system
mkdir $MODPATH/system/bin
mkdir $MODPATH/zygisk
if [ "$ARCH" = "arm" ]
then
    cp -r $MODPATH/frida-server/frida-server-arm/fs  $MODPATH/system/bin
    cp -r $MODPATH/android-server/arm/android_server  $MODPATH/system/bin
    mv "$MODPATH/lib/armeabi-v7a/libexample.so" "$MODPATH/zygisk/armeabi-v7a.so"
elif [ "$ARCH" = "arm64" ] 
then 
    cp -r $MODPATH/frida-server/frida-server-arm64/fs  $MODPATH/system/bin
    cp -r $MODPATH/android-server/arm64/android_server  $MODPATH/system/bin
    mv "$MODPATH/lib/arm64-v8a/libexample.so" "$MODPATH/zygisk/arm64-v8a.so"
else
    ui_print "*********************************************************"
    ui_print "！ERROR!仅支持arm和arm64"
    abort    "*********************************************************"
fi
#清理目录
rm -rf $MODPATH/frida-server
rm -rf $MODPATH/android-server
rm -rf $MODPATH/lib
rm -rf $MODPATH/apks
rm -rf $MODPATH/modle
#给权限
chmod 777 $MODPATH/system/bin/fs
chmod 777 $MODPATH/system/bin/android_server


