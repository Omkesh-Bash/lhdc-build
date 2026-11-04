# After-Update and Usage Guide

This guide explains what to check after updating Linux, Bluetooth, PipeWire,
WirePlumber, or the project repositories.

## Current setup

- LHDC v5 is the active codec when the Buds are connected.
- Custom PipeWire 1.7.0 and WirePlumber 0.5.19 run through reversible
  user-level systemd drop-ins.
- Browser and PulseAudio applications use the custom PipeWire Pulse bridge.
- Distribution-managed system files are not replaced.
- LHDC configuration persists across logout, reboot, and Buds reconnects.

Verify the live negotiated codec:

```bash
/path/to/lhdc-build/lhdc-control.sh --status
```

Expected output includes:

```text
Codec: lhdc v5
Profile: a2dp-sink
```

The GUI control is available with:

```bash
/path/to/lhdc-build/lhdc-control.sh --gui
```

## Before system updates

Normal updates are generally safe. Be more careful with:

- PipeWire or WirePlumber
- BlueZ and Bluetooth packages
- Linux kernel updates
- Major distribution upgrades

Before a major update, record the current state:

```bash
systemctl --user is-active pipewire pipewire-pulse wireplumber
/path/to/lhdc-build/lhdc-control.sh --status
```

If troubleshooting is needed, temporarily restore the distribution audio
stack:

```bash
/path/to/lhdc-build/lhdc-control.sh --disable
systemctl --user restart pipewire pipewire-pulse wireplumber
```

After updating, re-enable and verify:

```bash
/path/to/lhdc-build/lhdc-control.sh --enable
/path/to/lhdc-build/lhdc-control.sh --status
```

If the custom stack stops working after an update, use `--disable` first.
This restores the distribution binaries without deleting the custom
installation.

## Before publishing repositories publicly

Review all repositories and history for:

- Passwords, access tokens, private keys, and personal logs
- Bluetooth addresses and other identifying machine information
- Absolute home-directory paths
- Temporary test output and debug dumps
- Proprietary or vendor-supplied LHDC source

Check the licenses before publishing `liblhdcv3`, `liblhdcv5`, or copied AOSP
code. Do not redistribute code when its license does not permit it. A safer
public release is often:

1. Publish your PipeWire patches and helper scripts.
2. Document how users obtain compatible encoder libraries legally.
3. Keep vendor or license-restricted source repositories private.

The documentation repository currently contains machine-specific paths and a
Bluetooth address, so review or generalize those details before making it
public.

## Is LHDC better than AAC or SBC?

There is no universal winner, but LHDC can be the better choice for compatible
hardware:

| Codec | Strength |
|---|---|
| SBC | Most compatible and usually the safest fallback |
| AAC | Often very good quality, especially in Apple ecosystems |
| LHDC | Higher bitrate options, good detail, and potentially lower latency |

LHDC may use more power and may be more sensitive to interference. Audio
quality also depends on the earbuds, bitrate, signal conditions, and tuning.
The practical benefit here is that Linux can now use a codec your Buds
support, rather than being limited to SBC by the stock stack.

## Why LHDC does not provide native surround

Bluetooth A2DP normally carries two-channel audio. LHDC is a stereo codec; it
compresses left and right channels but does not define native 5.1 or 7.1
transport.

Virtual surround is still possible. Software can convert multichannel content
to binaural stereo before LHDC encodes it. The earbuds then receive stereo
audio containing spatial cues. This is different from sending six or eight
independent Bluetooth channels.

## Was it worth it?

Yes, for this hardware and goal:

- The Buds were limited to SBC on the stock Linux audio stack.
- The custom stack now negotiates and plays real audio through LHDC v5.
- Browser audio works through the Pulse bridge.
- The default integration is persistent and reversible.
- The project produced reproducible documentation and tested fallback paths.

The improvement is mainly technical capability and codec choice, not a
guarantee that every listener will hear a dramatic difference. If LHDC does
not sound better to you, SBC remains a valid fallback; the project is still
valuable because it removes the Linux-side limitation and gives you control
over the codec.
