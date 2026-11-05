# Complete LHDC PipeWire Build Procedure

## Step 1: Clone Repositories

### Clone Latest PipeWire
```bash
# Clone from official PipeWire repository (main branch = latest development)
git clone https://github.com/PipeWire/pipewire.git
cd pipewire
```

### Clone/Build liblhdcv5
```bash
# If not already present, clone or build liblhdcv5
# (In your workspace, it's already built in $HOME/lhdc-install)
git clone https://github.com/usbmuxd/liblhdc  # or your preferred source
cd liblhdc
# Follow specific LHDC build instructions (may require AOSP/NDK setup)
```

---

## Step 2: Ensure liblhdcv5 is Installed Locally

```bash
# Your liblhdcv5.so must be in a location pkg-config can find
# Verify it's present:
ls -lah $HOME/lhdc-install/lib/liblhdcv5.so

# Verify pkg-config can find it:
export PKG_CONFIG_PATH="$HOME/lhdc-install/lib/pkgconfig:$PKG_CONFIG_PATH"
pkg-config --modversion lhdcv5
# Expected output: something like "1.0"
```

---

## Step 3: Configure PipeWire with Meson

```bash
cd /path/to/pipewire

# Set the local prefix
PREFIX="$HOME/lhdc-install"
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"

# Run Meson setup with LHDC codec enabled
meson setup build-lhdc \
  --prefix="$PREFIX" \
  -Dbluez5-codec-lhdc=enabled \
  -Dsession-managers=[] \
  -Dtests=enabled \
  -Ddocs=disabled
```

### Meson Options Explained
| Option | Value | Reason |
|--------|-------|--------|
| `--prefix` | `$HOME/lhdc-install` | Local sandbox—no system changes |
| `-Dbluez5-codec-lhdc=enabled` | `enabled` | **Compile LHDC codec support** |
| `-Dsession-managers=[]` | `[]` | Skip WirePlumber (avoid external downloads) |
| `-Dtests=enabled` | `enabled` | Include test binaries |
| `-Ddocs=disabled` | `disabled` | Skip documentation (saves time) |

---

## Step 4: Build with Limited Parallelism

```bash
# For 4GB RAM systems, use -j2
cd build-lhdc
ninja -j2

# For 8GB+ RAM, you can use -j4 or -j$(nproc)
# For 2GB RAM systems, use -j1 to be safe
```

### Build Output Indicators
- ✅ `libspa-codec-bluez5-lhdc.so` : Codec plugin compiled successfully
- ✅ `libpipewire-0.3.so` : Core library ready
- ✅ `pipewire` (daemon) : Main service compiled

---

## Step 5: Install to Local Prefix

```bash
# NO sudo needed—this installs to your local prefix only
ninja install

# Verify installation
ls -lah $HOME/lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so
```

---

## Step 6: Create Environment Wrapper

Save this as `run-lhdc-env.sh` in your build directory:

```bash
#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/lhdc-install}"
SYSTEM_MULTIARCH="/usr/lib/x86_64-linux-gnu"

export LD_LIBRARY_PATH="$PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export SPA_PLUGIN_DIR="$PREFIX/lib/spa-0.2:$SYSTEM_MULTIARCH/spa-0.2:/usr/lib/spa-0.2"
export SPA_DATA_DIR="$PREFIX/share/spa-0.2:/usr/share/spa-0.2"
export PIPEWIRE_MODULE_DIR="$PREFIX/lib/pipewire-0.3:$SYSTEM_MULTIARCH/pipewire-0.3:/usr/lib/pipewire-0.3"
export PIPEWIRE_CONFIG_DIR="$PREFIX/share/pipewire"

exec "$@"
```

Make it executable:
```bash
chmod +x run-lhdc-env.sh
```

---

## Step 7: Test LHDC Codec

```bash
# Test codec plugin loads
./run-lhdc-env.sh ldd $HOME/lhdc-install/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so

# Expected output includes:
# liblhdcv5.so => $HOME/lhdc-install/lib/liblhdcv5.so (0x...)
```

---

## Step 8: Test PipeWire Startup

```bash
# Create isolated runtime to avoid conflicts with system PipeWire
CUSTOM_RUNTIME_DIR="/tmp/lhdc-pw-test-$$"
mkdir -p "$CUSTOM_RUNTIME_DIR"
export XDG_RUNTIME_DIR="$CUSTOM_RUNTIME_DIR"

# Start the custom PipeWire daemon
./run-lhdc-env.sh $HOME/lhdc-install/bin/pipewire &
PW_PID=$!

sleep 2

# Check if running
if ps -p $PW_PID > /dev/null; then
  echo "✅ PipeWire started successfully"
  ./run-lhdc-env.sh $HOME/lhdc-install/bin/pw-cli info core
else
  echo "❌ PipeWire failed to start"
fi

# Cleanup
kill $PW_PID 2>/dev/null || true
rm -rf "$CUSTOM_RUNTIME_DIR"
```

---

## Troubleshooting Build Issues

### Compilation Error: "bluez5-codec-lhdc" not found
- **Cause**: liblhdcv5 not installed to local prefix
- **Fix**:
  ```bash
  export PKG_CONFIG_PATH="$HOME/lhdc-install/lib/pkgconfig:$PKG_CONFIG_PATH"
  pkg-config --cflags --libs lhdcv5  # Should print paths
  ```

### Meson Error: "Unknown option 'bluez5-codec-lhdc'"
- **Cause**: PipeWire version too old or LHDC support not available
- **Fix**: Use latest PipeWire from GitHub:
  ```bash
  git clone https://github.com/PipeWire/pipewire.git  # Pulls main/latest
  ```

### Build Hangs or System Freezes
- **Cause**: Parallelism too high for available RAM
- **Fix**: Use lower -j value:
  ```bash
  ninja -j1  # Use 1 job instead of 2
  ```

### Library Not Found: "liblhdcv5.so"
- **Cause**: LD_LIBRARY_PATH not set when running tools
- **Fix**: Always use the wrapper:
  ```bash
  ./run-lhdc-env.sh $HOME/lhdc-install/bin/<command>
  # NOT: $HOME/lhdc-install/bin/<command>  # This will fail
  ```

---

## Performance Notes

| System | Recommended `-j` | Estimated Time |
|--------|-----------------|-----------------|
| 2GB RAM | `-j1` | 45–60 min |
| 4GB RAM | `-j2` | 25–35 min |
| 8GB+ RAM | `-j4` or `-j$(nproc)` | 10–15 min |

Your system: **4GB RAM → use `-j2`** ✅

---

## Cleanup & Disk Space

After successful build:
```bash
# Clean build artifacts (keep binaries in prefix)
rm -rf pipewire/build-lhdc

# Disk usage of local installation
du -sh $HOME/lhdc-install
# Typical: 50–150 MB depending on options

# Reclaim space if needed
rm -rf $HOME/lhdc-install  # Completely remove custom build
```

---

## Full Command-Line Script (Copy & Paste)

```bash
#!/bin/bash
set -euxo pipefail

PREFIX="$HOME/lhdc-install"
REPO_DIR="$PWD"

# 1. Clone PipeWire (if not already present)
if [ ! -d pipewire ]; then
  git clone https://github.com/PipeWire/pipewire.git
fi

cd pipewire

# 2. Configure with Meson
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
meson setup build-lhdc \
  --prefix="$PREFIX" \
  -Dbluez5-codec-lhdc=enabled \
  -Dsession-managers=[] \
  -Dtests=enabled \
  -Ddocs=disabled

# 3. Compile with -j2 for 4GB RAM
cd build-lhdc
ninja -j2

# 4. Install locally (no sudo!)
ninja install

# 5. Verify
echo "✅ Build complete. Installed to: $PREFIX"
ls -lah "$PREFIX/lib/spa-0.2/bluez5/libspa-codec-bluez5-lhdc.so"
```

Save as `build-lhdc.sh`, then run:
```bash
chmod +x build-lhdc.sh
./build-lhdc.sh
```

---

**Last Updated**: 2026-07-10  
**System**: Linux Mint 22.3 (Ubuntu 24.04)  
**PipeWire Version**: 1.7.0  
**LHDC Support**: ✅ Enabled
