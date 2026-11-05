# shellcheck disable=SC2154
INSTALLED=/data/adb/modules/wifi_gate

if [ -n "$KSU" ] || [ -n "$APATCH" ]; then
  abort "! Wi-Fi Gate is Magisk only"
fi

if [ "${MAGISK_VER_CODE:-0}" -lt 26000 ]; then
  abort "! Wi-Fi Gate needs Magisk v26.0+ (found ${MAGISK_VER:-unknown})"
fi

ui_print "- Wi-Fi Gate: Wi-Fi only while Magisk is loaded"
set_perm_recursive "$MODPATH" 0 0 0755 0755

if [ -f "$INSTALLED/last_wifi_state" ]; then
  cp "$INSTALLED/last_wifi_state" "$MODPATH/last_wifi_state"
else
  case "$(cmd wifi status 2>/dev/null | head -1)" in
    "Wifi is disabled") echo off > "$MODPATH/last_wifi_state" ;;
    *)                  echo on  > "$MODPATH/last_wifi_state" ;;
  esac
fi

if settings put global wifi_on 0 2>/dev/null; then
  ui_print "- Saved Wi-Fi state set to off for the next boot"
fi

# A running older version re-locks from its own shutdown hook.
if [ ! -f "$INSTALLED/.session" ] && pm set-user-restriction no_change_wifi_state 1 2>/dev/null; then
  ui_print "- Wi-Fi switch locked until the next rooted boot"
  ui_print "  (Wi-Fi keeps its current state for now)"
fi
