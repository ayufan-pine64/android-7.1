Upgrade (from [Ubuntu](https://github.com/ayufan-pine64/linux-build/releases/latest)):
```
$ pine64_upgrade_android.sh /dev/mmcblk1 android-7.1 0.3.17
```

Notice:
- Edit `/boot/uEnv.txt` as there are many different system and performance level configuration options,
- Add to `/boot/uEnv.txt`:
  - `emmc_compat=on`: if you are having problems with using eMMC module (especially eMMC 5.1),
  - `pinebook_lcd_mode=batch1|batch2`: if you are having problems with screen flickering on Pinebook,

Changes:
- 0.3.17: Use custom build boot0 with support for eMMC 5.1,
- 0.3.17: Support HS200 for eMMC 5.1,
- 0.3.17: Add `emmc_compat=150mhz|200mhz` allowing to enable extra performance boost on eMMC (unstable),
- 0.3.17: Make u-boot and kernel to support eMMC 5.1,
- 0.3.17: Run u-boot eMMC support in compatibility mode (SDR25),
- 0.3.17: Allow to change Pinebook LCD parameters with `uEnv.txt` to fix flickering,
- 0.3.17: Allow to enable eMMC compatibility mode for Android via `uEnv.txt`,
- 0.3.15: Do not include Geekbench,
- 0.3.14: Fix LCD display for Pine A64,
- Support additional HDMI modes: 1024x600p and 800x480p,
- Upgrade Android to 7.1.2_r11,
- Test release of SoPine,
- Fix support for HDMI,
- Fix U-Boot support for Pine A64,
- Use single DTB for U-Boot and kernel,
- Fix some suspend issues to additional locks done by power manager,
- Update sleep behavior when pressing the power buttons,
- Use native lid switch support instead of relying on custom keys,
- Make suspend to work regardless display on/off notifications,
- Use keyed autoboot, s to abort as The Pinebook uses UART via headphone jack (thanks, @longsleep),
- Reduce boot delay from 3 to 1 second to speed up booting,
- Added 8723cs_efuse.map,
- Disable CPUS_WAKE_ALRM0 from Wake sources to prevent suspend,
- Disable Realtek WiFi 8723 power management,
- Use BSP 1.2 kernel (without backports): https://github.com/ayufan-pine64/linux-pine64: my-hacks-1.2,
- Fixes camera support,
- Fixes headphones support, enable on boot,
- Auto-generates wifi mac address,
- Allows accessing eMMC when booting from SD,

Currently, it only works on Pinebook.

