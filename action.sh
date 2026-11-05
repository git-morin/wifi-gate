#!/system/bin/sh
WIFI_GATE_DIR=$(dirname "$(readlink -f "$0")")
# shellcheck disable=SC1091
. "$WIFI_GATE_DIR/common.sh"

if module_off; then echo "Module is disabled or being removed"; exit 0; fi

unlock_wifi
if [ "$(wifi_now)" = on ]; then new=off; else new=on; fi
set_wifi "$new"
echo "$new" > "$STATE_FILE"
sleep "$WIFI_SETTLE_SEC"
persist_off
session_active || lock_wifi
say "Action: Wi-Fi $new"
cmd wifi status | head -1
