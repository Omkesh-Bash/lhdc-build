# Versions and Path Map

## Verified versions

These are the versions used by the current working setup:

| Component | Version or commit |
|---|---|
| Custom PipeWire | 1.7.0 |
| Custom WirePlumber | 0.5.19 |
| System PipeWire baseline | 1.0.5 |
| System WirePlumber baseline | 0.4.17 |
| BlueZ | 5.72 |
| Linux kernel | 6.8.0-147-generic |
| Bluetooth adapter | your Bluetooth adapter |
| Verified codec | LHDC v5 (`lhdc_v5`) |
| LHDC v3 codec ID | `0x4c33` |
| LHDC v5 codec ID | `0x4c35` |

Verify custom versions with the runtime environment:

```bash
cd $HOME/lhdc-build
./run-lhdc-env.sh $HOME/lhdc-install/bin/pipewire --version
./run-lhdc-env.sh $HOME/lhdc-install/bin/wireplumber --version
```

Calling the custom binaries directly without the environment wrapper can
produce missing-library or symbol errors. The wrapper is part of the runtime,
not just a convenience.

## Custom installation paths

The custom prefix is:

```text
$HOME/lhdc-install
```

Important installed files:

```text
bin/pipewire
bin/pipewire-pulse
bin/wireplumber
bin/pw-dump
lib/liblhdcv5.so
lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so
lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc-v3.so
share/pipewire/pipewire.conf
share/pipewire/pipewire-pulse.conf
share/wireplumber/wireplumber.conf.d/10-lhdc.conf
```

## User-level service overrides

These are the files that select the custom stack as the default:

```text
~/.config/systemd/user/pipewire.service.d/10-lhdc.conf
~/.config/systemd/user/pipewire-pulse.service.d/10-lhdc.conf
~/.config/systemd/user/wireplumber.service.d/10-lhdc.conf
```

The version-controlled templates are under:

```text
systemd-user/pipewire.service.d/10-lhdc.conf
systemd-user/pipewire-pulse.service.d/10-lhdc.conf
systemd-user/wireplumber.service.d/10-lhdc.conf
```

These overrides replace service `ExecStart` commands and set the custom
library, SPA, module, and configuration paths. They do **not** replace
distribution files under `/usr/bin`, `/usr/lib`, or `/etc`.

## Runtime environment paths

`run-lhdc-env.sh` and the systemd drop-ins use:

```text
LD_LIBRARY_PATH=$PREFIX/lib
SPA_PLUGIN_DIR=$PREFIX/lib/spa-0.2
SPA_DATA_DIR=$PREFIX/share/spa-0.2
PIPEWIRE_MODULE_DIR=$PREFIX/lib/pipewire-0.3
PIPEWIRE_CONFIG_DIR=$PREFIX/share/pipewire
WIREPLUMBER_MODULE_DIR=$PREFIX/lib/wireplumber-0.5
WIREPLUMBER_CONFIG_DIR=$PREFIX/share/wireplumber
WIREPLUMBER_DATA_DIR=$PREFIX/share/wireplumber
```

## Change or rollback

Reinstall/update the custom prefix, then restart:

```bash
$HOME/lhdc-build/lhdc-control.sh --enable
```

Restore distribution-managed PipeWire and WirePlumber:

```bash
$HOME/lhdc-build/lhdc-control.sh --disable
```

Check the result:

```bash
$HOME/lhdc-build/lhdc-control.sh --status
```
