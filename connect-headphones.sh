#!/bin/bash
# Automated Bluetooth Headphones Connection Script
# Usage: ./connect-headphones.sh

set -euo pipefail

echo "🎵 Bluetooth Headphones Connection Tool"
echo "========================================"
echo

# Check if headphones address is provided
if [ $# -eq 0 ]; then
  HEADPHONE_NAME="realme"
else
  HEADPHONE_NAME="$1"
fi

echo "📱 Looking for $HEADPHONE_NAME headphones..."
echo

# Function to scan for devices
scan_devices() {
  echo "📡 Starting Bluetooth discovery scan (20 seconds)..."
  echo "   Make sure headphones are in PAIRING MODE (LED blinking!)"
  echo

  bluetoothctl scan on &
  SCAN_PID=$!

  for i in {1..20}; do
    printf "\r[%-20s] %d/20" "$(printf '#%.0s' $(seq 1 $((i/2))))" "$i"
    sleep 1
  done

  kill $SCAN_PID 2>/dev/null || true
  sleep 1

  echo
  echo
}

# Function to find device by name
find_device() {
  local search_term="$1"
  bluetoothctl devices | grep -i "$search_term" | head -1 | awk '{print $2}'
}

# Scan
scan_devices

# Find device
echo "🔍 Searching for device..."
DEVICE_ADDR=$(find_device "$HEADPHONE_NAME")

if [ -z "$DEVICE_ADDR" ]; then
  echo "❌ No device found with name containing '$HEADPHONE_NAME'"
  echo
  echo "📋 Available devices:"
  bluetoothctl devices
  echo
  echo "💡 Tip: Put your headphones in pairing mode first!"
  exit 1
fi

echo "✅ Found device: $DEVICE_ADDR"
echo

# Get device info
echo "📊 Device Information:"
bluetoothctl info "$DEVICE_ADDR" | grep -E "Name|Class|Paired|Connected"
echo

# Ask for confirmation
read -p "Proceed with pairing and connection? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo
echo "🔗 Pairing process starting..."

# Pair
echo "1️⃣  Pairing..."
bluetoothctl pair "$DEVICE_ADDR"
echo "✅ Pairing complete"

echo
echo "2️⃣  Trusting device..."
bluetoothctl trust "$DEVICE_ADDR"
echo "✅ Device trusted"

echo
echo "3️⃣  Connecting..."
bluetoothctl connect "$DEVICE_ADDR"

# Wait a moment for connection
sleep 2

# Verify connection
echo
echo "4️⃣  Verifying connection..."
CONNECTION_STATUS=$(bluetoothctl info "$DEVICE_ADDR" | grep "Connected:" | awk '{print $2}')

if [ "$CONNECTION_STATUS" = "yes" ]; then
  echo "✅ Connection successful!"
  echo
  echo "📊 Device Status:"
  bluetoothctl info "$DEVICE_ADDR" | grep -E "Name|Connected|Class|UUIDs"
  echo
  echo "🎵 Testing audio with PipeWire..."
  echo
  echo "Run this to monitor audio:"
  echo "  pw-top"
  echo
  echo "Your LHDC headphones are now connected! 🎉"
else
  echo "❌ Connection failed"
  echo
  echo "📊 Device Status:"
  bluetoothctl info "$DEVICE_ADDR" | grep -E "Name|Connected|Class"
  echo
  echo "💡 Troubleshooting tips:"
  echo "   • Ensure headphones battery is charged"
  echo "   • Keep headphones close to the computer"
  echo "   • Try restarting the headphones and put them back in pairing mode"
fi
