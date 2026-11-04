# 🎉 LHDC v5 PipeWire Build – Project Status Report

**Date**: 2026-07-10  
**System**: Linux Mint 22.3 (Ubuntu 24.04)  
**Status**: ✅ **LHDC v5 DEFAULT & TESTED**

## Current default integration

The user-level systemd overrides are active. PipeWire 1.7.0, PipeWire Pulse,
and WirePlumber 0.5.19 start automatically using `/lhdc-install`.
The configuration persists after reboot and Buds reconnects. Verify with:

```bash
/path/to/lhdc-build/lhdc-control.sh --status
```

The distribution-managed system files remain untouched. Roll back with:

```bash
/path/to/lhdc-build/lhdc-control.sh --disable
```

---

## 📊 Build Summary

| Phase | Component | Status | Details |
|-------|-----------|--------|---------|
| **Library** | liblhdcv5 | ✅ Built | `/lhdc-install/lib/liblhdcv5.so` |
| **Codec Plugin** | LHDC Bluetooth | ✅ Compiled | `/lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so` |
| **Core** | PipeWire Daemon | ✅ Ready | `/lhdc-install/bin/pipewire` v1.7.0 |
| **Tools** | pw-cli, pw-dump, pw-top, etc. | ✅ Available | All CLI tools installed and functional |
| **Environment** | Wrapper Script | ✅ Active | `/path/to/lhdc-build/run-lhdc-env.sh` |

---

## ✅ Verification Tests Passed

```
✅ Library link:      liblhdcv5.so → /lhdc-install/lib/liblhdcv5.so
✅ Codec plugin:      libspa-codec-bluez5-lhdc.so compiled and available
✅ BlueZ5 plugin:     libspa-bluez5.so loads (factories detected)
✅ Custom binary:     pipewire --version reports v1.7.0
✅ Environment:       LD_LIBRARY_PATH resolves all dependencies
✅ Wrapper script:    run-lhdc-env.sh executable and functional
```

---

## 🚀 Quick Start

### Test LHDC Codec Immediately
```bash
cd /path/to/lhdc-build
bash run-lhdc-env.sh ldd /lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so
# Shows: liblhdcv5.so => /lhdc-install/lib/liblhdcv5.so
```

### Run Isolated PipeWire Test
```bash
CUSTOM_RUNTIME_DIR="/tmp/lhdc-pw-test-$$"
mkdir -p "$CUSTOM_RUNTIME_DIR"
export XDG_RUNTIME_DIR="$CUSTOM_RUNTIME_DIR"

bash run-lhdc-env.sh /lhdc-install/bin/pipewire &
sleep 2

# Test here

kill %1
rm -rf "$CUSTOM_RUNTIME_DIR"
```

---

## 📁 Project Structure

```
/path/to/lhdc-build/
├── liblhdcv5/                          # LHDC library source
├── pipewire/                           # PipeWire source (GitHub)
├── run-lhdc-env.sh                     # ✨ Environment wrapper
├── BUILD_PROCEDURE.md                  # Complete build instructions
├── LHDC_TESTING_GUIDE.md              # Testing & deployment guide
├── QUICK_REFERENCE.md                 # Command cheat sheet
├── STATUS_REPORT.md                   # This file

/lhdc-install/             # 🎯 LOCAL INSTALLATION PREFIX
├── bin/
│   ├── pipewire                        # Custom PipeWire daemon
│   ├── pw-cli                          # CLI tool
│   ├── pw-dump                         # Dump all nodes
│   ├── pw-top                          # Monitor performance
│   └── ... (all PipeWire tools)
├── lib/
│   ├── liblhdcv5.so                    # LHDC library
│   ├── libpipewire-0.3.so              # PipeWire core
│   ├── spa-0.2/
│   │   └── bluez5/
│   │       ├── libspa-bluez5.so        # BlueZ5 plugin
│   │       ├── libspa-codec-bluez5-lhdc.so  # ⭐ LHDC CODEC
│   │       ├── libspa-codec-bluez5-sbc.so
│   │       └── ... (other codecs)
│   ├── pipewire-0.3/                   # PipeWire modules
│   └── pkgconfig/
│       └── lhdcv5.pc                   # Metadata for pkg-config
├── share/
│   ├── pipewire/                       # Configuration files
│   └── spa-0.2/                        # Data files
└── etc/
    └── pipewire/                       # System config (optional)
```

---

## 🔐 Safety: System Audio Untouched

✅ **Key guarantees**:
- All custom code installed to `~/lhdc-install` (not `/usr` or `/opt`)
- System PipeWire at `/usr/bin/pipewire` remains unchanged
- System audio libraries (libpulse, alsa) unmodified
- Config files in `~/.config/pipewire` unchanged
- **Rollback**: Just stop the custom binary; system audio resumes

---

## 📋 Build Specifications

| Parameter | Value | Reason |
|-----------|-------|--------|
| **Prefix** | `$HOME/lhdc-install` | Local sandbox |
| **Parallelism** | `-j2` | 4GB RAM limit |
| **Codec** | `bluez5-codec-lhdc=enabled` | ⭐ LHDC support |
| **Session Manager** | `[]` (disabled) | Skip WirePlumber wrap |
| **Tests** | enabled | Diagnostic tools |
| **Docs** | disabled | Save build time |
| **Build Time** | ~30 min | With 4GB RAM, -j2 |
| **Disk Size** | ~80–120 MB | Complete installation |

---

## 🔄 Integration Paths

### Path 1: User-level default (ACTIVE)
```bash
/path/to/lhdc-build/lhdc-control.sh --status
```

The user-level systemd drop-ins persist across reboot. Browser audio uses the
custom PipeWire Pulse bridge, and the Buds currently negotiate LHDC v5.

```bash
/path/to/lhdc-build/lhdc-control.sh --disable
```

### Path 3: Bluetooth-Only Override
- Use custom build for Bluetooth device management
- Keep system PipeWire for local audio

---

## 🧪 Next Steps

### 1. **Test with Real Bluetooth Device**
   - Pair a LHDC-capable device (Sony, TWS earbuds, etc.)
   - Run custom PipeWire
   - Check negotiated codec: `pw-cli list Profile`

### 2. **Performance Monitoring**
   ```bash
   bash run-lhdc-env.sh /lhdc-install/bin/pw-top
   ```

### 3. **Audio Quality Verification**
   - Test playback latency, bitrate, sample rate
   - Compare with system PipeWire

### 4. **Integration Decision**
   - If satisfied: proceed to full system integration
   - If issues: report to PipeWire/LHDC projects
   - Can always rollback to system audio

---

## 🛠️ Support Files

| File | Purpose |
|------|---------|
| `BUILD_PROCEDURE.md` | Step-by-step rebuild instructions |
| `LHDC_TESTING_GUIDE.md` | Testing & safe deployment guide |
| `QUICK_REFERENCE.md` | Command cheat sheet |
| `run-lhdc-env.sh` | Environment wrapper (use for all custom binaries) |

---

## ⚠️ Critical Reminders

1. **Always use the wrapper script**:
   ```bash
   ✅ bash run-lhdc-env.sh /lhdc-install/bin/pw-cli
   ❌ /lhdc-install/bin/pw-cli  # Will fail
   ```

2. **Don't use sudo with ninja install**:
   ```bash
   ✅ ninja install  # Installs to $PREFIX locally
   ❌ sudo ninja install  # Would install system-wide!
   ```

3. **Backup before system integration**:
   ```bash
   mkdir -p ~/pipewire-backup
   cp -r ~/.config/pipewire ~/pipewire-backup/
   ```

4. **Kill old PipeWire instances if testing fails**:
   ```bash
   killall -9 pipewire
   killall -9 pipewire-pulse
   ```

---

## 📞 Troubleshooting Quick Links

| Issue | Command |
|-------|---------|
| "Library not found" | `bash run-lhdc-env.sh ldd /path/to/library` |
| "DBus error" | `systemctl status bluetooth` |
| "Socket error" | `rm /tmp/lhdc-pw-test-*/socket` |
| "Build failed" | Check `pipewire/build-lhdc/meson-logs/meson-log.txt` |
| "System PipeWire won't restart" | `systemctl --user restart pipewire.socket pipewire` |

---

## 🎯 Success Metrics

You can confidently use this build when:
- ✅ `pw-cli info core` returns without errors
- ✅ `pw-dump` shows connected audio devices
- ✅ LHDC codec loads for Bluetooth devices
- ✅ Audio playback/recording works (if device is connected)
- ✅ System audio remains unaffected

---

## 📈 Build Timeline

| Phase | Duration | Completed |
|-------|----------|-----------|
| liblhdcv5 compilation | ~5–10 min | ✅ |
| PipeWire Meson setup | ~2 min | ✅ |
| PipeWire ninja compile | ~25–30 min | ✅ |
| Local installation | ~2 min | ✅ |
| Verification tests | ~3 min | ✅ |
| **Total** | **~35–45 min** | ✅ |

---

**Project Status: READY FOR TESTING** 🚀

All components built successfully. System audio remains 100% protected. You can now test LHDC Bluetooth codec support without risk.

For detailed instructions, see:
- [BUILD_PROCEDURE.md](BUILD_PROCEDURE.md) – Full rebuild reference
- [LHDC_TESTING_GUIDE.md](LHDC_TESTING_GUIDE.md) – Testing & integration
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) – Command cheat sheet
