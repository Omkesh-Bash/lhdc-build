# Public Release and Licensing Audit

This is an engineering checklist, not legal advice. A lawyer or the
copyright holders should make the final publication decision.

## What this repository currently contains

The GitHub repository `Omkesh-Bash/lhdc-build` tracks documentation, shell
helpers, desktop metadata, and systemd drop-in templates. The large
`pipewire`, `wireplumber`, `liblhdcv3`, and `liblhdcv5` directories are
separate local repositories and are excluded from the root repository by
`.gitignore`; they are not currently uploaded as root-repository contents.

## License findings

The local component sources identify these licenses:

- PipeWire: MIT for source files, with exceptions described in its `LICENSE`
  and `COPYING` files.
- WirePlumber: MIT.
- LHDC v5 source: Apache License 2.0.
- LHDC v3 source: Apache License 2.0, with a libFLAC-derived file covered by
  the BSD-style notice in `liblhdcv3/NOTICE`.

Those licenses generally permit redistribution when their notices and license
conditions are preserved. They do **not** automatically grant permission to
redistribute every vendor LHDC implementation, proprietary binary, trademark,
patent, or branding asset. Keep the upstream license and notice files with
any source or binary distribution, and verify the exact upstream repository
history before redistributing it.

The root documentation/helper repository has no root `LICENSE` file yet.
Without one, public visibility does not grant others permission to reuse the
original scripts and documentation. Before making it public, either:

1. Add a license you are willing to grant for your original files; or
2. Keep the repository private and grant permission separately.

Do not add a license to third-party source as though you authored it.

## Sensitive information review

No passwords, access tokens, private keys, or common cloud-secret patterns
were found in the tracked root files.

The public-facing files now use placeholders instead of the author's real
Bluetooth address and home path:

- `$HOME`, `AA:BB:CC:DD:EE:FF`, and `/tmp` test directories are intentional
  generic examples, not credentials or personal identifiers.

Recommended public replacements:

```text
$HOME/lhdc-install
$HOME/path/to/lhdc-build
AA:BB:CC:DD:EE:FF
YOUR_DEVICE_ADDRESS
```

For a reusable public helper, set the address outside the repository:

```bash
export LHDC_DEVICE_ADDRESS='AA:BB:CC:DD:EE:FF'
```

Then run the status/control commands. Do not commit a user's real address as
the default.

## History check

Before making the repository public, scan the complete Git history, not only
the current files:

```bash
git log --all --stat
git grep -n -I -E \
  'gho_|github_pat_|BEGIN .*PRIVATE KEY|password[[:space:]]*[:=]|token[[:space:]]*[:=]' \
  $(git rev-list --all)
```

If a secret was ever committed, rotate/revoke it first. Removing it from the
latest commit is not sufficient; rewrite history only after preserving a
backup and understanding the impact on existing clones.

## Recommendation

The root repository is suitable for a small public side-project release:
credentials are absent, personal defaults are generalized, and the original
scripts/docs now have an MIT license. Before publishing any nested LHDC source
or binaries, separately confirm its upstream license and that it is not a
proprietary vendor implementation.
