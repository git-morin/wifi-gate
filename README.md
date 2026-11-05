# Wi-Fi Gate

Magisk module to allow Wi-Fi only when Magisk is active.

This aims at preventing an unrooted device (such as those with untethered roots) from receiving OTA updates that may push them out of the exploit's supported firmware version.

## Technicals

- Pins `Settings.Global.wifi_on` to `0` and sets the `no_change_wifi_state` user restriction, which Android enforces from disk.
- The Action button toggles Wi-Fi even while locked.
- An unclean shutdown leaves the switch usable until the next rooted boot.
  - This module should not be the only protection you have against unwarranted updates.

## Install

1. Download the zip from [Releases](../../releases/latest).
2. In the Magisk app, go to *Modules* > *Install from storage* and pick it.
3. Reboot.

Installing locks the switch right away, so Wi-Fi keeps its current state until that reboot.
