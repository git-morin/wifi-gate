# Wi-Fi Gate

<img src="assets/icon.svg" alt="Wi-Fi Gate icon" width="96">

Magisk module to allow Wi-Fi only when Magisk is active.

Some roots, like the semi-tethered ones, are lost on every reboot. Until you root again, the device runs stock and can download an update that patches the exploit. Wi-Fi Gate keeps Wi-Fi off during those unrooted boots, so the device stays on firmware the exploit supports.

## Technicals

- Pins `Settings.Global.wifi_on` to `0` and sets the `no_change_wifi_state` user restriction, which Android enforces from disk.
- Magisk v26.0+ only. Older Magisk, KernelSU and APatch are refused at install.
- Logs to `/data/local/tmp/wifi_gate.log`, rotated to `wifi_gate.log.old` past 64 KiB.
- On an unrooted boot, neither Settings nor `adb shell` can lift the restriction, since it needs `MANAGE_USERS`.
- Never locks ahead of a pending update. If `bootctl` reports a slot switch for the next boot, `update_engine` finished an update this boot, or the boot slots can't be read, shutdown leaves Wi-Fi normal instead. Otherwise the lock could land on firmware the exploit no longer supports, and only a factory reset would clear it.

### What it does not cover

Wi-Fi Gate blocks one path: Wi-Fi during an unrooted boot. **Don't rely on it alone to block unwanted updates.** These remain open:

- **Rooted sessions.** Wi-Fi works normally while rooted, and the module leaves the system updater alone. An A/B update can download and install to the inactive slot in the background, then take over at the next reboot, rooted or not. Wi-Fi Gate then skips the lock so the updated headset keeps working Wi-Fi, but it can't stop the update itself. **Block any updates / servers that hold them in your root session**.
- **Unclean shutdowns.** The switch is only locked at a clean shutdown. After a crash, a forced restart or a dead battery, the next unrooted boot still starts with Wi-Fi off, but anyone can turn it back on until you root again.
- **Other networks.** The restriction covers Wi-Fi only, not a USB Ethernet adapter or Bluetooth and USB tethering.
- **Factory reset.** Wiping `/data` erases the restriction and the saved state, and the setup wizard asks for Wi-Fi and updates before anything else.

## Install

1. Download the zip from [Releases](../../releases/latest).
2. In the Magisk app, go to *Modules* > *Install from storage* and pick it.
3. Reboot.

Installing the module locks the switch right away, so Wi-Fi keeps its current state until that reboot.

## Usage

There is nothing to configure. Once installed, every boot lands in one of two states:

- **Rooted boot:** the switch works normally, and Wi-Fi comes back as you left it at the last rooted shutdown.
- **Unrooted boot:** Wi-Fi is off and the toggle is locked. Neither Settings nor adb can turn it on.

What you can change:

- **Toggle Wi-Fi normally** during a rooted session. Your last choice is what returns on the next rooted boot, and an unrooted boot still starts off either way.
- **Action button**, under *Modules* > *Wi-Fi Gate* > *Action* in the Magisk app, is a safety valve for rooted devices: it toggles Wi-Fi and remembers the choice even while the switch is locked, such as before the first reboot after install. It runs as root, so it is no help on an unrooted boot.
- **Disable the module** in the Magisk app to hand Wi-Fi straight back to Android, with no reboot needed. Re-enabling it resumes the gate.
- **Uninstall** releases the switch the same way, with a fallback on the next boot in case the module was not running.
