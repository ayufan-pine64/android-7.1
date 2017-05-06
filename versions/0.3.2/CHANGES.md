Changes:
- Upgrade Android to 7.1.2_r11,
- Update sleep behavior when pressing the power buttons,
- Use native lid switch support instead of relying on custom keys (testing),
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

