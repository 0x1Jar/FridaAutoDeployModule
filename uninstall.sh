#!/system/bin/sh
# Frida Server Automatic Deployment Module - Uninstall Script
# Runs when the module is removed to clean up all Frida-related files

MODPATH=${0%/*}
LOGDIR="$MODPATH/data/frida/logs"
LOGFILE="$LOGDIR/uninstall.log"

# Ensure log directory exists for uninstall log
mkdir -p "$LOGDIR" 2>/dev/null

log_msg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_msg "=========================================="
log_msg "Frida Server Module Uninstall Started"
log_msg "=========================================="

# Stop Frida Server if running
log_msg "Checking for running Frida processes..."
if pgrep -f "frida-server" > /dev/null; then
  log_msg "Found running Frida Server processes, stopping..."
  pkill -9 -f "frida-server"
  log_msg "Frida Server stopped"
  sleep 1
else
  log_msg "No running Frida Server processes found"
fi

# Remove Frida binaries
log_msg "Removing Frida Server binaries..."
if [ -d "$MODPATH/system/bin" ]; then
  for file in "$MODPATH/system/bin"/frida-server*; do
    if [ -f "$file" ]; then
      log_msg "Removing: $(basename $file)"
      rm -f "$file"
    fi
  done
fi

# Remove BusyBox binaries
log_msg "Removing BusyBox binaries..."
if [ -d "$MODPATH/system/bin" ]; then
  for file in "$MODPATH/system/bin"/busybox*; do
    if [ -f "$file" ]; then
      log_msg "Removing: $(basename $file)"
      rm -f "$file"
    fi
  done
fi

# Remove system/xbin if it exists
if [ -d "$MODPATH/system/xbin" ]; then
  log_msg "Removing system/xbin directory..."
  rm -rf "$MODPATH/system/xbin"
fi

# Remove data directory with logs and temp files
log_msg "Removing Frida data directory..."
if [ -d "$MODPATH/data/frida" ]; then
  log_msg "Removing logs and temporary files..."
  rm -rf "$MODPATH/data/frida"
fi

# Remove any remaining empty directories
log_msg "Cleaning up empty directories..."
if [ -d "$MODPATH/data" ]; then
  rmdir "$MODPATH/data" 2>/dev/null
fi

if [ -d "$MODPATH/system/bin" ]; then
  rmdir "$MODPATH/system/bin" 2>/dev/null
fi

if [ -d "$MODPATH/system" ]; then
  rmdir "$MODPATH/system" 2>/dev/null
fi

# Remove common directory if it exists
if [ -d "$MODPATH/common" ]; then
  log_msg "Removing common directory..."
  rm -rf "$MODPATH/common"
fi

log_msg "=========================================="
log_msg "Frida Server Module Uninstall Completed"
log_msg "=========================================="
log_msg "All Frida Server files have been removed"
log_msg "System state has been restored"
