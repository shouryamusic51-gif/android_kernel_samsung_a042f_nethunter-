# Kali NetHunter Kernel for Samsung Galaxy A04e (SM-A042F)

A custom **Linux 4.19.191** Kali NetHunter kernel for the **Samsung Galaxy A04e (`SM-A042F`, MediaTek MT6765 / Helio P35)**, compiled natively on ARM64 with **Clang 11.0.1** and **LLD 11.0.1**.

> **Tested Firmware:** `A042FXXSCEYG2` (`4.19.191-28581296-abA042FXXSCEYG2`)
> **Disclaimer:** Flashing custom kernels carries risk. Always back up your stock `boot` partition before flashing anything.

---

## Features & Supported Hardware

### Core System & Vendor Compatibility
- **100% Stock Vendor Module Compatibility:** Keeps `CONFIG_MODVERSIONS=y` and stock `LOCALVERSION` (`-28581296-abA042FXXSCEYG2`) so all stock `/vendor/lib/modules/*.ko` (`wmt_drv.ko`, `wlan_drv_gen4m.ko`, `bt_drv_connac1x.ko`, `gps_drv.ko`, `fmradio_drv_mt6631.ko`) load cleanly at boot.
- **Built-in Wi-Fi, Bluetooth, GPS, FM Radio, Camera, and Audio:** All work out of the box.
- **Root Preserved:** Repacked `boot.img` retains Magisk root.

### Kali NetHunter Features
- **Wi-Fi Monitor Mode & Packet Injection:** Includes `mac80211` injection patch (`add-wifi-injection-4.19.patch`).
- **USB Gadgets (ConfigFS):**
  - HID Keyboard & Mouse (`CONFIG_USB_CONFIGFS_F_HID=y`) for BadUSB / DuckHunter attacks (`/dev/hidg0`, `/dev/hidg1`).
  - USB Mass Storage (`CONFIG_USB_CONFIGFS_MASS_STORAGE=y`) for DriveDroid / ISO mounting.
- **Networking & Tunneling:** `CONFIG_TUN=y` (`/dev/tun`) for VPNs and MITM tools.

### Built-in External USB Wi-Fi Drivers (OTG)
No separate `.ko` module loading required — all drivers are compiled directly into `Image`:

| Chipset / Driver | Kernel Option | Example Adapters |
| :--- | :--- | :--- |
| Realtek `RTL8812AU / 8821AU / 8814AU` | `CONFIG_88XXAU=y` | ALFA AWUS036ACH, AWUS036ACS |
| Atheros `AR9271` | `CONFIG_ATH9K_HTC=y` | TP-Link TL-WN722N v1, ALFA AWUS036NHA |
| MediaTek `MT7601U` | `CONFIG_MT7601U=y` | Generic MT7601U USB Wi-Fi dongles |
| Realtek `RTL8187` | `CONFIG_RTL8187=y` | ALFA AWUS036H |

---

## Before You Flash (Mandatory Backup)

Back up your current working `boot` partition in a rooted Android Shell (`su`) before flashing:

```bash
dd if=/dev/block/by-name/boot of=/sdcard/stock-boot-backup.img
```

Keep a copy of `stock-boot-backup.img` on your internal storage / SD card so you can restore it anytime in TWRP if needed.

---

## Flashing Instructions

Download the files from the **Releases** tab of this repository.

### Method 1: Flash `nh-boot-v5.img` Directly (TWRP)
*(Best if you are on matching `A042FXXSCEYG2` firmware with Magisk)*
1. Boot into **TWRP** (`Volume Up + Power` with USB cable connected).
2. Tap **Install** -> **Install Image** (bottom right).
3. Select `nh-boot-v5.img` -> choose **Boot** -> swipe to flash.
4. Reboot System.

### Method 2: Repack `nh_Image_v5` into Your Own Stock `boot.img` (Recommended for Other Builds)
*(Preserves your exact firmware's ramdisk, DTB, and Magisk)*
```bash
mkdir -p /data/local/tmp/repack && cd /data/local/tmp/repack
cp /sdcard/stock-boot-backup.img .
/data/adb/magisk/magiskboot unpack stock-boot-backup.img
cp /sdcard/nh_Image_v5 kernel
/data/adb/magisk/magiskboot repack stock-boot-backup.img /sdcard/my-nethunter-boot.img
```
Then flash `/sdcard/my-nethunter-boot.img` to **Boot** in TWRP (or via `dd if=/sdcard/my-nethunter-boot.img of=/dev/block/by-name/boot && sync && reboot`).

---

## Verifying Everything After Boot

Run these commands in **Kali NetHunter** or **Android Shell (`su`)**:

```bash
# 1. Confirm custom kernel build date and version
cat /proc/version

# 2. Confirm stock vendor modules loaded (built-in Wi-Fi & Bluetooth)
lsmod

# 3. Confirm NetHunter drivers are active
zcat /proc/config.gz | grep -E "CONFIG_88XXAU=|CONFIG_ATH9K_HTC=|CONFIG_MT7601U=|CONFIG_RTL8187=|CONFIG_USB_CONFIGFS_F_HID=|CONFIG_TUN="
```

### Testing USB HID (BadUSB)
1. Open the **NetHunter App** -> **USB Arsenal**.
2. Set **USB Function** to `HID` -> tap **Set USB Function**.
3. Run `ls -l /dev/hidg*` — `/dev/hidg0` and `/dev/hidg1` should appear.

### Testing External USB Wi-Fi
1. Plug your adapter into a **powered USB OTG hub** (recommended for high-power adapters like `RTL8812AU`).
2. Run `lsusb` and `iw dev` in Kali to confirm `wlan1` appears.
3. Enable monitor mode:
   ```bash
   airmon-ng start wlan1
   ```

---

## Building from Source

### Dependencies (Debian / Ubuntu / Kali)
```bash
apt update && apt install -y git bc bison flex libssl-dev make python3 cpio zip clang lld llvm gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu libncurses-dev
```

### Build on ARM64 (`build_local.sh`) or x86_64 (`build_kernel.sh`)
```bash
git clone https://github.com/shouryamusic51-gif/android_kernel_samsung_a042f_nethunter-.git
cd android_kernel_samsung_a042f_nethunter-
mkdir -p out
./build_local.sh
```
The compiled kernel will be generated at `out/arch/arm64/boot/Image`.

---

## Troubleshooting
- **Bootloop after flashing:** Boot into TWRP (`Volume Up + Power` with USB plugged in) -> **Install Image** -> select `/sdcard/stock-boot-backup.img` -> **Boot** -> Reboot.
- **External Wi-Fi adapter detected in `lsusb` but no `wlan1`:** Check `dmesg | tail -n 25` for missing firmware files. For Atheros `ath9k_htc`, install `firmware-atheros` inside Kali (`apt install -y firmware-atheros`).
- **Adapter disconnects randomly:** Use a powered USB OTG hub; dual-antenna adapters draw more power than a phone port can supply alone.

---

## Credits
- **Samsung Open Source** for the `SM-A042F` kernel source
- **Kali NetHunter** (`kali-nethunter-kernel`) for the 4.19 Wi-Fi injection & driver patches
- **Magisk** (`magiskboot`) for on-device boot image unpacking/repacking
