#!/system/bin/sh
WIFI_GATE_DIR=$(dirname "$(readlink -f "$0")")
. "$WIFI_GATE_DIR/common.sh"

event=$1
watched_dir=$2
filename=$3

if [ "$watched_dir" = "$WIFI_GATE_DIR" ]; then
  case $filename in
    disable|remove)
      if [ "$event" = "$INOTIFYD_CREATE" ]; then
        release_wifi
        say "Module $filename requested: Wi-Fi unlocked and back to normal"
      elif ! module_off; then
        persist_off
        say "Module re-enabled: saved Wi-Fi state off again"
      fi ;;
  esac
  exit 0
fi

[ "$filename" = settings_global.xml ] || exit 0
module_off && exit 0

saved=$(settings get global wifi_on)
if [ "$saved" != 0 ]; then
  echo on > "$STATE_FILE"
  settings put global wifi_on 0
  say "Saved Wi-Fi state was $saved: reset to 0"
else
  sleep "$WIFI_SETTLE_SEC"
  record_state
fi
