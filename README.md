# rM-wallpaper-manager

a utility to assist to manage the wallpapers (sleep screens) on reMarkable devices.

## before u begin

| for reMarkable Paper Pro, Move, and Pure  | for reMarkable 2 |
| ------------- | ------------- |
| you **must** enable Developer Mode to access SSH and run this script: `Settings > General > Developer options`  | I'd *strongly* recommended enabling data encryption: `Settings > Security > Data Protection > Security Level`  |

> [!IMPORTANT]
> both of these actions 👆 will wipe your entire device. be sure to either backup your data directory or sync with reMarkable Connect/rmfakecloud before continuing!

## installation

### 1. clone this repo

```bash
git clone https://github.com/ambercaravalho/rM-Wallpaper-Manager.git
```

### 2. run the install script

1. connect the tablet to the computer via USB
2. open Terminal
3. navigate to the downloaded repo folder:
   ```bash
   cd path/to/rM-Wallpaper-Manager
   ```
4. make the start script executable:
   ```bash
   chmod +x setup.sh
   ```
5. Run the start script:
   ```bash
   ./setup.sh
   ```

> [!TIP]
> You can find your reMarkable's IP address here: `Settings > Help > Copyrights and licenses > GPLv3 Compliance`

### 3. choose install mode

the script will offers two install options:

1. **guided mode** *recommended* - interactively select images for each background type.
   
2. **manual mode** - use pre-prepared images in the `device/bg` folder.
   - create custom .PNG files with the correct resolution for your device:
     - rM1/rM2/Paper Pure: 1404×1872 pixels
     - Paper Pro: 1872×2404 pixels
     - Paper Pro Move: 1696×954 pixels
   - place them in the `device/bg` folder
   - name the files according to where you want them to appear:
     - `batteryempty.png` - Shown when battery is depleted
     - `factory.png` - Factory reset screen
     - `hibernate.png` - Hibernation screen
     - `overheating.png` - Overheating warning
     - `poweroff.png` - Shutdown screen
     - `remotewipe.png` - Enterprise wipe screen
     - `rebooting.png` - Reboot screen
     - `restart-crashed.png` - Crash recovery
     - `starting.png` - Startup screen
     - `suspended.png` - Suspended/sleep mode

## post-installation

after installation, the script (should) connect you to the device using SSH.

once connected via SSH, run the following commands:

1. navigate to the `device` directory:
   ```bash
   cd /home/root/device
   ```

2. run the wallpaper manager script:
   ```bash
   bash run.sh
   ```

3. choose from the available options in the menu:
   - option 1: install custom wallpapers (creates backups of original files)
   - option 2: update wallpapers (reinstalls after system update, creates backups)
   - option 3: restore original wallpapers (restores from backups)
   - option 4: exit

> [!WARNING]
> after every reMarkable software update, the device resets all custom wallpapers to defaults.
> you'll need to SSH back into your tablet and run the wallpaper manager script again using option 2 (update wallpapers). *You don't need to repeat the computer-side setup.*

## troubleshooting

- **can't connect to reMarkable**: verify that developer mode is enabled (if needed) and that your tablet is displayed as a network device on your computer.
- **permission denied errors**: make sure you're using the correct password from your device settings.
- **wallpapers not showing up**: verify that your images are PNG files, that they are properly named, and that they are placed in the `device/bg` folder.
- **changes not appearing**: reboot the tablet after installing or updating wallpapers.
- **after reMarkable update**: use option 2 in the wallpaper manager to reinstall your custom wallpapers.

## reverting to default wallpapers

the installed wallpapers can be reverted to default in two ways:

1. using the wallpaper manager script (option 3)
2. manually restoring from backup files:

  ```bash
  cd /usr/share/remarkable
  mv batteryempty.png.bak batteryempty.png
  # repeat for other wallpaper files
  ```

## disclaimer

this tool modifies system files on your reMarkable device. use at your own risk! Neither the author nor reMarkable provides support for this process, and it could potentially cause issues with your device.

## license

this project is available as open source under the terms of the MIT license.
