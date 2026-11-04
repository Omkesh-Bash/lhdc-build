#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/lhdc-install}"

export LD_LIBRARY_PATH="$PREFIX/lib"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PATH="$PREFIX/bin:$PATH"
export SPA_PLUGIN_DIR="$PREFIX/lib/spa-0.2"
export SPA_DATA_DIR="$PREFIX/share/spa-0.2"
export PIPEWIRE_MODULE_DIR="$PREFIX/lib/pipewire-0.3"
export PIPEWIRE_CONFIG_DIR="$PREFIX/share/pipewire"

exec "$@"
