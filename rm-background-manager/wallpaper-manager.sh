#!/bin/bash

# Function to display menu
display_menu() {
    echo "reMarkable Wallpaper Manager"
    echo "============================"
    echo "1. Install Custom Wallpapers (creates backups of original files)"
    echo "2. Update Wallpapers (removes existing links)"
    echo "3. Restore Original Wallpapers (restores from backups)"
    echo "4. Exit"
    echo ""
    echo "Enter your choice (1-4):"
}

# Function to install wallpapers (creates backups)
install_wallpapers() {
    echo "Installing wallpapers (with backup)..."
    
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
}

# Function to update wallpapers (removes existing links)
update_wallpapers() {
    echo "Updating wallpapers (removing existing links)..."
    
    # Process each file
    MISSING_FILES=0
    for file in "${FILES[@]}"; do
        # Check if the file exists in the custom-backgrounds folder
        if [ -f "$CUSTOM_BACKGROUNDS_DIR/$file" ]; then
            # Remove any existing file or symbolic link in the remarkable directory
            if [ -e "$REMARKABLE_DIR/$file" ]; then
                rm "$REMARKABLE_DIR/$file"
                echo "Removed existing $REMARKABLE_DIR/$file"
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

    echo "All available files have been re-linked to $REMARKABLE_DIR"
}

# Function to restore original wallpapers from backup
restore_original_wallpapers() {
    echo "Restoring original wallpapers from backup files..."
    
    # Count of how many files were restored
    RESTORED_FILES=0
    
    # Process each file
    for file in "${FILES[@]}"; do
        # Check if backup file exists
        if [ -f "$REMARKABLE_DIR/$file.bak" ]; then
            # Remove the current file (which is likely a symlink)
            if [ -e "$REMARKABLE_DIR/$file" ]; then
                rm "$REMARKABLE_DIR/$file"
                echo "Removed $REMARKABLE_DIR/$file"
            fi
            
            # Rename the backup file to restore the original
            mv "$REMARKABLE_DIR/$file.bak" "$REMARKABLE_DIR/$file"
            echo "Restored $file from backup"
            RESTORED_FILES=$((RESTORED_FILES + 1))
        else
            echo "No backup found for $file"
        fi
    done
    
    if [ $RESTORED_FILES -eq 0 ]; then
        echo "No backup files were found. Nothing was restored."
    else
        echo "Successfully restored $RESTORED_FILES original wallpaper files."
    fi
}

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

# Display menu and get user choice
display_menu
read -r CHOICE

# Process based on user's choice
case "$CHOICE" in
    "1")
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

        install_wallpapers
        ;;
    "2")
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

        update_wallpapers
        ;;
    "3")
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

        restore_original_wallpapers
        ;;
    "4")
        echo "Exiting program."
        exit 0
        ;;
    *)
        echo "Invalid option. Please run the script again and select a valid option (1-4)."
        exit 1
        ;;
esac

exit 0
