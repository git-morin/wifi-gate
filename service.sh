#!/system/bin/sh
WIFI_GATE_DIR=$(dirname "$(readlink -f "$0")")
# shellcheck disable=SC1091
. "$WIFI_GATE_DIR/common.sh"

lock_on_clean_shutdown() {
  wait_for_shutdown
  if module_off; then
    release_wifi
    say "Shutdown with module disabled/removed: Wi-Fi left normal"
    return
  fi
  record_state
  lock_wifi
  persist_off
  say "Shutdown ($(getprop sys.shutdown.requested)): Wi-Fi was $(remembered_state), switch locked"
}

wait_for_boot
sleep "$SERVICE_SETTLE_SEC"

if ! magisk_loaded; then
  say "Magisk not loaded: Wi-Fi off and locked"
  unlock_wifi; set_wifi off; persist_off; lock_wifi
  exit 0
fi

boot_id > "$SESSION_FILE"
want=$(remembered_state)
unlock_wifi
set_wifi "$want"
sleep "$WIFI_SETTLE_SEC"
persist_off
say "Rooted session: Wi-Fi unlocked, restored to $want"

lock_on_clean_shutdown &

exec "$(busybox_bin)" inotifyd "$WIFI_GATE_DIR/on_event.sh" "$SETTINGS_DIR:$WATCH_SETTINGS_SAVED" "$WIFI_GATE_DIR:$WATCH_MODULE_FLAGS"
