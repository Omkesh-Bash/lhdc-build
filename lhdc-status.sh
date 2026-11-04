#!/usr/bin/env bash
set -euo pipefail

DEVICE_ADDRESS="${LHDC_DEVICE_ADDRESS:-AA:BB:CC:DD:EE:FF}"
WATCH=false
GUI=false

usage() {
  printf 'Usage: %s [--watch] [--gui]\n' "$0"
}

for arg in "$@"; do
  case "$arg" in
    --watch) WATCH=true ;;
    --gui) GUI=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

print_status() {
  local dump
  if ! dump="$(pw-dump 2>/dev/null)"; then
    printf 'PipeWire is not reachable.\n' >&2
    return 1
  fi

  local rows
  rows="$(printf '%s' "$dump" | perl -0777 -ne '
    while (/"info"\s*:\s*\{(.*?)\n\s*\}\s*,\s*"params"/sg) {
      my $info = $1;
      next unless $info =~ /"api\.bluez5\.address"\s*:\s*"'$DEVICE_ADDRESS'"/;
      next unless $info =~ /"api\.bluez5\.codec"\s*:\s*"([^"]+)"/;
      my $codec = $1;
      my ($profile) = $info =~ /"api\.bluez5\.profile"\s*:\s*"([^"]+)"/;
      my ($node) = $info =~ /"node\.name"\s*:\s*"([^"]+)"/;
      print join("\t", $codec, ($profile // "unknown"), ($node // "unknown")), "\n";
      last;
    }
  ' | head -1)"

  if [[ -z "$rows" ]]; then
    printf 'No active Bluetooth audio codec found for %s.\n' "$DEVICE_ADDRESS"
    return 0
  fi

  local codec profile node
  IFS=$'\t' read -r codec profile node <<<"$rows"
  local label="${codec//_/ }"
  printf 'Device: %s\nCodec: %s\nProfile: %s\nNode: %s\n' \
    "$DEVICE_ADDRESS" "$label" "$profile" "$node"

  if [[ "$GUI" == true ]]; then
    zenity --info --title="Bluetooth audio codec" \
      --text="Device: $DEVICE_ADDRESS\nCodec: $label\nProfile: $profile" \
      2>/dev/null || true
  fi
}

if [[ "$WATCH" == true ]]; then
  while true; do
    clear
    date '+%Y-%m-%d %H:%M:%S'
    print_status || true
    sleep 1
  done
else
  print_status
fi
