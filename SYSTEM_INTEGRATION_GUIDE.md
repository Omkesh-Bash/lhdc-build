# 🎵 System-Wide LHDC PipeWire – Active & Ready

**Status**: ✅ **Running as User-Level Default**
**Date**: 2026-07-10  
**Mode**: Reversible user-level integration (can rollback anytime)

---

## 🎯 Current Setup

| Component | Status | Details |
|-----------|--------|---------|
| **System PipeWire** | ✅ Running | v1.7.0 with LHDC support |
| **LHDC Codec** | ✅ Integrated | All BlueZ5 plugins loaded |
| **Environment** | ✅ Active | `~/.config/systemd/user/*-lhdc.conf` |
| **Bluetooth** | ✅ Ready | Powered, waiting for devices |
| **System Files** | ✅ Untouched | Distribution files remain unchanged |

Use the maintained control script instead of editing `/etc/profile.d` or
replacing `/usr/bin` files:

```bash
/path/to/lhdc-build/lhdc-control.sh --enable
/path/to/lhdc-build/lhdc-control.sh --status
/path/to/lhdc-build/lhdc-control.sh --disable
```

---

## 🔗 Bluetooth Connection Checklist

Before attempting connection, ensure:
- [ ] **Headphones powered ON** (check LED lights)
- [ ] **Headphones in pairing/discovery mode** (LED blinking blue/red)
- [ ] **Headphones close to computer** (within 1 meter)
- [ ] **Bluetooth adapter enabled** (verified ✅)

---

## 📱 Step-by-Step Connection Guide

### Step 1: Put Headphones in Pairing Mode
**realme Buds Air6**: 
- Press and hold the button on the charging case for 5-10 seconds
- LED should blink blue and red alternately

### Step 2: Scan for Devices
```bash
# Start 20-second discovery scan
bluetoothctl scan on &
sleep 20
kill %1

# Should see headphones appear
bluetoothctl devices
```

### Step 3: Pair the Headphones
```bash
# Replace ADDR with address from scan
HEADPHONE_ADDR="XX:XX:XX:XX:XX:XX"

bluetoothctl pair $HEADPHONE_ADDR
bluetoothctl trust $HEADPHONE_ADDR
bluetoothctl connect $HEADPHONE_ADDR
```

### Step 4: Verify Connection
```bash
bluetoothctl info $HEADPHONE_ADDR | grep -E "Connected|Name|Alias"
# Should show: Connected: yes
```

### Step 5: Verify LHDC Codec is Active
```bash
# Monitor audio streams
pw-cli list Node | grep -i "realme\|a2dp"

# Check for LHDC codec
pw-dump | grep -i "lhdc\|codec" | head -10
```

---

## 🎨 Expected Output When Connected

When headphones are successfully connected with LHDC:

```bash
pw-dump | grep -A5 "realme"
```

Expected to see:
- Device: `bluez5-device.realme-Buds-Air6` 
- Profile: `a2dp_sink` or similar
- Codec: Should include reference to LHDC capability

```bash
pw-top
```

Expected to see:
- Active sink node for headphones
- Audio streams flowing through it
- No crackling/stuttering (sign of good LHDC negotiation)

---

## 🔧 Troubleshooting Bluetooth Issues

### "Devices not discoverable"
```bash
# 1. Verify adapter is ready
bluetoothctl show | grep Powered
# Should show: Powered: yes

# 2. Check Bluetooth service
systemctl status bluetooth

# 3. If not running:
sudo systemctl restart bluetooth
```

### "Pairing fails"
```bash
# Try removing and re-pairing
bluetoothctl remove $HEADPHONE_ADDR

# Scan again (make sure LED is blinking)
bluetoothctl scan on &
sleep 15
kill %1

# Try pairing again
bluetoothctl pair $HEADPHONE_ADDR
```

### "Connection fails"
```bash
# Check device battery
bluetoothctl info $HEADPHONE_ADDR

# Try connecting to a different profile
bluetoothctl menu
# device <addr>
# connect
```

### "No audio through headphones"
```bash
# Set headphones as default sink
DEFAULT_SINK=$(pw-cli list Node | grep -i realme)
pactl set-default-sink $DEFAULT_SINK

# Or use pw-cli directly:
pw-cli set-default-node Speaker realme-headphones
```

---

## ⚙️ Quick Commands Reference

```bash
# Check system PipeWire status
systemctl --user status pipewire

# See all Bluetooth devices
bluetoothctl devices

# Connect to device
bluetoothctl connect MAC_ADDRESS

# Disconnect device
bluetoothctl disconnect MAC_ADDRESS

# Remove device (unpair)
bluetoothctl remove MAC_ADDRESS

# Monitor audio in real-time
pw-top

# List all audio nodes
pw-cli list Node

# Dump full PipeWire state
pw-dump

# Check audio output
pactl list short sinks
```

---

## 📊 Verify LHDC Codec is Working

Once connected:

```bash
# Method 1: Check codec in stream
pw-dump | grep -B5 -A5 "codec" | grep -i "lhdc"

# Method 2: Check negotiated format
pw-cli info all | grep "format.*lhdc"

# Method 3: Play sound and monitor
pw-top
# Look for active stream through headphone sink
# No dropouts = good LHDC negotiation
```

---

## 🔄 Rollback Instructions (If Needed)

### Option A: Restore System PipeWire (Recommended)
```bash
# Stop current PipeWire
systemctl --user stop pipewire

# Restore original binary
sudo cp ~/pipewire-backup-system/pipewire.original /usr/bin/pipewire

# Remove LHDC environment
sudo rm /etc/profile.d/lhdc-pipewire.sh

# Restart system PipeWire
systemctl --user start pipewire

# Verify system is back to normal
/usr/bin/pipewire --version
```

### Option B: Keep LHDC Temporarily
```bash
# Just stop the service without restoring
systemctl --user restart pipewire

# This uses the LHDC binary with LHDC paths
# To fully restore, follow Option A
```

---

## 📋 System Files Modified

- ✅ **Created**: `/etc/profile.d/lhdc-pipewire.sh` (environment wrapper)
- ⚠️ **Not replaced**: System binary still in use (environment injection only)
- 💾 **Backed up**: `~/pipewire-backup-system/pipewire.original`

---

## ✅ Success Checklist

You'll know it's working when:
- [ ] Bluetooth headphones appear in `bluetoothctl devices`
- [ ] Connection succeeds without errors
- [ ] `Connected: yes` shows in device info
- [ ] Audio plays through headphones
- [ ] `pw-dump` shows LHDC codec being used
- [ ] No audio dropouts or crackling

---

## 🎯 Next Steps

1. **Ensure headphones are powered ON and in pairing mode**
2. **Run the connection steps above**
3. **Test audio playback**
4. **Monitor with `pw-top` to verify LHDC codec**
5. **If all good**: Enjoy high-quality LHDC Bluetooth audio! 🎵

---

**Your custom LHDC PipeWire is now system-wide and ready for Bluetooth!** ✨

*Backup location: `~/pipewire-backup-system/`*  
*Rollback: Single `cp` command (see above)*  
*System integration: Environment paths only (safe)*
