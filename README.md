# Wi-Fi Gate

Magisk module to allow Wi-Fi only when Magisk is active.

This aims at preventing an unrooted device (such as those with untethered roots) from receiving OTA updates that may push them out of the exploit's supported firmware version.

## Technicals

- Pins `Settings.Global.wifi_on` to `0` and sets the `no_change_wifi_state` user restriction, which Android enforces from disk.
- Magisk only. KernelSU and APatch are refused at install.
- An unclean shutdown leaves the switch usable until the next rooted boot.
  - This module should not be the only protection you have against unwarranted updates.

## Install

1. Download the zip from [Releases](../../releases/latest).
2. In the Magisk app, go to *Modules* > *Install from storage* and pick it.
3. Reboot.

Installing locks the switch right away, so Wi-Fi keeps its current state until that reboot.

## Usage

There is nothing to configure. Once installed, every boot lands in one of two states:

- **Rooted boot:** the switch works normally, and Wi-Fi comes back as you left it at the last rooted shutdown.
- **Unrooted boot:** Wi-Fi is off and the toggle is locked. Neither Settings nor adb can turn it on.

What you can change:

- **Toggle Wi-Fi normally** during a rooted session. Your last choice is what returns on the next rooted boot, and an unrooted boot still starts off either way.
- **Action button**, under *Modules* > *Wi-Fi Gate* > *Action* in the Magisk app, is a safety valve for rooted devices: it toggles Wi-Fi and remembers the choice even while the switch is locked, such as before the first reboot after install. It runs as root, so it is no help on an unrooted boot.
- **Disable the module** in the Magisk app to hand Wi-Fi straight back to Android, with no reboot needed. Re-enabling it resumes the gate.
- **Uninstall** releases the switch the same way, with a fallback on the next boot in case the module was not running.
