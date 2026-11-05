# Reproducible LHDC on Linux with PipeWire

This document records the complete path used to enable and verify LHDC audio
from a Linux PC to realme Buds Air6. It includes the problems that blocked the
first attempts and the fixes that made the final test work.

## Result

- Device: realme Buds Air6
- Bluetooth address: set `LHDC_DEVICE_ADDRESS` for your own device
- Host: Linux Mint/Ubuntu 24.04 base
- System PipeWire: 1.0.5
- System WirePlumber: 0.4.17
- BlueZ: 5.72
- Adapter: your Bluetooth adapter
- Custom PipeWire: 1.7.0
- Custom WirePlumber: 0.5.19
- Custom install prefix: `$HOME/lhdc-install`
- Negotiated codec: `lhdc_v5`
- Audio mode: stereo A2DP, two channels

The normal system audio installation was kept intact. LHDC was proven through
an isolated user-space PipeWire/WirePlumber stack.

## Important limitation

The Buds must already have LHDC enabled through the vendor Android application
or another supported device. The Android log:

```text
a2dp_vendor_lhdcv3: isValid: lhdc_enabled v3 = true
```

proved that LHDC was enabled on the Android side, but it did not itself prove
that Linux could negotiate LHDC. Linux negotiation had to be verified from
PipeWire's live node property.

LHDC is a stereo A2DP codec here. It does not create native 5.1/7.1 Bluetooth
surround sound.

## Repository layout

The project directory contains separate repositories:

```text
lhdc-build/
├── pipewire/      # PipeWire fork with LHDC codec loading
├── wireplumber/   # WirePlumber configuration
├── liblhdcv3/     # AOSP-derived LHDC v3 encoder
├── liblhdcv5/     # LHDC v5 encoder source
├── run-lhdc-env.sh
├── lhdc-status.sh
├── lhdc-control.sh
└── connect-headphones.sh
```

The known-good component commits are:

| Component | Commit | Purpose |
|---|---|---|
| PipeWire | `1067982f0` | Load both LHDC v5 and separate LHDC v3 SPA plugins |
| WirePlumber | `abdf127` | Enable `lhdc_v5` and experimental `lhdc_v3` |
| liblhdcv3 | `a2f3d71` | Add and test the AOSP-derived v3 encoder |
| liblhdcv5 | `0df76b0` | Honor install paths in generated pkg-config metadata |

## Why the first attempts failed

### 1. Stock Linux packages did not provide LHDC

The stock PipeWire/WirePlumber packages exposed common codecs such as SBC and
LDAC, but not the required LHDC encoder and SPA codec plugin.

**Fix:** build a separate PipeWire stack and install it under
`$HOME/lhdc-install` instead of replacing system packages.

### 2. Android support did not automatically transfer to Linux

The Android `lhdc_enabled` message only described Android's configuration.
Linux still needed a compatible encoder, codec advertisement, and AVDTP
negotiation with the Buds.

**Fix:** treat Android as evidence that the earbuds can use LHDC, then verify
Linux using the active PipeWire node's `api.bluez5.codec` property.

### 3. LHDC v3 was a separate plugin

PipeWire's codec loader initially requested only the `lhdc` plugin. The v3
implementation exported a separate `lhdc_v3` plugin, so it was never loaded.

**Fix:** update `pipewire/spa/plugins/bluez5/codec-loader.c` to load both:

```text
api.codec.bluez5.media.lhdc
api.codec.bluez5.media.lhdc_v3
```

The v3 identifiers used were:

```text
Vendor ID: 0x053a
Codec ID:  0x4c33
```

LHDC v5 uses codec ID `0x4c35`.

### 4. Custom and system PipeWire files were mixed

The first wrapper allowed system SPA plugins/modules/data to remain visible.
That produced ABI warnings such as:

```text
7 != 17
```

This meant the custom PipeWire could load incompatible system components.

**Fix:** `run-lhdc-env.sh` sets only the custom prefix for libraries, SPA
plugins, SPA data, PipeWire modules, PipeWire configuration, and binaries:

```bash
LD_LIBRARY_PATH=$HOME/lhdc-install/lib
SPA_PLUGIN_DIR=$HOME/lhdc-install/lib/spa-0.2
SPA_DATA_DIR=$HOME/lhdc-install/share/spa-0.2
PIPEWIRE_MODULE_DIR=$HOME/lhdc-install/lib/pipewire-0.3
PIPEWIRE_CONFIG_DIR=$HOME/lhdc-install/share/pipewire
```

### 5. WirePlumber selected the system 0.4 configuration

The custom WirePlumber 0.5 binary initially tried to read
`/usr/share/wireplumber/wireplumber.conf`, which belongs to WirePlumber 0.4.

**Fix:** export all custom WirePlumber paths before launching it:

```bash
WIREPLUMBER_MODULE_DIR=$HOME/lhdc-install/lib/wireplumber-0.5
WIREPLUMBER_CONFIG_DIR=$HOME/lhdc-install/share/wireplumber
WIREPLUMBER_DATA_DIR=$HOME/lhdc-install/share/wireplumber
```

### 6. The system daemon continued owning Bluetooth profiles

Stopping only the visible PipeWire processes was insufficient. The user
systemd socket units could restart the system daemon, producing:

```text
RegisterProfile() failed: org.bluez.Error.NotPermitted
```

and:

```text
Multiple sound server instances ... are probably trying to use Bluetooth audio
```

**Fix:** disconnect the Buds, stop the services and their socket units, wait
briefly, then start the isolated stack:

```bash
bluetoothctl disconnect "$LHDC_DEVICE_ADDRESS"
systemctl --user stop wireplumber pipewire-pulse pipewire \
  pipewire-pulse.socket pipewire.socket
sleep 3
```

### 7. A successful connection was not enough

The Buds could connect while Linux still selected SBC. Capability files and
installed libraries were not proof of actual use.

**Fix:** require all three checks:

1. `api.bluez5.codec` is `lhdc_v5`
2. The LHDC encoder reports `lhdcv5BT_init_encoder: success!`
3. Real stereo audio completes playback

## Build and installation outline

The exact Meson options can vary with source revisions, but the build must
produce the following artifacts:

```text
$HOME/lhdc-install/bin/pipewire
$HOME/lhdc-install/bin/wireplumber
$HOME/lhdc-install/bin/pw-dump
$HOME/lhdc-install/lib/liblhdcv5.so
$HOME/lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so
$HOME/lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc-v3.so
$HOME/lhdc-install/share/wireplumber/wireplumber.conf.d/10-lhdc.conf
```

Build the v3 encoder and run its tests before installing it:

```bash
cd $HOME/lhdc-build/liblhdcv3
make
# Expected: 66 unit tests and 6 round-trip tests pass
```

Build PipeWire and WirePlumber from their known-good branches, install both
with the same prefix, and install the v3/v5 libraries and SPA plugins into
that prefix. Keep the system packages untouched.

## WirePlumber LHDC configuration

The version-controlled example is:

[10-lhdc.conf]($HOME/lhdc-build/wireplumber/src/config/wireplumber.conf.d.examples/10-lhdc.conf)

The installed file must enable both codecs and use automatic quality:

```text
bluez5.codecs = [ lhdc_v5 lhdc_v3 ]
bluez5.a2dp.lhdc.quality = "auto"
```

LHDC v3 is experimental and was not selected by the Buds in the final tests.
LHDC v5 is the verified codec.

## Reusable status command

The helper reads the negotiated live codec, not merely the installed library:

```bash
cd $HOME/lhdc-build
./lhdc-status.sh
./lhdc-status.sh --watch
./lhdc-status.sh --gui
```

Expected successful output:

```text
Device: AA:BB:CC:DD:EE:FF
Codec: lhdc v5
Profile: a2dp-sink
```

## Clean isolated test procedure

Replace `RUNTIME` and `LOGDIR` as needed. Do not run this while the system
PipeWire Bluetooth backend is active.

```bash
PREFIX=$HOME/lhdc-install
RUNTIME=/tmp/lhdc-runtime-$(id -u)
LOGDIR=/tmp/lhdc-logs-$(date +%s)
mkdir -p "$RUNTIME" "$LOGDIR"

bluetoothctl disconnect "$LHDC_DEVICE_ADDRESS" || true
systemctl --user stop wireplumber pipewire-pulse pipewire \
  pipewire-pulse.socket pipewire.socket
sleep 3

export XDG_RUNTIME_DIR="$RUNTIME"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export LD_LIBRARY_PATH="$PREFIX/lib"
export PATH="$PREFIX/bin:$PATH"
export SPA_PLUGIN_DIR="$PREFIX/lib/spa-0.2"
export SPA_DATA_DIR="$PREFIX/share/spa-0.2"
export PIPEWIRE_MODULE_DIR="$PREFIX/lib/pipewire-0.3"
export PIPEWIRE_CONFIG_DIR="$PREFIX/share/pipewire"
export WIREPLUMBER_MODULE_DIR="$PREFIX/lib/wireplumber-0.5"
export WIREPLUMBER_CONFIG_DIR="$PREFIX/share/wireplumber"
export WIREPLUMBER_DATA_DIR="$PREFIX/share/wireplumber"
export PIPEWIRE_REMOTE=pipewire-0

"$PREFIX/bin/pipewire" --config=pipewire.conf >"$LOGDIR/pipewire.log" 2>&1 &
PIPEWIRE_PID=$!
sleep 2

"$PREFIX/bin/wireplumber" >"$LOGDIR/wireplumber.log" 2>&1 &
WIREPLUMBER_PID=$!
sleep 10

bluetoothctl connect "$LHDC_DEVICE_ADDRESS"
sleep 8

./lhdc-status.sh
```

For playback, use a player from the same PipeWire graph. The system
`pw-play` is sufficient when `PIPEWIRE_REMOTE=pipewire-0` is exported:

```bash
ffmpeg -hide_banner -loglevel error \
  -f lavfi -i 'sine=frequency=440:sample_rate=48000:duration=120' \
  -ac 2 -f wav - | /usr/bin/pw-play -
```

For a longer test, change `duration=120` to `duration=1800` for 30 minutes.
Save logs and check for:

```bash
grep -E 'lhdcv5BT_init_encoder|error|Error|warning|Warning' \
  "$LOGDIR"/{pipewire.log,wireplumber.log}
```

Always clean up using numeric process IDs captured when starting the daemons:

```bash
kill -TERM "$WIREPLUMBER_PID" "$PIPEWIRE_PID"
bluetoothctl disconnect "$LHDC_DEVICE_ADDRESS" || true
systemctl --user start pipewire pipewire-pulse wireplumber
systemctl --user is-active pipewire pipewire-pulse wireplumber
```

The final validation completed a two-minute playback and then a 30-minute
stability playback. Both negotiated `lhdc_v5`; the encoder initialized
successfully and the normal services were restored afterward.

## What is and is not finished

Finished:

- LHDC v5 negotiation with realme Buds Air6
- Real stereo playback through LHDC
- LHDC v3 encoder build and tests
- Experimental v3 plugin loading
- Realtime CLI and optional Zenity status display
- Isolated runtime that avoids system ABI contamination
- Repeatable short and long playback validation

Not finished:

- A standard desktop mixer codec dropdown
- Proof that these Buds select LHDC v3
- Native multichannel Bluetooth surround

## Reversible user-level default integration

The recommended default integration does not replace distribution files. It
adds systemd user drop-ins under `~/.config/systemd/user/` that point the
existing user services at the custom PipeWire 1.7.0 and WirePlumber 0.5.19
installation. Distribution packages remain available for rollback and updates.

Enable it:

```bash
./lhdc-control.sh --enable
```

Inspect the live codec:

```bash
./lhdc-control.sh --status
```

Restore the distribution PipeWire/WirePlumber binaries:

```bash
./lhdc-control.sh --disable
```

The optional GUI can be started with:

```bash
./lhdc-control.sh --gui
```

Install `lhdc-control.desktop` into
`~/.local/share/applications/` to make it searchable from the desktop
application menu. The GUI can enable LHDC, show the live codec, or restore
system audio. Codec selection is still negotiated automatically; reconnecting
the Buds may be required after changing modes.

The custom WirePlumber configuration advertises LHDC first and retains SBC as
a fallback. If the Buds reject LHDC, the Bluetooth profile can still negotiate
SBC without changing the service configuration.
