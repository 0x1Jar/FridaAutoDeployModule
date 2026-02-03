#!/system/bin/sh
# Frida Server Automatic Deployment Module - Post-FS-Data Script
# Runs during early boot to detect architecture and prepare Frida Server

MODPATH=${0%/*}
MODDIR=$MODPATH
LOGDIR="$MODPATH/data/frida/logs"
LOGFILE="$LOGDIR/frida.log"

# Ensure log directory exists
mkdir -p "$LOGDIR"

# Log function
log_msg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_msg "=== Frida Server Post-FS-Data Script Started ==="
log_msg "Detecting device architecture..."

# Get device CPU architecture
DEVICE_ARCH=$(getprop ro.product.cpu.abi)
log_msg "Device ABI: $DEVICE_ARCH"

# Map Android ABI to Magisk architecture
case "$DEVICE_ARCH" in
  armeabi-v7a)
    ARCH_TYPE="arm"
    FRIDA_BINARY="frida-server-android-arm"
    log_msg "Detected: ARM 32-bit (armeabi-v7a)"
    ;;
  arm64-v8a)
    ARCH_TYPE="arm64"
    FRIDA_BINARY="frida-server-android-arm64"
    log_msg "Detected: ARM 64-bit (arm64-v8a)"
    ;;
  x86)
    ARCH_TYPE="x86"
    FRIDA_BINARY="frida-server-android-x86"
    log_msg "Detected: x86 32-bit"
    ;;
  x86_64)
    ARCH_TYPE="x64"
    FRIDA_BINARY="frida-server-android-x86_64"
    log_msg "Detected: x86_64 64-bit"
    ;;
  *)
    log_msg "ERROR: Unsupported architecture: $DEVICE_ARCH"
    exit 1
    ;;
esac

# Check available binaries in system/bin
SYSTEM_BIN="$MODPATH/system/bin"
if [ -d "$SYSTEM_BIN" ]; then
  log_msg "Available binaries in system/bin:"
  for binary in "$SYSTEM_BIN"/*; do
    if [ -f "$binary" ]; then
      log_msg "  - $(basename $binary)"
    fi
  done
  
  # Remove unnecessary architecture binaries to save space
  log_msg "Cleaning up unnecessary binaries for non-$ARCH_TYPE architectures..."
  
  for binfile in "$SYSTEM_BIN"/frida-server*; do
    if [ -f "$binfile" ]; then
      filename=$(basename "$binfile")
      if ! echo "$filename" | grep -q "$ARCH_TYPE"; then
        log_msg "Removing unused binary: $filename"
        rm -f "$binfile"
      fi
    fi
  done
  
  # Ensure the correct Frida binary is executable
  if [ -f "$SYSTEM_BIN/$FRIDA_BINARY" ]; then
    chmod +x "$SYSTEM_BIN/$FRIDA_BINARY"
    log_msg "Made $FRIDA_BINARY executable"
  else
    log_msg "WARNING: Expected Frida binary not found: $FRIDA_BINARY"
  fi
fi

# Handle BusyBox binaries (keep only architecture-compatible version)
BUSYBOX_DIR="$SYSTEM_BIN"
if [ -d "$BUSYBOX_DIR" ]; then
  log_msg "Processing BusyBox binaries..."
  
  # Set architecture-specific BusyBox as primary
  case "$ARCH_TYPE" in
    arm64)
      if [ -f "$BUSYBOX_DIR/busybox-arm64" ]; then
        chmod +x "$BUSYBOX_DIR/busybox-arm64"
        log_msg "BusyBox arm64 ready"
      fi
      # Remove other architectures
      rm -f "$BUSYBOX_DIR/busybox-arm"
      rm -f "$BUSYBOX_DIR/busybox-x86"
      rm -f "$BUSYBOX_DIR/busybox-x86_64"
      ;;
    arm)
      if [ -f "$BUSYBOX_DIR/busybox-arm" ]; then
        chmod +x "$BUSYBOX_DIR/busybox-arm"
        log_msg "BusyBox arm ready"
      fi
      rm -f "$BUSYBOX_DIR/busybox-arm64"
      rm -f "$BUSYBOX_DIR/busybox-x86"
      rm -f "$BUSYBOX_DIR/busybox-x86_64"
      ;;
    x64)
      if [ -f "$BUSYBOX_DIR/busybox-x86_64" ]; then
        chmod +x "$BUSYBOX_DIR/busybox-x86_64"
        log_msg "BusyBox x86_64 ready"
      fi
      rm -f "$BUSYBOX_DIR/busybox-arm"
      rm -f "$BUSYBOX_DIR/busybox-arm64"
      rm -f "$BUSYBOX_DIR/busybox-x86"
      ;;
    x86)
      if [ -f "$BUSYBOX_DIR/busybox-x86" ]; then
        chmod +x "$BUSYBOX_DIR/busybox-x86"
        log_msg "BusyBox x86 ready"
      fi
      rm -f "$BUSYBOX_DIR/busybox-arm"
      rm -f "$BUSYBOX_DIR/busybox-arm64"
      rm -f "$BUSYBOX_DIR/busybox-x86_64"
      ;;
  esac
fi

log_msg "Post-FS-Data setup completed"
log_msg "Device is ready for Frida Server deployment"
