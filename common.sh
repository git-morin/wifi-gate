TAG=wifi_gate
LOG=/data/local/tmp/wifi_gate.log
LOG_MAX_BYTES=65536
# shellcheck disable=SC2034
SETTINGS_DIR=/data/system/users/0
RESTRICTION=no_change_wifi_state
# shellcheck disable=SC2034
BUSYBOX=/data/adb/magisk/busybox
WIFI_GATE_DIR=${WIFI_GATE_DIR:-/data/adb/modules/wifi_gate}
STATE_FILE=$WIFI_GATE_DIR/last_wifi_state
SESSION_FILE=$WIFI_GATE_DIR/.session
# shellcheck disable=SC2034
WIFI_SETTLE_SEC=2
# shellcheck disable=SC2034
SERVICE_SETTLE_SEC=3

INOTIFYD_CREATE=n
INOTIFYD_DELETE=d
# shellcheck disable=SC2034
WATCH_SETTINGS_SAVED=y
# shellcheck disable=SC2034
WATCH_MODULE_FLAGS=$INOTIFYD_CREATE$INOTIFYD_DELETE

say() {
  /system/bin/log -t "$TAG" "$*" 2>/dev/null
  if [ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt "$LOG_MAX_BYTES" ]; then
    mv -f "$LOG" "$LOG.old"
  fi
  echo "$(date '+%F %T') $*" >> "$LOG"
  echo "$*"
}

magisk_loaded() {
  [ "$(id -u)" = 0 ] || return 1
  ctx=$(tr -d '\0' < /proc/self/attr/current 2>/dev/null)
  [ "$ctx" = "u:r:magisk:s0" ] || return 1
  for m in magisk /product/bin/magisk /system/bin/magisk /debug_ramdisk/magisk; do
    "$m" -V >/dev/null 2>&1 && return 0
  done
  return 1
}

wait_for_boot()     { resetprop -w sys.boot_completed "" >/dev/null 2>&1; }
wait_for_shutdown() { resetprop -w sys.shutdown.requested "" >/dev/null 2>&1; }

boot_id()        { cat /proc/sys/kernel/random/boot_id; }
session_active() { [ "$(cat "$SESSION_FILE" 2>/dev/null)" = "$(boot_id)" ]; }
module_off()     { [ -f "$WIFI_GATE_DIR/disable" ] || [ -f "$WIFI_GATE_DIR/remove" ]; }

lock_wifi()   { pm set-user-restriction "$RESTRICTION" 1 >/dev/null 2>&1; }
unlock_wifi() { pm set-user-restriction "$RESTRICTION" 0 >/dev/null 2>&1; }

set_wifi() {
  case $1 in
    on)  cmd wifi set-wifi-enabled enabled ;;
    off) cmd wifi set-wifi-enabled disabled ;;
  esac >/dev/null 2>&1
}

persist_off() {
  [ "$(settings get global wifi_on)" = 0 ] || settings put global wifi_on 0
}

wifi_now() {
  case "$(cmd wifi status 2>/dev/null | head -1)" in
    "Wifi is enabled")  echo on ;;
    "Wifi is disabled") echo off ;;
  esac
}

remembered_state() {
  case "$(cat "$STATE_FILE" 2>/dev/null)" in
    off) echo off ;;
    *)   echo on ;;
  esac
}

record_state() {
  s=$(wifi_now)
  [ -n "$s" ] && echo "$s" > "$STATE_FILE"
}

release_wifi() {
  unlock_wifi
  if [ "$(wifi_now)" = on ]; then settings put global wifi_on 1; else persist_off; fi
}
