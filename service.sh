#!/system/bin/sh
# Frida Server Automatic Deployment Module - Service Script
# Runs at late boot to check for updates and start Frida Server automatically

MODPATH=${0%/*}
LOGDIR="$MODPATH/data/frida/logs"
LOGFILE="$LOGDIR/frida.log"
DATADIR="$MODPATH/data/frida"
FRIDA_VERSION_FILE="$DATADIR/frida_version.txt"
FRIDA_PORT=27042

# Ensure log directory exists
mkdir -p "$LOGDIR"
mkdir -p "$DATADIR"

log_msg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_msg "=========================================="
log_msg "Frida Server Service Script Started"
log_msg "=========================================="

# Detect device architecture
DEVICE_ARCH=$(getprop ro.product.cpu.abi)
case "$DEVICE_ARCH" in
  armeabi-v7a)
    FRIDA_ARCH="arm"
    FRIDA_BINARY="frida-server-android-arm"
    ;;
  arm64-v8a)
    FRIDA_ARCH="arm64"
    FRIDA_BINARY="frida-server-android-arm64"
    ;;
  x86)
    FRIDA_ARCH="x86"
    FRIDA_BINARY="frida-server-android-x86"
    ;;
  x86_64)
    FRIDA_ARCH="x64"
    FRIDA_BINARY="frida-server-android-x86_64"
    ;;
  *)
    log_msg "ERROR: Unsupported architecture: $DEVICE_ARCH"
    exit 1
    ;;
esac

log_msg "Device Architecture: $DEVICE_ARCH ($FRIDA_ARCH)"
log_msg "Looking for binary: $FRIDA_BINARY"

# Function to get latest Frida version from GitHub
get_latest_frida_version() {
  log_msg "Checking latest Frida version from GitHub..."
  
  # Try to get the latest release info from GitHub API
  LATEST_VERSION=$(curl -s https://api.github.com/repos/frida/frida/releases/latest | grep -o '"tag_name": "[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/^v//')
  
  if [ -z "$LATEST_VERSION" ]; then
    log_msg "WARNING: Could not fetch latest version from GitHub API, using bundled version"
    LATEST_VERSION="17.6.2"
  fi
  
  echo "$LATEST_VERSION"
}

# Function to download and update Frida
update_frida() {
  local version="$1"
  local arch="$2"
  local binary_name="$3"
  
  log_msg "Attempting to download Frida $version for $arch..."
  
  DOWNLOAD_URL="https://github.com/frida/frida/releases/download/$version/frida-server-$version-android-$arch.xz"
  TEMP_FILE="$DATADIR/frida-server.xz"
  
  log_msg "Download URL: $DOWNLOAD_URL"
  
  # Try to download the binary
  if curl -L -o "$TEMP_FILE" "$DOWNLOAD_URL" 2>> "$LOGFILE"; then
    log_msg "Download successful, extracting..."
    
    # Decompress the xz file
    DECOMPRESS_SUCCESS=0
    
    if which unxz > /dev/null 2>&1; then
      log_msg "Using unxz for decompression..."
      unxz -f "$TEMP_FILE" >> "$LOGFILE" 2>&1
      EXTRACTED_FILE="$DATADIR/frida-server"
      DECOMPRESS_SUCCESS=1
    elif which xz > /dev/null 2>&1; then
      log_msg "Using xz for decompression..."
      xz -d -f "$TEMP_FILE" >> "$LOGFILE" 2>&1
      EXTRACTED_FILE="$DATADIR/frida-server"
      DECOMPRESS_SUCCESS=1
    elif which 7z > /dev/null 2>&1; then
      log_msg "Using 7z for decompression..."
      7z x "$TEMP_FILE" -o"$DATADIR" >> "$LOGFILE" 2>&1
      EXTRACTED_FILE="$DATADIR/frida-server"
      DECOMPRESS_SUCCESS=1
    elif which busybox > /dev/null 2>&1; then
      log_msg "Using busybox for decompression..."
      busybox xzcat "$TEMP_FILE" > "$DATADIR/frida-server" 2>> "$LOGFILE"
      EXTRACTED_FILE="$DATADIR/frida-server"
      DECOMPRESS_SUCCESS=1
    else
      log_msg "ERROR: No xz decompression tool found (unxz, xz, 7z, or busybox required)"
      log_msg "Please manually decompress and push Frida Server:"
      log_msg "  PC: unxz frida-server-*.xz"
      log_msg "  adb push frida-server-* /data/adb/modules/frida_server_auto_deploy/system/bin/"
      rm -f "$TEMP_FILE"
      return 1
    fi
    
    if [ "$DECOMPRESS_SUCCESS" -ne 1 ]; then
      log_msg "ERROR: Decompression failed"
      rm -f "$TEMP_FILE"
      return 1
    fi
    
    # Move to system/bin
    if [ -f "$EXTRACTED_FILE" ]; then
      SYSTEM_BIN="$MODPATH/system/bin"
      mkdir -p "$SYSTEM_BIN"
      mv "$EXTRACTED_FILE" "$SYSTEM_BIN/$binary_name"
      chmod +x "$SYSTEM_BIN/$binary_name"
      log_msg "Frida updated successfully to version $version"
      echo "$version" > "$FRIDA_VERSION_FILE"
      return 0
    else
      log_msg "ERROR: Failed to extract Frida binary"
      return 1
    fi
  else
    log_msg "ERROR: Failed to download Frida from $DOWNLOAD_URL"
    return 1
  fi
}

# Check if Frida binary exists
SYSTEM_BIN="$MODPATH/system/bin"
if [ ! -f "$SYSTEM_BIN/$FRIDA_BINARY" ]; then
  log_msg "Frida binary not found, attempting to download..."
  LATEST_VERSION=$(get_latest_frida_version)
  log_msg "Latest Frida version: $LATEST_VERSION"
  update_frida "$LATEST_VERSION" "$FRIDA_ARCH" "$FRIDA_BINARY"
fi

# Check for updates
if [ -f "$FRIDA_VERSION_FILE" ]; then
  INSTALLED_VERSION=$(cat "$FRIDA_VERSION_FILE")
else
  INSTALLED_VERSION="unknown"
  echo "bundled" > "$FRIDA_VERSION_FILE"
fi

log_msg "Installed Frida version: $INSTALLED_VERSION"

# Get latest version and check if update is needed
LATEST_VERSION=$(get_latest_frida_version)
if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "unknown" ]; then
  log_msg "Update available: $INSTALLED_VERSION -> $LATEST_VERSION"
  update_frida "$LATEST_VERSION" "$FRIDA_ARCH" "$FRIDA_BINARY"
else
  log_msg "Frida is up to date (version: $LATEST_VERSION)"
fi

# Ensure binary is executable
if [ -f "$SYSTEM_BIN/$FRIDA_BINARY" ]; then
  chmod +x "$SYSTEM_BIN/$FRIDA_BINARY"
  
  # Check if Frida is already running
  if pgrep -f "$FRIDA_BINARY" > /dev/null; then
    log_msg "Frida Server is already running"
    FRIDA_PID=$(pgrep -f "$FRIDA_BINARY" | head -1)
    log_msg "Frida process ID: $FRIDA_PID"
  else
    log_msg "Starting Frida Server..."
    
    # Start Frida Server in background with nohup for persistence
    nohup "$SYSTEM_BIN/$FRIDA_BINARY" -l 0.0.0.0:$FRIDA_PORT >> "$LOGFILE" 2>&1 &
    FRIDA_PID=$!
    
    log_msg "Frida Server started with PID: $FRIDA_PID"
    log_msg "Listening on 0.0.0.0:$FRIDA_PORT"
    
    # Give it a moment to start
    sleep 2
    
    # Verify it's running
    if pgrep -f "$FRIDA_BINARY" > /dev/null; then
      log_msg "✓ Frida Server is running successfully"
    else
      log_msg "ERROR: Frida Server failed to start"
    fi
  fi
else
  log_msg "ERROR: Frida binary not found at $SYSTEM_BIN/$FRIDA_BINARY"
  log_msg "Please check the module installation"
fi

log_msg "Service script completed"
log_msg ""
