#!/system/bin/sh
unlock_after_boot() {
  resetprop -w sys.boot_completed "" >/dev/null 2>&1
  pm set-user-restriction no_change_wifi_state 0 >/dev/null 2>&1
  rm -f /data/local/tmp/wifi_gate.log
}

unlock_after_boot &
