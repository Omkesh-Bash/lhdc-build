#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
USER_SYSTEMD="$HOME/.config/systemd/user"
DEVICE_ADDRESS="${LHDC_DEVICE_ADDRESS:-}"

install_overrides() {
  mkdir -p \
    "$USER_SYSTEMD/pipewire.service.d" \
    "$USER_SYSTEMD/pipewire-pulse.service.d" \
    "$USER_SYSTEMD/wireplumber.service.d"
  cp "$ROOT/systemd-user/pipewire.service.d/10-lhdc.conf" \
    "$USER_SYSTEMD/pipewire.service.d/10-lhdc.conf"
  cp "$ROOT/systemd-user/pipewire-pulse.service.d/10-lhdc.conf" \
    "$USER_SYSTEMD/pipewire-pulse.service.d/10-lhdc.conf"
  cp "$ROOT/systemd-user/wireplumber.service.d/10-lhdc.conf" \
    "$USER_SYSTEMD/wireplumber.service.d/10-lhdc.conf"
}

enable_lhdc() {
  install_overrides
  systemctl --user daemon-reload
  if [[ -n "$DEVICE_ADDRESS" ]]; then
    bluetoothctl disconnect "$DEVICE_ADDRESS" >/dev/null 2>&1 || true
  fi
  systemctl --user restart pipewire pipewire-pulse wireplumber
  if [[ -n "$DEVICE_ADDRESS" ]]; then
    bluetoothctl connect "$DEVICE_ADDRESS" >/dev/null 2>&1 || true
  fi
  sleep 5
  "$ROOT/lhdc-status.sh" || true
}

disable_lhdc() {
  rm -f \
    "$USER_SYSTEMD/pipewire.service.d/10-lhdc.conf" \
    "$USER_SYSTEMD/pipewire-pulse.service.d/10-lhdc.conf" \
    "$USER_SYSTEMD/wireplumber.service.d/10-lhdc.conf"
  rmdir --ignore-fail-on-non-empty \
    "$USER_SYSTEMD/pipewire.service.d" \
    "$USER_SYSTEMD/pipewire-pulse.service.d" \
    "$USER_SYSTEMD/wireplumber.service.d" 2>/dev/null || true
  systemctl --user daemon-reload
  systemctl --user restart pipewire pipewire-pulse wireplumber
  echo "System PipeWire/WirePlumber restored."
}

gui() {
  command -v zenity >/dev/null 2>&1 || {
    echo "Zenity is not installed; use --enable, --disable, or --status." >&2
    exit 1
  }
  local choice
  choice="$(zenity --list --title='LHDC audio' --text='Choose an audio mode' \
    --column='Action' 'Enable LHDC default' 'Show codec status' 'Restore system audio' \
    --height=240 --width=420 2>/dev/null || true)"
  case "$choice" in
    'Enable LHDC default') enable_lhdc ;;
    'Show codec status') "$ROOT/lhdc-status.sh" --gui ;;
    'Restore system audio') disable_lhdc ;;
  esac
}

case "${1:-}" in
  --enable) enable_lhdc ;;
  --disable) disable_lhdc ;;
  --status) "$ROOT/lhdc-status.sh" ;;
  --gui) gui ;;
  *)
    printf 'Usage: %s --enable|--disable|--status|--gui\n' "$0"
    exit 2
    ;;
esac
