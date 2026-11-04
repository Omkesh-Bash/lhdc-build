# Quick Reference: LHDC PipeWire Commands

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

### Start Isolated Test
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

## 🔄 Stop System PipeWire (Backup First!)
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

## ✅ Restart System PipeWire
```bash
systemctl --user start pipewire pipewire.socket
systemctl --user status pipewire
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
# Restore config
cp -r ~/pipewire-backup/.config/pipewire ~/.config/

# Restart system
systemctl --user restart pipewire pipewire.socket
```

---

**Keep this file next to your build directory for quick reference!**
