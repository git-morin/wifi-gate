# Wi-Fi Gate

Magisk module to allow Wi-Fi only when Magisk is active.

This aims at preventing an unrooted device (such as those with untethered roots) from receiving OTA updates that may push them out of the exploit's supported firmware version.

## Technicals

- Pins `Settings.Global.wifi_on` to `0` and sets the `no_change_wifi_state` user restriction, which Android enforces from disk.
- The Action button toggles Wi-Fi even while locked.
- Logs: `/data/local/tmp/wifi_gate.log`, logcat tag `wifi_gate`.
- An unclean shutdown leaves the switch usable until the next rooted boot.

## Install

Flash the zip from [Releases](../../releases/latest), then reboot.
