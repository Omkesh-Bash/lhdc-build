# LHDC Linux Build Notes

This repository contains the reproducible documentation and helper scripts for
using LHDC with PipeWire on Linux.

**Author / maintainer:** Omkesh Bash

This is a small, experimental, tech-focused side project rather than a
full-fledged product. It is shared so other Linux users with LHDC-capable
headphones can learn from the investigation and adapt the scripts.

Start with [REPRODUCIBLE_LHDC_BUILD.md](./REPRODUCIBLE_LHDC_BUILD.md). It
records the complete investigation, blockers, fixes, exact runtime procedure,
validation evidence, and cleanup steps.

The user-level default integration is controlled with
`./lhdc-control.sh --enable`, and the optional desktop entry is
`lhdc-control.desktop`.

See [VERSIONS_AND_PATHS.md](./VERSIONS_AND_PATHS.md) for the exact component
versions, installed files, service overrides, and runtime paths. Before
publishing, read [PUBLICATION_AUDIT.md](./PUBLICATION_AUDIT.md); it identifies
machine-specific information and license checks that must be completed first.

The PipeWire, WirePlumber, LHDC v3, and LHDC v5 source trees are separate
nested repositories and are intentionally not vendored here.

## Public setup: replace the placeholders

The public scripts intentionally do not contain a device MAC address or a
user-specific home path.

Set your Buds/headphones address for the current shell:

```bash
export LHDC_DEVICE_ADDRESS='AA:BB:CC:DD:EE:FF'
```

Find it with:

```bash
bluetoothctl devices
```

Install the custom build under:

```text
$HOME/lhdc-install
```

If you use another install directory, update the `PREFIX` value in
`run-lhdc-env.sh` and adjust the documented service template path, or install
to `$HOME/lhdc-install` as shown. Then enable the user-level default:

```bash
./lhdc-control.sh --enable
./lhdc-control.sh --status
```

The tracked systemd templates use `%h`, so they automatically resolve to the
current user's home directory when copied by `lhdc-control.sh`.

The original helper scripts and documentation are released under the
[MIT License](./LICENSE). This applies only to original files in this root
repository; upstream PipeWire, WirePlumber, and encoder sources retain their
own licenses and notices.
