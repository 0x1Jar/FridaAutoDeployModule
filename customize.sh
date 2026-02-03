#!/system/bin/sh
# Frida Server Automatic Deployment Module - Installation Script
# This script customizes the module installation for the target device

ui_print "================================================"
ui_print "Frida Server Automatic Deployment Module"
ui_print "Version 1.0.0"
ui_print "================================================"

# Get device architecture
ui_print "Detecting device architecture..."
case "$ARCH" in
  arm)
    ui_print "✓ Detected ARM (32-bit) architecture"
    FRIDA_ARCH="arm"
    FRIDA_BINARY="frida-server-android-arm"
    ;;
  arm64)
    ui_print "✓ Detected ARM64 (64-bit) architecture"
    FRIDA_ARCH="arm64"
    FRIDA_BINARY="frida-server-android-arm64"
    ;;
  x86)
    ui_print "✓ Detected x86 (32-bit) architecture"
    FRIDA_ARCH="x86"
    FRIDA_BINARY="frida-server-android-x86"
    ;;
  x64)
    ui_print "✓ Detected x86_64 (64-bit) architecture"
    FRIDA_ARCH="x64"
    FRIDA_BINARY="frida-server-android-x86_64"
    ;;
  *)
    ui_print "✗ Unsupported architecture: $ARCH"
    abort "This device architecture is not supported."
    ;;
esac

ui_print ""
ui_print "Setting up module files..."

# Set permissions on scripts
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/customize.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

# Set permissions on system binaries
if [ -d "$MODPATH/system/bin" ]; then
  set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
fi

if [ -d "$MODPATH/system/xbin" ]; then
  set_perm_recursive "$MODPATH/system/xbin" 0 0 0755 0755
fi

ui_print ""
ui_print "Creating required directories..."
mkdir -p "$MODPATH/data/frida"
mkdir -p "$MODPATH/data/frida/logs"
set_perm_recursive "$MODPATH/data" 0 0 0755 0755

ui_print ""
ui_print "✓ Installation setup completed successfully!"
ui_print "✓ The module will start Frida Server on the next boot"
ui_print ""
ui_print "To view logs, use:"
ui_print "  tail -f /data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log"
ui_print ""
ui_print "Please reboot to apply changes..."
