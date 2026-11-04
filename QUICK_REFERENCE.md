# Quick Reference: LHDC PipeWire Commands

## Current Default

LHDC v5 is configured as the default user-level audio stack. The configuration
survives reboot and reconnects, while the distribution-managed system files
remain untouched.

```bash
# Check the live negotiated codec
/path/to/lhdc-build/lhdc-control.sh --status

# Open the GUI control
/path/to/lhdc-build/lhdc-control.sh --gui

# Restore the distribution PipeWire/WirePlumber stack
/path/to/lhdc-build/lhdc-control.sh --disable
```

Expected status:

```text
Codec: lhdc v5
Profile: a2dp-sink
```

## 🚀 Essential Commands

### Run Custom PipeWire Tools
```bash
cd /path/to/lhdc-build
bash run-lhdc-env.sh /lhdc-install/bin/<command>
```

### Verify Codec
```bash
bash run-lhdc-env.sh \
  /lhdc-install/bin/spa-inspect \
  /lhdc-install/lib/spa-0.2/bluez5/libspa-bluez5.so
```

### Check Library Links
```bash
bash run-lhdc-env.sh ldd \
  /lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so
```

### Start Isolated Test (advanced)
```bash
CUSTOM_RUNTIME_DIR="/tmp/lhdc-pw-test-$$"
mkdir -p "$CUSTOM_RUNTIME_DIR"
export XDG_RUNTIME_DIR="$CUSTOM_RUNTIME_DIR"

bash run-lhdc-env.sh /lhdc-install/bin/pipewire &

# Test commands here

kill %1  # Stop background PipeWire
rm -rf "$CUSTOM_RUNTIME_DIR"
```

### Check PipeWire Status
```bash
bash run-lhdc-env.sh /lhdc-install/bin/pw-cli info core
```

### Dump All Nodes (Bluetooth Devices, etc.)
```bash
bash run-lhdc-env.sh /lhdc-install/bin/pw-dump
```

### Monitor Performance
```bash
bash run-lhdc-env.sh /lhdc-install/bin/pw-top
```

### List Audio Profiles
```bash
bash run-lhdc-env.sh /lhdc-install/bin/pw-cli list Profile
```

---

## 🔄 Legacy isolated-test commands

The commands below are for advanced troubleshooting only. Do not stop the
system services for normal use; the user-level default is already configured.
```bash
# Backup config
mkdir -p ~/pipewire-backup
cp -r ~/.config/pipewire ~/pipewire-backup/

# Stop service
systemctl --user stop pipewire pipewire.socket

# Verify stopped
systemctl --user status pipewire
```

---

## ✅ Restart the configured default stack
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
systemctl --user is-active pipewire pipewire-pulse wireplumber
```

---

## 📊 Installation Summary
```
Local Prefix:           /lhdc-install
LHDC Library:           lib/liblhdcv5.so
Codec Plugin:           lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so
Custom PipeWire Binary: bin/pipewire
Environment Wrapper:    run-lhdc-env.sh
```

---

## ⚠️ Rollback (If Needed)
```bash
# Remove user-level overrides and return to distribution binaries
/path/to/lhdc-build/lhdc-control.sh --disable
```

---

**Keep this file next to your build directory for quick reference!**
