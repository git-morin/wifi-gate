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
  reason=$(pending_update)
  if [ -n "$reason" ]; then
    boot_id > "$RELEASED_FILE"
    release_wifi
    say "Shutdown with a pending update ($reason): Wi-Fi left normal, not locked"
    return
  fi
  record_state
  lock_wifi
  persist_off
  say "Shutdown ($(getprop sys.shutdown.requested)): Wi-Fi was $(remembered_state), switch locked"
}

open_session() {
  if ! wait_for_framework; then
    say "Rooted session ($1): framework not up after ${FRAMEWORK_TIMEOUT_SEC}s, switch left as is"
    return 1
  fi
  want=$(remembered_state)
  n=0
  while unlock_wifi; wifi_locked; do
    n=$((n + 1))
    if [ "$n" -ge "$UNLOCK_ATTEMPTS" ]; then
      say "Rooted session ($1): could not unlock the Wi-Fi switch"
      return 1
    fi
    sleep 1
  done
  set_wifi "$want"
  sleep "$WIFI_SETTLE_SEC"
  persist_off
  say "Rooted session ($1): Wi-Fi unlocked, restored to $want"
}

reopen_on_framework_restart() {
  pid=$1
  [ -n "$pid" ] || return
  while :; do
    resetprop -w init.svc_debug_pid.zygote "$pid" >/dev/null 2>&1
    new=$(zygote_pid)
    [ -n "$new" ] && [ "$new" != "$pid" ] || { sleep 1; continue; }
    pid=$new
    sleep "$SERVICE_SETTLE_SEC"
    module_off || open_session "framework restart"
  done
}

wait_for_boot
zygote=$(zygote_pid)
sleep "$SERVICE_SETTLE_SEC"

if ! magisk_loaded; then
  say "Magisk not loaded: Wi-Fi off and locked"
  unlock_wifi; set_wifi off; persist_off; lock_wifi
  exit 0
fi

boot_id > "$SESSION_FILE"
reopen_on_framework_restart "$zygote" &
open_session boot

lock_on_clean_shutdown &

exec "$BUSYBOX" inotifyd "$WIFI_GATE_DIR/on_event.sh" "$SETTINGS_DIR:$WATCH_SETTINGS_SAVED" "$WIFI_GATE_DIR:$WATCH_MODULE_FLAGS"
