#!/bin/bash

# reMarkable Wallpaper Manager installer script
# Copies rm-background-manager folder to remote reMarkable tablet

echo "Welcome to reMarkable Wallpaper Manager!"
echo "For updates and more information, visit:"
echo "https://github.com/ambercaravalho/rM-Wallpaper-Manager"
echo
echo "IMPORTANT:"
echo "- If you are using a reMarkable Paper Pro, you must enable developer mode:"
echo "  https://support.remarkable.com/s/article/Developer-mode"
echo "- On reMarkable 2 or Paper Pro, please enable full device encryption before doing anything else with your device (this is technically optional):"
echo "  Settings > Security > Data Protection > Security Level"
echo

echo "reMarkable Background Manager Installer"
echo "========================================"
echo

# Check if rm-background-manager folder exists
if [ ! -d "rm-background-manager" ]; then
    echo "Error: rm-background-manager folder not found in current directory."
    echo "Please redownload the repository from GitHub and run the start script again."
    exit 1
fi

# Get the IP address of the reMarkable
read -p "Enter your reMarkable's IP address: " REMARKABLE_IP

# Copy files to the reMarkable
echo "Copying files to your reMarkable tablet..."
scp -r rm-background-manager root@$REMARKABLE_IP:/home/root/

if [ $? -eq 0 ]; then
    echo "Success! rm-background-manager has been installed to your reMarkable."
    echo "Connect to your device using SSH to run the application."
else
    echo "Error: Failed to copy files to the reMarkable."
    echo "Please check the IP address and make sure your tablet is connected to your computer over USB."
    echo "Note: You'll need to enter the password when prompted (found if your device's settings)."
fi