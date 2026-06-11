#!/usr/bin/env bash
set -euo pipefail

# Optimize BlueZ for low-latency BLE HID keyboards.
# Run with sudo.

MAIN_CONF="/etc/bluetooth/main.conf"

[[ $EUID -ne 0 ]] && { echo "Run with sudo."; exit 1; }
[[ ! -f "$MAIN_CONF" ]] && { echo "$MAIN_CONF not found."; exit 1; }

cp "$MAIN_CONF" "${MAIN_CONF}.bak.$(date +%s)"
echo "Backed up $MAIN_CONF"

# Set LE connection params to match keyboard preferences (7.5ms interval).
# Robust against the keys shipping commented or absent: strip any existing
# occurrence (commented or not, any spacing) and re-insert under [LE].
set_le_key() {
    local key=$1 val=$2
    sed -i "/^[#[:space:]]*${key}[[:space:]]*=.*/d" "$MAIN_CONF"
    sed -i "/^\[LE\]/a ${key}=${val}" "$MAIN_CONF"
}
set_le_key MinConnectionInterval 6
set_le_key MaxConnectionInterval 6
set_le_key ConnectionLatency 0
set_le_key ConnectionSupervisionTimeout 400

# Enable FastConnectable if not already set.
if ! grep -q '^FastConnectable' "$MAIN_CONF"; then
    sed -i '/^\[General\]/a FastConnectable = true' "$MAIN_CONF"
fi

# Add reconnection policy if not configured.
if ! grep -q '^ReconnectAttempts' "$MAIN_CONF"; then
    sed -i '/^\[Policy\]/a ReconnectAttempts=7\nReconnectIntervals=1,2,4,8,16,32,64\nAutoEnable=true' "$MAIN_CONF"
fi

# Ensure GATT cache is always on.
if ! grep -q '^Cache' "$MAIN_CONF"; then
    sed -i '/^\[GATT\]/a Cache = always' "$MAIN_CONF"
fi

echo "Updated $MAIN_CONF"
echo "Restarting bluetooth..."
systemctl restart bluetooth
echo "Done. Changes:"
echo "  [LE] MinConnectionInterval=6, MaxConnectionInterval=6, ConnectionLatency=0, ConnectionSupervisionTimeout=400"
echo "  [General] FastConnectable = true"
echo "  [Policy] ReconnectAttempts=7, AutoEnable=true"
echo "  [GATT] Cache = always"
