# 🎵 Custom LHDC PipeWire – Active & Ready for Bluetooth

**Status**: ✅ **Running**  
**Date**: 2026-07-10  
**Build**: PipeWire v1.7.0 with LHDC v5 codec support

---

## 🚀 Current System Status

| Component | Status | Details |
|-----------|--------|---------|
| **Custom PipeWire** | ✅ Running | PID: 27484 |
| **LHDC Codec Plugin** | ✅ Ready | 329 KB (`libspa-codec-bluez5-lhdc.so`) |
| **Isolation Mode** | ✅ Active | Runtime Dir: `/tmp/lhdc-pw-25284` |
| **System Audio** | ✅ Protected | Original PipeWire stopped (will restart later) |
| **Bluetooth Service** | ✅ Active | Ready to connect devices |

---

## 📱 Bluetooth Connection Instructions

### Step 1: Put Headphones in Pairing Mode
- **realme Buds Air6**: Hold the button on the case for 5-10 seconds until LEDs blink blue/red

### Step 2: Run Auto-Pair Script
```bash
cd $HOME/lhdc-build

# Run the connection script
bash connect-bluetooth-headphones.sh realme
```

### Step 3: Verify Connection
```bash
bluetoothctl info AA:BB:CC:DD:EE:FF | grep -E "Connected|Name|Class"
# Should show: Connected: yes
```

### Step 4: Test Audio
```bash
# Monitor with PipeWire top
CUSTOM_RUNTIME_DIR="/tmp/lhdc-pw-25284"
export XDG_RUNTIME_DIR="$CUSTOM_RUNTIME_DIR"
bash run-lhdc-env.sh $HOME/lhdc-install/bin/pw-top
```

---

## 🛠️ Manual Connection Steps (If Auto-Pair Doesn't Work)

```bash
# 1. Scan for devices in pairing mode
bluetoothctl scan on &
sleep 10
kill %1

# 2. Pair the device
bluetoothctl pair AA:BB:CC:DD:EE:FF

# 3. Connect
bluetoothctl connect AA:BB:CC:DD:EE:FF

# 4. Trust it for auto-reconnect
bluetoothctl trust AA:BB:CC:DD:EE:FF
```

---

## 🔄 System Audio Management

### To Restore System PipeWire
```bash
# When done testing, restart system audio:
systemctl --user start pipewire pipewire.socket

# Verify it's running:
systemctl --user status pipewire
```

### To Stop Custom PipeWire
```bash
# Kill the custom daemon:
kill 27484  # Or: killall pipewire

# Clean up runtime dir:
rm -rf /tmp/lhdc-pw-25284
```

---

## 📊 What to Expect Once Connected

When your headphones connect, you'll see:

```bash
# Via PipeWire dump:
pw-dump | grep -i "realme\|lhdc"

# Expected output:
# "device": {
#   "info": {"type": "device"},
#   "name": "bluez5-device.realme-Buds-Air6",
#   "properties": {"device.name": "realme Buds Air6"}
# }
# "node": {
#   "info": {"type": "node"},
#   "name": "bluez5-node.a2dp_sink",
#   "port": {"name": "a2dp_sink"}
# }
```

And the audio stream should negotiate **LHDC codec** for high-quality Bluetooth audio!

---

## ⚠️ Troubleshooting

### "Headphones not discoverable"
- Ensure LEDs are blinking
- Check Bluetooth adapter: `bluetoothctl show | grep Powered`
- Restart Bluetooth: `sudo systemctl restart bluetooth`

### "Failed to connect"
- Remove old pairing: `bluetoothctl remove AA:BB:CC:DD:EE:FF`
- Pair fresh from pairing mode
- Check device battery (might be too low)

### "No audio through headphones"
- Verify connection: `bluetoothctl info AA:BB:CC:DD:EE:FF`
- Check PipeWire routing: `pw-cli list Node`
- Switch default sink to headphones

---

## 📋 Quick Command Reference

```bash
# Show running PipeWire
ps aux | grep pipewire | grep -v grep

# Monitor audio streams
bash run-lhdc-env.sh $HOME/lhdc-install/bin/pw-top

# See all nodes
bash run-lhdc-env.sh $HOME/lhdc-install/bin/pw-dump

# Check codec being used
bash run-lhdc-env.sh $HOME/lhdc-install/bin/pw-cli info all | grep lhdc

# Restart headphones connection
bluetoothctl disconnect AA:BB:CC:DD:EE:FF
bluetoothctl connect AA:BB:CC:DD:EE:FF
```

---

## ✅ Verification Checklist

When headphones are successfully connected:
- [ ] `bluetoothctl info AA:BB:CC:DD:EE:FF` shows `Connected: yes`
- [ ] `pw-dump` shows realme Buds device
- [ ] Audio plays through headphones (test with system sound)
- [ ] No crackling or stuttering (LHDC codec working)
- [ ] `pw-top` shows active stream

---

**System is ready!** ✨ Just connect your headphones and enjoy LHDC audio quality.

*Custom PipeWire Runtime: `/tmp/lhdc-pw-25284`*  
*System PipeWire: Paused (will restart with `systemctl --user start pipewire`)*
