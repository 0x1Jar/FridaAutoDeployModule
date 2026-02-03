# Frida Server Automatic Deployment Module

## Overview

This Magisk module automates the deployment of Frida Server on Android devices without requiring repetitive manual steps. The module automatically:

- ✅ Detects device architecture (arm, arm64, x86, x86_64)
- ✅ Extracts the correct Frida binary for the device architecture
- ✅ Runs Frida Server automatically on boot
- ✅ Checks for Frida version updates from GitHub API
- ✅ Updates Frida Server automatically if a newer version is available
- ✅ Provides full BusyBox compatibility
- ✅ Logs all operations for debugging

## Key Features

### 1. Automatic Architecture Detection
The module detects the device CPU architecture and automatically selects the appropriate Frida binary. No need to manually choose the version.

**Supported Architectures:**
- ARM 32-bit (armeabi-v7a)
- ARM 64-bit (arm64-v8a)
- x86 32-bit
- x86_64 64-bit

### 2. Automatic Updates
The `service.sh` script checks the latest Frida version from GitHub API on every boot. If a newer version is available, the module will:
- Download the latest version
- Extract the binary
- Replace the old version
- Restart Frida Server

### 3. Frida Lifecycle Management
- **Post-FS-Data Phase:** Prepare files and remove unnecessary binaries
- **Service Phase:** Start Frida Server with `nohup` for background persistence
- **Uninstall:** Clean up all Frida files and restore the system to its original state

### 4. Comprehensive Logging
All operations are logged to a file for easy debugging:
```
/data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log
```

## Installation

### Requirements
- Android device with Magisk installed (version 20.0+)
- Root access through Magisk Manager
- Internet connection to download Frida Server

### Installation Steps

1. **Download the module ZIP:**
   - Use the `FridaServerAutomaticDeployment.zip` file

2. **Install via Magisk Manager:**
   - Open Magisk Manager
   - Select "Modules"
   - Tap the "Install from storage" button
   - Choose the ZIP file
   - Wait for the process to complete
   - Reboot the device

3. **Verify Installation:**
   - Open a terminal and run:
   ```bash
   adb shell ps | grep frida
   ```
   - You should see the `frida-server` process running

## Module Structure

```
FridaServerAutomaticDeployment/
├── module.prop                    # Module metadata
├── customize.sh                   # Custom installation script
├── post-fs-data.sh               # Early boot script (architecture detection)
├── service.sh                    # Late boot script (update & run Frida)
├── uninstall.sh                  # Cleanup script
├── META-INF/
│   └── sepolicy.rule             # Optional SELinux policy rules
├── system/bin/                   # Directory for Frida binaries
│   └── (frida-server binary will be stored here)
└── data/frida/logs/              # Directory for logs
    └── frida.log                 # Operation log file
```

## Script Files

### module.prop
Defines module metadata:
- `id`: Unique module identifier (`frida_server_auto_deploy`)
- `name`: Module display name
- `version`: Module version
- `author`: Module author
- `description`: Complete description of module functionality

### customize.sh
Runs during installation to:
- Detect device architecture
- Set up file and script permissions
- Create required data directories
- Provide installation feedback to the user

### post-fs-data.sh
Runs during early boot phase to:
- Detect device CPU architecture using `getprop ro.product.cpu.abi`
- Select the appropriate Frida binary
- Delete unnecessary binaries (saves space)
- Set executable permissions for binaries

### service.sh
Runs during late boot phase to:
- Check the latest Frida version from GitHub API
- Compare with the installed version
- Download and extract a new version if available
- Start Frida Server with nohup (background daemon)
- Log all operations to the log file

**Frida Connection Information:**
- Port: 27042 (default)
- Bind address: 0.0.0.0 (accessible from network)

### uninstall.sh
Runs when the module is removed to:
- Stop the running Frida Server process
- Remove all Frida binaries
- Remove BusyBox and other binaries
- Clean up log and temporary files
- Remove empty directories

## Accessing Logs

To view Frida Server operation logs in real-time:

```bash
# If permission denied, use su:
adb shell su -c "tail -f /data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log"
```

Log includes:
- Architecture detection
- Frida download status
- Installed and used versions
- Frida process PID
- Errors and warnings

## Debugging Commands

### Check if Frida is running
```bash
adb shell ps | grep frida-server
```

### Stop Frida
```bash
adb shell pkill -9 frida-server
# If permission denied, use su:
adb shell su -c "pkill -9 frida-server"
```

### Manually restart Frida
```bash
adb shell su -c "/data/adb/modules/frida_server_auto_deploy/service.sh"
```

### View installed Frida version
```bash
adb shell cat /data/adb/modules/frida_server_auto_deploy/data/frida/frida_version.txt
# If permission denied, use su:
adb shell su -c "cat /data/adb/modules/frida_server_auto_deploy/data/frida/frida_version.txt"
```

### Check port listening
```bash
adb shell netstat -an | grep 27042
# or
adb shell ss -an | grep 27042
```

### Check module installation
```bash
# If permission denied, use su:
adb shell su -c "ls -la /data/adb/modules/frida_server_auto_deploy/"
```

## Connecting from Client

Once Frida Server is running, you can connect from a Frida client:

```bash
frida-ps -H <android_device_ip>:27042
frida -H <android_device_ip>:27042 -n com.example.app
```

## Troubleshooting

### Permission Denied
If you get "Permission denied" errors, use `su` (root access):
```bash
# Example with su:
adb shell su -c "ls -la /data/adb/modules/frida_server_auto_deploy/"
adb shell su -c "tail -f /data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log"
```

### Frida not running after reboot
1. Check logs: `adb shell su -c "tail -f /data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log"`
2. Verify module is active in Magisk Manager
3. Ensure device has internet connection on boot (for download)
4. **Make sure you rebooted after installation** - module requires reboot to start service.sh
5. Reboot the device again if needed

### "Unsupported architecture" error
- Your device architecture may be uncommon
- Check with: `adb shell getprop ro.product.cpu.abi`
- Create an issue in the repository with your architecture info

### Frida fails to download
- Ensure device has internet connectivity
- Check for firewall or proxy blocking GitHub
- Device must be online during boot for automatic download
- **If device lacks xz decompression tools (unxz, xz, 7z, busybox):**
  - Manually decompress on your PC and push to device:
  ```bash
  # On PC:
  cd /tmp
  wget https://github.com/frida/frida/releases/download/17.6.2/frida-server-17.6.2-android-arm64.xz
  unxz frida-server-17.6.2-android-arm64.xz
  adb push frida-server-17.6.2-android-arm64 /data/local/tmp/frida-server
  adb shell su -c "cp /data/local/tmp/frida-server /data/adb/modules/frida_server_auto_deploy/system/bin/frida-server-android-arm64"
  adb shell su -c "chmod +x /data/adb/modules/frida_server_auto_deploy/system/bin/frida-server-android-arm64"
  adb shell su -c "sh -c 'echo 17.6.2 > /data/adb/modules/frida_server_auto_deploy/data/frida/frida_version.txt'"
  adb shell su -c "nohup /data/adb/modules/frida_server_auto_deploy/system/bin/frida-server-android-arm64 -l 0.0.0.0:27042 &"
  ```

### Permission denied when accessing module files
- Use `su -c` prefix for commands requiring root:
  ```bash
  adb shell su -c "command_here"
  ```
- Ensure Magisk has full access to module files
- Check if you have proper root access via `adb shell su -c "whoami"` (should output `root`)

## Manual Updates

If you want to use a specific Frida version instead of the latest:

1. Download Frida Server from: https://github.com/frida/frida/releases
2. Choose based on your architecture
3. Extract .xz file: `unxz frida-server-x.x.x-android-arm64.xz`
4. Place at: `/data/adb/modules/frida_server_auto_deploy/system/bin/frida-server-android-arm64`
5. Set permission: `chmod +x frida-server-android-arm64`
6. Update version at: `/data/adb/modules/frida_server_auto_deploy/data/frida/frida_version.txt`

## Uninstall

1. Open Magisk Manager
2. Select Modules
3. Find "Frida Server Automatic Deployment"
4. Tap the uninstall button
5. Reboot the device

All Frida files will be removed and the system will be restored to its original state.

## Support

For help or to report issues:
- Check the log file first
- Include output from: `adb shell getprop ro.product.cpu.abi`
- Include Android API level: `adb shell getprop ro.build.version.sdk`
- Include Magisk version

## License

See the LICENSE file for license details.

## References

- Magisk Documentation: https://topjohnwu.github.io/Magisk/
- Frida Framework: https://frida.re/
- Frida Releases: https://github.com/frida/frida/releases