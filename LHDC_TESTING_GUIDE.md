# LHDC v5 Custom PipeWire – Testing & Deployment Guide

## ✅ Build Summary

Your custom PipeWire with LHDC v5 codec is **fully built, installed, and active
as the default user-level audio stack**:

| Component | Location | Status |
|-----------|----------|--------|
| **liblhdcv5** | `$HOME/lhdc-install/lib/liblhdcv5.so` | ✅ Linked |
| **LHDC Codec Plugin** | `$HOME/lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so` | ✅ Compiled |
| **Custom PipeWire** | `$HOME/lhdc-install/bin/pipewire` | ✅ Ready |
| **Wrapper Script** | `$HOME/lhdc-build/run-lhdc-env.sh` | ✅ Active |

---

## ✅ Current Default Integration

The default integration uses reversible user-level systemd drop-ins. It
survives reboot and reconnects, and browser/PulseAudio applications use the
custom PipeWire Pulse bridge.

```bash
$HOME/lhdc-build/lhdc-control.sh --status
$HOME/lhdc-build/lhdc-control.sh --gui
$HOME/lhdc-build/lhdc-control.sh --disable
```

Expected codec:

```text
Codec: lhdc v5
```

## 🧪 Phase 1: Safe Isolated Testing (Historical)

### 1️⃣ Verify LHDC Codec Loads

```bash
cd $HOME/lhdc-build
bash run-lhdc-env.sh $HOME/lhdc-install/bin/spa-inspect \
  $HOME/lhdc-install/lib/spa-0.2/bluez5/libspa-bluez5.so
```

**Expected Output:** You'll see a list of factories including `api.bluez5.*` and codec definitions. Errors like "a dbus is needed" are **expected**—they indicate the plugin loaded successfully but needs DBus/BlueZ runtime services (only used when connecting Bluetooth devices).

### 2️⃣ Verify Codec Plugin Loads

```bash
bash run-lhdc-env.sh ldd $HOME/lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so
```

**Expected Output:** Should show:
```
liblhdcv5.so => $HOME/lhdc-install/lib/liblhdcv5.so (0x...)
```

### 3️⃣ Start Custom PipeWire in Isolated Mode (DO NOT replace system service yet)

Create a temporary runtime directory to avoid socket conflicts:

```bash
# Create a temporary XDG runtime directory
CUSTOM_RUNTIME_DIR="/tmp/lhdc-pw-test-$$"
mkdir -p "$CUSTOM_RUNTIME_DIR"
export XDG_RUNTIME_DIR="$CUSTOM_RUNTIME_DIR"

# Start custom PipeWire in the background
cd $HOME/lhdc-build
bash run-lhdc-env.sh $HOME/lhdc-install/bin/pipewire &
PIPEWIRE_PID=$!

sleep 2  # Give it time to initialize

# Check if it's running
ps -p $PIPEWIRE_PID && echo "✅ PipeWire running" || echo "❌ PipeWire failed"

# Inspect loaded modules
bash run-lhdc-env.sh $HOME/lhdc-install/bin/pw-cli info core

# Kill the test instance
kill $PIPEWIRE_PID 2>/dev/null || true
rm -rf "$CUSTOM_RUNTIME_DIR"
```

---

## 🔗 Phase 2: Integration with System Audio (Historical)

### ⚠️ IMPORTANT: Backup Your System First

Before integrating with system audio, make a backup:

```bash
# Backup system PipeWire config
mkdir -p ~/pipewire-backup
cp -r ~/.config/pipewire ~/pipewire-backup/

# Backup system libraries
sudo cp /usr/lib/x86_64-linux-gnu/libpipewire-0.3.so.0 \
  ~/pipewire-backup/libpipewire-0.3.so.0.system
```

### Option A: Temporary Override (Recommended for Testing)

Keep your system PipeWire running, but use the custom build for **specific tools**:

```bash
# Use custom PipeWire for CLI tools (does NOT affect system audio)
alias pw-custom='bash $HOME/lhdc-build/run-lhdc-env.sh $HOME/lhdc-install/bin'

# Example: inspect with custom build
pw-custom pw-cli info core

# Example: list nodes
pw-custom pw-dump
```

### Option B: Permanent Replacement (Deprecated)

Do not replace distribution-managed files. Use `lhdc-control.sh --enable`
instead; it selects the custom binaries through user-level systemd overrides
without sudo and remains reversible.

If you want the system to use your custom LHDC-enabled PipeWire:

1. **Stop the system PipeWire:**
   ```bash
   systemctl --user stop pipewire pipewire.socket
   ```

2. **Update LD_LIBRARY_PATH system-wide** (create `/etc/profile.d/lhdc-pipewire.sh`):
   ```bash
   # This requires sudo
   sudo tee /etc/profile.d/lhdc-pipewire.sh > /dev/null <<'EOF'
   # LHDC v5 PipeWire Custom Build
   export LD_LIBRARY_PATH="$HOME/lhdc-install/lib:$LD_LIBRARY_PATH"
   export SPA_PLUGIN_DIR="$HOME/lhdc-install/lib/spa-0.2:/usr/lib/x86_64-linux-gnu/spa-0.2:/usr/lib/spa-0.2"
   export PIPEWIRE_MODULE_DIR="$HOME/lhdc-install/lib/pipewire-0.3:/usr/lib/x86_64-linux-gnu/pipewire-0.3:/usr/lib/pipewire-0.3"
   export PIPEWIRE_CONFIG_DIR="$HOME/lhdc-install/share/pipewire"
   export SPA_DATA_DIR="$HOME/lhdc-install/share/spa-0.2:/usr/share/spa-0.2"
   EOF
   ```

3. **Create a wrapper for the system PipeWire service:**
   ```bash
   sudo mkdir -p /opt/lhdc-pipewire
   sudo cp $HOME/lhdc-build/run-lhdc-env.sh \
     /opt/lhdc-pipewire/wrapper.sh
   sudo chmod 755 /opt/lhdc-pipewire/wrapper.sh
   ```

4. **Restart PipeWire with the custom build:**
   ```bash
   systemctl --user start pipewire pipewire.socket
   ```

5. **Verify it's using the LHDC build:**
   ```bash
   bash $HOME/lhdc-build/run-lhdc-env.sh \
     ldd /usr/bin/pipewire | grep lhdcv5
   ```

---

## 🔄 Rollback Instructions

If anything breaks, **your system audio remains untouched** thanks to the local prefix. To restore:

```bash
# Restore the backup
cp -r ~/pipewire-backup/.config/pipewire ~/.config/

# Restart system PipeWire
systemctl --user restart pipewire pipewire.socket

# Verify system audio works
speaker-test -t sine -f 440 -l 1
```

---

## 📋 Testing Checklist

- [ ] **Codec loads**: `spa-inspect` shows LHDC factories
- [ ] **Library links**: `ldd` shows `liblhdcv5.so` resolved
- [ ] **PipeWire starts**: Custom build launches without crashes
- [ ] **Audio device detected**: `pw-dump` or `pw-cli info all` shows Bluetooth devices
- [ ] **LHDC codec available**: Connect a LHDC-compatible Bluetooth device; `pw-dump | grep -i lhdc` shows active codec

---

## 🛠️ Troubleshooting

### "cannot open shared object file"
- Check `LD_LIBRARY_PATH`:
  ```bash
  bash run-lhdc-env.sh echo $LD_LIBRARY_PATH
  ```
- Verify `liblhdcv5.so` exists:
  ```bash
  ls -lah $HOME/lhdc-install/lib/liblhdcv5.so
  ```

### "DBus error" when connecting Bluetooth
- This is **not a codec error**—you need BlueZ running:
  ```bash
  systemctl --user status pipewire
  systemctl status bluetooth
  ```

### PipeWire won't start
- Check for socket conflicts:
  ```bash
  ps aux | grep pipewire
  killall pipewire pulseaudio  # Clean up old instances
  ```

---

## 📚 Next Steps

1. **Test with a real Bluetooth device** that supports LHDC (e.g., Sony, TWS earbuds with LHDC support)
2. **Monitor performance** with `pw-top` or `pw-dump`
3. **Report codec negotiation** via `pw-cli` when connected:
   ```bash
   bash run-lhdc-env.sh $HOME/lhdc-install/bin/pw-cli list Profile
   ```

---

## 📞 Support Files

- **Wrapper script**: `$HOME/lhdc-build/run-lhdc-env.sh`
- **Local installation**: `$HOME/lhdc-install/`
- **PipeWire source**: `$HOME/lhdc-build/pipewire/`
- **LHDC source**: `$HOME/lhdc-build/liblhdcv5/`

---

**Build Date**: 2026-07-10  
**System**: Linux Mint 22.3 (Ubuntu 24.04)  
**RAM Used**: 4GB (with -j2 parallelism limit)
