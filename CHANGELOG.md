# Changelog

All notable changes to the Frida Server Automatic Deployment module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-02-04

### Added
- Initial stable release of Frida Server Automatic Deployment module
- Automatic architecture detection (ARM 32-bit, ARM 64-bit, x86, x86_64)
- Automatic Frida version checking via GitHub API
- Network connectivity wait mechanism (max 30 seconds)
- Download retry logic (3 attempts with 5-second intervals)
- Multi-method decompression fallback:
  - Primary: `unxz` (standard Linux tool)
  - Secondary: `xz` command
  - Tertiary: `7z` archive manager
  - Fallback: `busybox xzcat`
- Comprehensive logging system for all operations
- Clean module installation and uninstallation
- Full BusyBox compatibility
- Complete English documentation (200+ lines)
- Detailed troubleshooting guide
- Step-by-step manual deployment instructions
- Debugging commands reference

### Features
- ✅ Automatic Frida binary extraction for device architecture
- ✅ Persistent Frida Server daemon (using nohup)
- ✅ Automatic binary cleanup for unused architectures
- ✅ Proper file and script permission handling
- ✅ Real-time operation logging for debugging
- ✅ Graceful error handling with user guidance
- ✅ Support for multiple Frida versions

### Documentation
- `README.md` - Complete user guide with examples
- `RELEASE_NOTES.md` - Detailed release information
- `CHANGELOG.md` - This file, tracking all versions
- `LICENSE` - MIT license
- Inline script comments - Detailed code documentation

### Tested
- ✅ ARM64-v8a (64-bit ARM) device
- ✅ Frida 17.6.2 (latest at release time)
- ✅ Manual deployment procedure
- ✅ Network connectivity handling
- ✅ Retry mechanism
- ✅ Multi-tool decompression fallbacks
- ✅ Module installation via Magisk Manager
- ✅ Frida Server startup and persistence

---

## [Unreleased]

### Planned Features
- [ ] Pre-bundled Frida binaries for offline installation
- [ ] SELinux policy customization for stricter devices
- [ ] Configurable Frida listening port
- [ ] Version pinning option (lock to specific Frida version)
- [ ] Automated health checks
- [ ] Support for custom Frida builds
- [ ] Persistent network connectivity checker before boot

### Potential Improvements
- [ ] Reduce module size with selective binary inclusion
- [ ] Add support for older Frida versions (v16.x compatibility)
- [ ] Implement update rollback mechanism
- [ ] Add web-based status dashboard
- [ ] Support for multiple Frida instances on different ports

---

## Version Format

**Version**: X.Y.Z

- **X** (Major): Breaking changes or major features
- **Y** (Minor): New features, backward compatible
- **Z** (Patch): Bug fixes, backward compatible

---

## How to Contribute

When submitting changes that should be in the changelog:

1. Add entries under `[Unreleased]` section
2. Group changes by type: Added, Changed, Deprecated, Removed, Fixed, Security
3. Use past tense: "Added", "Fixed", "Changed", not "Add", "Fix", "Change"
4. Reference issues/PRs when applicable

---

## Support

For issues or questions about specific versions:
- Check the `RELEASE_NOTES.md` for detailed v1.0.0 information
- View `README.md` for installation and usage instructions
- Check module logs: `/data/adb/modules/frida_server_auto_deploy/data/frida/logs/frida.log`

---

Last Updated: February 4, 2026
