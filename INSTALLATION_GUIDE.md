# Installation & Setup Guide

Complete step-by-step guide for installing and configuring the Frida Server Automatic Deployment module.

---

## Table of Contents

1. [Pre-Installation Requirements](#pre-installation-requirements)
2. [Quick Start](#quick-start)
3. [Detailed Installation](#detailed-installation)
4. [Post-Installation Verification](#post-installation-verification)
5. [Initial Configuration](#initial-configuration)
6. [Troubleshooting Installation](#troubleshooting-installation)
7. [First Run](#first-run)

---

## Pre-Installation Requirements

### Hardware Requirements
- Android device (any architecture: ARM 32-bit, ARM 64-bit, x86, x86_64)
- Sufficient storage:
  - ~50MB for Magisk
  - ~30MB for Frida Server binary
  - ~10MB for module data

### Software Requirements
- **Android OS**: Android 5.0 (API 21) or higher
- **Magisk**: Version 20.0 or higher
  - [Download Magisk](https://github.com/topjohnwu/Magisk/releases)
- **Magisk Manager**: Latest version (for easy module management)

### Network Requirements
- **During Installation**: Not required
- **First Boot After Installation**: Internet connection needed
  - Device must be online when module's `service.sh` runs
  - Typically 30-60 seconds after device boots
- **Subsequent Boots**: Optional (checks for updates)

### Root Access
- ✅ Device must have Magisk root installed
- ✅ Magisk Manager must be installed
- ✅ Root access must be fully functional

---

## Quick Start

### For Experienced Users

1. Download `FridaServerAutomaticDeployment.zip`
2. Magisk Manager → Modules → Install from storage
3. Select ZIP file → Wait for installation
4. Reboot device
5. Verify: `adb shell ps | grep frida-server`

**Expected Result**: Frida Server running on port 27042

---

## Detailed Installation

### Step 1: Verify Magisk Installation

Before installing this module, ensure Magisk is properly installed:

```bash
# Check if Magisk is installed
adb shell which magisk

# Should output:
# /data/adb/magisk/magisk

# Verify Magisk root access works
adb shell su -c "whoami"

# Should output:
# root
```

If these commands fail, install Magisk first: https://github.com/topjohnwu/Magisk/releases

### Step 2: Download Module ZIP

Option A: **Via GitHub Releases** (Recommended)
- Visit: https://github.com/yourusername/FridaAutoDeployModule/releases
- Download `FridaServerAutomaticDeployment.zip` (v1.0.0 or latest)

Option B: **Manual Build**
```bash
git clone https://github.com/yourusername/FridaAutoDeployModule.git
cd FridaAutoDeployModule
zip -r FridaServerAutomaticDeployment.zip .
```

### Step 3: Install via Magisk Manager (GUI)

**Recommended Method - Easiest**

1. **Open Magisk Manager**
   - Tap the app icon

2. **Navigate to Modules**
   - Bottom menu → Select "Modules" tab

3. **Install New Module**
   - Tap the button with `+` icon or "Install from storage"
   - Icon looks like: ⬇️ or similar

4. **Select ZIP File**
   - Navigate to your Downloads folder
   - Select `FridaServerAutomaticDeployment.zip`
   - Magisk verifies the ZIP structure

5. **Wait for Installation**
   - Status shows: "Installing..."
   - Progress bar indicates installation progress
   - **Do not close the app** until installation completes
   - Takes typically 5-15 seconds

6. **Installation Complete**
   - You'll see: "Installation successful"
   - Or: "Module installed successfully"

7. **Reboot Device**
   - Option 1: Tap "Reboot" button in Magisk Manager
   - Option 2: Manual reboot via Settings → Power → Restart
   - **Device MUST reboot** for module to activate

### Step 4: Install via ADB (Advanced)

**For users without Magisk Manager GUI**

```bash
# Push ZIP to device
adb push FridaServerAutomaticDeployment.zip /data/local/tmp/

# Open adb shell
adb shell

# Install module (Magisk v20.0+ required)
su -c "magisk --install-module /data/local/tmp/FridaServerAutomaticDeployment.zip"

# Or manually place in modules folder
su -c "unzip /data/local/tmp/FridaServerAutomaticDeployment.zip -d /data/adb/modules/frida_server_auto_deploy/"
su -c "chmod +x /data/adb/modules/frida_server_auto_deploy/*.sh"

# Exit shell
exit

# Reboot from PC
adb reboot
```

### Step 5: Verify Installation Location

After reboot, verify module is installed:

```bash
# Check module directory exists
adb shell ls /data/adb/modules/frida_server_auto_deploy/

# Should show:
# customize.sh
# data/
# module.prop
# post-fs-data.sh
# service.sh
# system/
# uninstall.sh
# etc.
```

---

## Post-Installation Verification

### Check 1: Module Active in Magisk

```bash
# Method 1: Open Magisk Manager
# Modules tab → Should see "Frida Server Automatic Deployment" listed
# ✅ = Module is active
# ⚠️ = Module is installed but disabled (click to enable)
```

### Check 2: Verify Frida Process Running

```bash
# Check if Frida Server is running
adb shell ps | grep frida-server

# Expected output (example):
# root    1234  1.5 2.3 456789 123456 S frida-server-android-arm64

# If not running, try:
adb shell su -c "ps | grep frida-server"
```

### Check 3: Verify Port Listening

```bash
# Check if Frida is listening on port 27042
adb shell ss -an | grep 27042

# Expected output:
# tcp  LISTEN  0  128  0.0.0.0:27042  0.0.0.0:*

# Alternative command:
adb shell netstat -an | grep 27042
```

### Check 4: View Installation Logs

```bash
# Check module installation log
adb shell su -c "cat /data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log"

# Expected log entries (example):
# [2026-02-04 12:34:56] ==========================================
# [2026-02-04 12:34:56] Frida Server Service Script Started
# [2026-02-04 12:34:56] ==========================================
# [2026-02-04 12:34:57] Device Architecture: arm64-v8a (arm64)
# [2026-02-04 12:34:58] Checking latest Frida version from GitHub...
# [2026-02-04 12:35:02] ✓ Frida Server is running successfully
```

### Check 5: Test Connectivity

```bash
# From PC, test Frida connection (requires Frida tools installed)
frida-ps -H <device_ip>:27042

# Expected output (example):
# PID   NAME
# 1     init
# 2     kthreadd
# ... (list of running processes)
```

---

## Initial Configuration

### Default Settings

The module comes with sensible defaults:

- **Listening Port**: 27042 (standard Frida port)
- **Bind Address**: 0.0.0.0 (accessible from network)
- **Auto-Update**: Enabled (checks GitHub on each boot)
- **Logging**: Enabled (writes to `data/frida/logs/frida.log`)

### Optional Customizations

#### Custom Port Configuration (Advanced)

To change the listening port, edit `service.sh`:

```bash
# On PC:
adb pull /data/adb/modules/frida_server_auto_deploy/service.sh

# Edit the file, change:
# FRIDA_PORT=27042
# To your desired port (e.g., FRIDA_PORT=5555)

# Push back:
adb push service.sh /data/adb/modules/frida_server_auto_deploy/

# Set permissions:
adb shell su -c "chmod +x /data/adb/modules/frida_server_auto_deploy/service.sh"

# Restart Frida:
adb shell su -c "pkill -9 frida-server && sh /data/adb/modules/frida_server_auto_deploy/service.sh"
```

#### Disable Auto-Update

To prevent automatic version updates:

```bash
# On device:
adb shell su -c "echo 'DISABLE_UPDATE=1' >> /data/adb/modules/frida_server_auto_deploy/service.sh"

# Or comment out the update check line in service.sh
```

---

## Troubleshooting Installation

### Problem: "Installation failed" in Magisk Manager

**Causes**:
- Corrupted ZIP file
- Insufficient storage space
- Magisk version too old (< v20.0)

**Solutions**:
1. Verify ZIP integrity: `unzip -t FridaServerAutomaticDeployment.zip`
2. Check storage: `adb shell df -h /data`
3. Update Magisk: Download latest from https://github.com/topjohnwu/Magisk/releases
4. Try manual installation via ADB (see Step 4 above)

### Problem: Module installed but not showing in Magisk Manager

**Solutions**:
```bash
# Check if module directory exists
adb shell ls /data/adb/modules/frida_server_auto_deploy/

# Check if module.prop is valid
adb shell cat /data/adb/modules/frida_server_auto_deploy/module.prop

# Verify permissions
adb shell su -c "ls -la /data/adb/modules/frida_server_auto_deploy/"

# If needed, set correct permissions:
adb shell su -c "chmod -R 755 /data/adb/modules/frida_server_auto_deploy/"
```

### Problem: Device won't reboot after installation

**Solutions**:
1. Wait 2-3 minutes (installation might still be processing)
2. Long-press power button to force reboot
3. If stuck, try:
   ```bash
   adb reboot
   ```
4. If that fails, uninstall module and reinstall:
   ```bash
   adb shell su -c "rm -rf /data/adb/modules/frida_server_auto_deploy/"
   adb reboot
   ```

### Problem: "Permission denied" during installation

**Solutions**:
```bash
# Ensure you have root access
adb shell su -c "whoami"  # Should output: root

# If not working, ensure Magisk root is enabled in Magisk Manager
# Settings → Root Access → Grant

# Then try reinstalling module
```

---

## First Run

### What Happens on First Boot After Installation

1. **Post-FS-Data Phase** (Early Boot - ~10 seconds after boot)
   - Architecture detection
   - Binary selection
   - Unnecessary architecture files deleted
   - Permissions set

2. **Service Phase** (Late Boot - ~30-60 seconds after boot)
   - Network connectivity check (waits up to 30 seconds)
   - GitHub API check for latest Frida version
   - Frida binary download (if not present)
   - Extraction and setup
   - Frida Server daemon started

### Monitoring First Run

```bash
# Option 1: Watch logs in real-time
adb shell su -c "tail -f /data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log"

# Option 2: Check final logs after boot
adb shell su -c "cat /data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log"

# Option 3: Check if Frida is running (after 60 seconds)
adb shell ps | grep frida-server
```

### Expected Timeline

```
Boot Start
    ↓
~10s: Post-FS-Data phase (architecture detection)
    ↓
~30s: Service phase starts (network check begins)
    ↓
~35s: GitHub API check
    ↓
~40s: Frida download (if needed, ~10-20 seconds)
    ↓
~45s: Extraction and setup
    ↓
~50s: Frida Server starts
    ↓
Boot Complete
    ↓
~60s: Frida fully running and ready for connections
```

### Connection Test

After boot completes (60+ seconds):

```bash
# From PC with Frida tools installed
frida-ps -H <device_ip>:27042

# If successful, you'll see process list
# If connection fails, check:
# 1. Device is on same network as PC
# 2. Firewall not blocking port 27042
# 3. Frida is running: adb shell ps | grep frida-server
```

---

## Next Steps

- **Read Documentation**: See [README.md](README.md) for detailed usage
- **Check Logs**: Monitor `frida.log` for any issues
- **Start Using**: Connect with Frida client tools
- **Report Issues**: If something doesn't work, check troubleshooting guide

---

## Support

If you encounter issues during installation:

1. **Check the logs**: `/data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log`
2. **Verify requirements**: Magisk 20.0+, sufficient storage, internet connection
3. **Try manual installation**: Follow Step 4 (ADB installation)
4. **Report issue**: Include device info, logs, and steps taken

---

**Last Updated**: February 4, 2026  
**Module Version**: 1.0.0
