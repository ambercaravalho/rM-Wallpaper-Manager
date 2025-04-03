# rM-Wallpaper-Manager

A simple utility to assist in managing the wallpapers (or splash screens) on reMarkable devices.

## Overview

This tool allows you to customize the splash screens (wallpapers) that appear on your reMarkable tablet, including startup, shutdown, battery empty, and other system screens.

## Requirements

- A reMarkable tablet (reMarkable 1, reMarkable 2, or reMarkable Paper Pro)
- Your reMarkable tablet connected via USB on your computer
- SSH password (found in `Settings > About > Copyrights and licenses > GPLv3 Compliance`)

### Before We Begin

| For reMarkable Paper Pro  | For reMarkable 2 |
| ------------- | ------------- |
| You must enable Developer Mode to access SSH and run this script: `Settings > General > Developer options`  | I'd *strongly* recommended enabling data encryption: `Settings > Security > Data Protection > Security Level`  |

> [!IMPORTANT]
> Both these actions 👆 will wipe your entire device. Be sure to either backup your data directory or sync with reMarkable Connect before continuing!

## Installation

### Step 1: Download the Repository
Clone or download this repository to your computer.

```bash
git clone https://github.com/ambercaravalho/rM-Wallpaper-Manager.git
```

### Step 2: Prepare Your Custom Wallpapers
1. Create your custom wallpaper PNG files (1404×1872 pixels is recommended)
2. Place them in the `rm-background-manager/custom-backgrounds` folder
3. Name the files according to where you want them to appear:
   - `batteryempty.png` - Shown when battery is depleted
   - `factory.png` - Factory reset screen
   - `hibernate.png` - Hibernation screen
   - `overheating.png` - Overheating warning
   - `poweroff.png` - Shutdown screen
   - `rebooting.png` - Reboot screen
   - `restart-crashed.png` - Crash recovery
   - `starting.png` - Startup screen
   - `suspended.png` - Suspended/sleep mode

### Step 3: Install on Your reMarkable

Click the dropdown for your operating system below:

<details><summary>For macOS/Linux Users</summary>

1. Connect your tablet to the computer via USB
2. Open Terminal
3. Navigate to the downloaded repository folder:
   ```bash
   cd path/to/rM-Wallpaper-Manager
   ```
4. Make the start script executable:
   ```bash
   chmod +x start_macos-linux.sh
   ```
5. Run the start script:
   ```bash
   ./start_macos-linux.sh
   ```

</details>

<details><summary>For Windows Users</summary>

1. Connect your tablet to the computer via USB
2. Open PowerShell
3. Navigate to the downloaded repository folder:
   ```powershell
   cd path\to\rM-Wallpaper-Manager
   ```
4. Run the start script:
   ```powershell
   .\start_windows.ps1
   ```

</details>

> [!TIP]
> You can find your reMarkable's IP address here: `Settings > About > Copyrights and licenses > GPLv3 Compliance`

## Using the Wallpaper Manager on Your reMarkable

After installation, connect to your reMarkable through SSH:

```bash
ssh root@YOUR_REMARKABLE_IP
```

Once connected via SSH, run the following commands:

1. Navigate to the `rm-background-manager` directory:
   ```bash
   cd /home/root/rm-background-manager
   ```

2. Run the wallpaper manager script:
   ```bash
   bash wallpaper-manager.sh
   ```

3. Choose from the available options in the menu:
   - Option 1: Install Custom Wallpapers (creates backups of original files)
   - Option 2: Update Wallpapers (reinstalls after system update, creates backups)
   - Option 3: Restore Original Wallpapers (restores from backups)
   - Option 4: Exit

> [!WARNING]
> After every reMarkable software update, the device resets custom wallpapers to defaults.
> You'll need to SSH back into your tablet and run the wallpaper manager script again using Option 2 (Update Wallpapers). You don't need to repeat the computer-side setup.

## Troubleshooting

- **Can't connect to reMarkable**: Verify that developer mode is enabled (if supported) and that your tablet is displayed as a network device on your computer.
- **Permission denied errors**: Make sure you're using the correct password from your device settings.
- **Wallpapers not showing up**: Verify that your images are PNG files, that they are properly named, and that they are placed in the custom-backgrounds folder.
- **Changes not appearing**: Reboot your reMarkable tablet after installing or updating wallpapers.
- **After reMarkable update**: Use Option 2 in the wallpaper manager to reinstall your custom wallpapers.

## Reverting to Default Wallpapers

The installed wallpapers can be reverted to default in two ways:

1. Using the wallpaper manager script (Option 3)
2. Manually restoring from backup files:

  ```bash
  cd /usr/share/remarkable
  mv batteryempty.png.bak batteryempty.png
  # Repeat for other wallpaper files
  ```

## Disclaimer

This tool modifies system files on your reMarkable device. Use at your own risk. Neither the author nor reMarkable provides support for this process, and it could potentially cause issues with your device.

## License

This project is available as open source under the terms of the MIT License.

