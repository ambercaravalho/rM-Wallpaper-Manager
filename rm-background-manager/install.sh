#!/bin/bash

# Setting the directories
REMARKABLE_DIR="/usr/share/remarkable"
CUSTOM_BACKGROUNDS_DIR="./custom-backgrounds"

# List of files to check
FILES=(
    "batteryempty.png"
    "factory.png"
    "hibernate.png"
    "overheating.png"
    "poweroff.png"
    "rebooting.png"
    "restart-crashed.png"
    "starting.png"
    "suspended.png"
)

# Display warning and prompt for confirmation
echo "WARNING: This script modifies system files on your reMarkable device."
echo "Proceeding with this script could potentially brick your device."
echo "Neither the script author nor reMarkable provides any support for this process."
echo "Use this script at your own risk."
echo "Type 'yes' to continue or anything else to cancel:"
read -r CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
    echo "Operation canceled by the user."
    exit 0
fi

# Check if the remarkable directory exists
if [ ! -d "$REMARKABLE_DIR" ]; then
    echo "Error: Directory $REMARKABLE_DIR does not exist"
    echo "The tablet may have been updated and the file structure could have changed."
    echo "Unless there's a new version of this script on GitHub, you'll have to complete this process manually."
    exit 1
fi

# Check if the custom backgrounds directory exists
if [ ! -d "$CUSTOM_BACKGROUNDS_DIR" ]; then
    echo "Error: Directory $CUSTOM_BACKGROUNDS_DIR does not exist"
    echo "Make sure the 'custom-backgrounds' folder is in the same directory as this script."
    echo "Please redownload the repository from GitHub and run the start script again."
    exit 1
fi

# Process each file
MISSING_FILES=0
for file in "${FILES[@]}"; do
    # Check if the file exists in the custom-backgrounds folder
    if [ -f "$CUSTOM_BACKGROUNDS_DIR/$file" ]; then
        # If the file exists in the remarkable directory, rename it to .bak
        if [ -f "$REMARKABLE_DIR/$file" ]; then
            mv "$REMARKABLE_DIR/$file" "$REMARKABLE_DIR/$file.bak"
            echo "Renamed $REMARKABLE_DIR/$file to $REMARKABLE_DIR/$file.bak"
        fi

        # Create a symbolic link to the file in the custom-backgrounds folder
        ln -s "$CUSTOM_BACKGROUNDS_DIR/$file" "$REMARKABLE_DIR/$file"
        echo "Created symbolic link for $file in $REMARKABLE_DIR"
    else
        echo "Skipping $file as it is not present in $CUSTOM_BACKGROUNDS_DIR"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

# If any files are missing in the custom-backgrounds folder, warn the user
if [ $MISSING_FILES -gt 0 ]; then
    echo "Warning: $MISSING_FILES files were not found in $CUSTOM_BACKGROUNDS_DIR and were skipped."
fi

echo "All available files have been linked to $REMARKABLE_DIR"
exit 0