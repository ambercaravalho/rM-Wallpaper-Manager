# rM-Wallpaper-Manager

A simple utility to assist in managing the wallpapers (or splash screens) on reMarkable devices.

## Overview

This tool allows you to customize the splash screens (wallpapers) that appear on your reMarkable tablet, including startup, shutdown, battery empty, and other system screens.

## Requirements

- A reMarkable tablet (reMarkable 1, reMarkable 2, or reMarkable Paper Pro)
- Your reMarkable tablet connected via USB on your computer
- SSH password (found in `Settings > About > Copyrights and licenses > GPLv3 Compliance`)

### Some Notes

| For reMarkable Paper Pro  | Security Note |
| ------------- | ------------- |
| You must enable Developer Mode to access SSH and run this script: `Settings > General > Developer options`.  | For reMarkable 2 or Paper Pro, it's recommended to enable full device encryption: `Settings > Security > Data Protection > Security Level`  |

> [!IMPORTANT]
> These actions will wipe your entire device. Be sure to either backup your device or sync with reMarkable Connect before continuing!

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

2. Install the wallpapers (first-time setup):
   ```bash
   bash install.sh
   ```

3. For future wallpaper updates (after changing the PNG files):
   ```bash
   bash update.sh
   ```

## Troubleshooting

- **Can't connect to reMarkable**: Verify that developer mode is enabled (if supported) and that your tablet is displayed as a network device on your computer.
- **Permission denied errors**: Make sure you're using the correct password from your device settings.
- **Wallpapers not showing up**: Verify that your images are PNG files, that they are properly named, and that they are placed in the custom-backgrounds folder.
- **Changes not appearing**: Reboot your reMarkable tablet after installing or updating wallpapers.

## Reverting to Default Wallpapers

The install script creates backup files with ".bak" extensions. To restore the original wallpapers, connect via SSH and move these files back:

```bash
cd /usr/share/remarkable
mv batteryempty.png.bak batteryempty.png
# Repeat for other wallpaper files
```

## Disclaimer

This tool modifies system files on your reMarkable device. Use at your own risk. Neither the author nor reMarkable provides support for this process, and it could potentially cause issues with your device.

## License

This project is available as open source under the terms of the MIT License.

