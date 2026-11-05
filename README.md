# LHDC Linux Build Notes

This repository contains the reproducible documentation and helper scripts for
using LHDC with PipeWire on Linux.

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
