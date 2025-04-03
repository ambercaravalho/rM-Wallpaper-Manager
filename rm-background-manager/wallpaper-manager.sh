#!/bin/bash

# Color and formatting definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;96m"
YELLOW="\033[0;93m"
RED="\033[0;31m"
RESET="\033[0m"
SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Function to display menu
display_menu() {
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}            reMarkable Wallpaper Manager${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
    echo -e "${BOLD}1.${RESET} Install Custom Wallpapers ${BLUE}(creates backups of original files)${RESET}"
    echo -e "${BOLD}2.${RESET} Update Wallpapers ${BLUE}(reinstalls after system update, creates backups)${RESET}"
    echo -e "${BOLD}3.${RESET} Restore Original Wallpapers ${BLUE}(restores from backups)${RESET}"
    echo -e "${BOLD}4.${RESET} Exit"
    echo
    echo -e "${BOLD}Enter your choice (1-4):${RESET}"
}

# Function to install wallpapers (creates backups)
install_wallpapers() {
    echo -e "${BOLD}${BLUE}Installing wallpapers (with backup)...${RESET}"
    echo
    
    # Process each file
    MISSING_FILES=0
    for file in "${FILES[@]}"; do
        # Check if the file exists in the custom-backgrounds folder
        if [ -f "$CUSTOM_BACKGROUNDS_DIR/$file" ]; then
            # If the file exists in the remarkable directory, rename it to .bak
            if [ -f "$REMARKABLE_DIR/$file" ]; then
                # Only create backup if one doesn't already exist
                if [ -f "$REMARKABLE_DIR/$file.bak" ]; then
                    echo -e "  ${YELLOW}⚠${RESET} Backup for $file already exists, keeping original backup"
                else
                    mv "$REMARKABLE_DIR/$file" "$REMARKABLE_DIR/$file.bak"
                    echo -e "  ${GREEN}✓${RESET} Renamed $REMARKABLE_DIR/$file to $REMARKABLE_DIR/$file.bak"
                fi
            fi

            # Copy the file to the remarkable directory
            cp "$CUSTOM_BACKGROUNDS_DIR/$file" "$REMARKABLE_DIR/$file"
            echo -e "  ${GREEN}✓${RESET} Copied $file to $REMARKABLE_DIR"
        else
            echo -e "  ${YELLOW}⚠${RESET} Skipping $file as it is not present in $CUSTOM_BACKGROUNDS_DIR"
            MISSING_FILES=$((MISSING_FILES + 1))
        fi
    done

    echo
    # If any files are missing in the custom-backgrounds folder, warn the user
    if [ $MISSING_FILES -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}Warning:${RESET} ${YELLOW}$MISSING_FILES files were not found in $CUSTOM_BACKGROUNDS_DIR and were skipped.${RESET}"
    fi

    echo -e "${GREEN}${BOLD}✓ Success!${RESET} ${GREEN}All available files have been copied to $REMARKABLE_DIR${RESET}"
}

# Function to update wallpapers (after system update)
update_wallpapers() {
    echo -e "${BOLD}${BLUE}Updating wallpapers after system update (creating backups)...${RESET}"
    echo
    
    # Process each file
    MISSING_FILES=0
    for file in "${FILES[@]}"; do
        # Check if the file exists in the custom-backgrounds folder
        if [ -f "$CUSTOM_BACKGROUNDS_DIR/$file" ]; then
            # If the file exists in the remarkable directory, rename it to .bak
            if [ -f "$REMARKABLE_DIR/$file" ]; then
                # Only create backup if one doesn't already exist
                if [ -f "$REMARKABLE_DIR/$file.bak" ]; then
                    echo -e "  ${YELLOW}⚠${RESET} Backup for $file already exists, keeping original backup"
                else
                    mv "$REMARKABLE_DIR/$file" "$REMARKABLE_DIR/$file.bak"
                    echo -e "  ${GREEN}✓${RESET} Renamed $REMARKABLE_DIR/$file to $REMARKABLE_DIR/$file.bak"
                fi
            fi

            # Copy the file to the remarkable directory
            cp "$CUSTOM_BACKGROUNDS_DIR/$file" "$REMARKABLE_DIR/$file"
            echo -e "  ${GREEN}✓${RESET} Copied $file to $REMARKABLE_DIR"
        else
            echo -e "  ${YELLOW}⚠${RESET} Skipping $file as it is not present in $CUSTOM_BACKGROUNDS_DIR"
            MISSING_FILES=$((MISSING_FILES + 1))
        fi
    done

    echo
    # If any files are missing in the custom-backgrounds folder, warn the user
    if [ $MISSING_FILES -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}Warning:${RESET} ${YELLOW}$MISSING_FILES files were not found in $CUSTOM_BACKGROUNDS_DIR and were skipped.${RESET}"
    fi

    echo -e "${GREEN}${BOLD}✓ Success!${RESET} ${GREEN}All available files have been copied to $REMARKABLE_DIR${RESET}"
}

# Function to restore original wallpapers from backup
restore_original_wallpapers() {
    echo -e "${BOLD}${BLUE}Restoring original wallpapers from backup files...${RESET}"
    echo
    
    # Count of how many files were restored
    RESTORED_FILES=0
    
    # Process each file
    for file in "${FILES[@]}"; do
        # Check if backup file exists
        if [ -f "$REMARKABLE_DIR/$file.bak" ]; then
            # Remove the current file (which is likely a symlink)
            if [ -e "$REMARKABLE_DIR/$file" ]; then
                rm "$REMARKABLE_DIR/$file"
                echo -e "  ${GREEN}✓${RESET} Removed $REMARKABLE_DIR/$file"
            fi
            
            # Rename the backup file to restore the original
            mv "$REMARKABLE_DIR/$file.bak" "$REMARKABLE_DIR/$file"
            echo -e "  ${GREEN}✓${RESET} Restored $file from backup"
            RESTORED_FILES=$((RESTORED_FILES + 1))
        else
            echo -e "  ${YELLOW}⚠${RESET} No backup found for $file"
        fi
    done
    
    echo
    if [ $RESTORED_FILES -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}Notice:${RESET} ${YELLOW}No backup files were found. Nothing was restored.${RESET}"
    else
        echo -e "${GREEN}${BOLD}✓ Success!${RESET} ${GREEN}Successfully restored $RESTORED_FILES original wallpaper files.${RESET}"
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
        echo
        echo -e "${RED}${BOLD}WARNING:${RESET} ${YELLOW}This script modifies system files on your reMarkable device.${RESET}"
        echo -e "${YELLOW}Proceeding with this script could potentially brick your device.${RESET}"
        echo -e "${YELLOW}Neither the script author nor reMarkable provides any support for this process.${RESET}"
        echo -e "${YELLOW}Use this script at your own risk.${RESET}"
        echo
        echo -e "${BOLD}Type 'yes' to continue or anything else to cancel:${RESET}"
        read -r CONFIRMATION

        if [ "$CONFIRMATION" != "yes" ]; then
            echo -e "${YELLOW}Operation canceled by the user.${RESET}"
            exit 0
        fi

        # Check if the remarkable directory exists
        if [ ! -d "$REMARKABLE_DIR" ]; then
            echo -e "${RED}${BOLD}Error:${RESET} ${RED}Directory $REMARKABLE_DIR does not exist${RESET}"
            echo -e "${RED}The tablet may have been updated and the file structure could have changed.${RESET}"
            echo -e "${RED}Unless there's a new version of this script on GitHub, you'll have to complete this process manually.${RESET}"
            exit 1
        fi

        # Check if the custom backgrounds directory exists
        if [ ! -d "$CUSTOM_BACKGROUNDS_DIR" ]; then
            echo -e "${RED}${BOLD}Error:${RESET} ${RED}Directory $CUSTOM_BACKGROUNDS_DIR does not exist${RESET}"
            echo -e "${RED}Make sure the 'custom-backgrounds' folder is in the same directory as this script.${RESET}"
            echo -e "${RED}Please redownload the repository from GitHub and run the start script again.${RESET}"
            exit 1
        fi

        install_wallpapers
        ;;
    "2")
        # Display warning and prompt for confirmation
        echo
        echo -e "${RED}${BOLD}WARNING:${RESET} ${YELLOW}This script modifies system files on your reMarkable device.${RESET}"
        echo -e "${YELLOW}Proceeding with this script could potentially brick your device.${RESET}"
        echo -e "${YELLOW}Neither the script author nor reMarkable provides any support for this process.${RESET}"
        echo -e "${YELLOW}Use this script at your own risk.${RESET}"
        echo
        echo -e "${BOLD}Type 'yes' to continue or anything else to cancel:${RESET}"
        read -r CONFIRMATION

        if [ "$CONFIRMATION" != "yes" ]; then
            echo -e "${YELLOW}Operation canceled by the user.${RESET}"
            exit 0
        fi

        # Check if the remarkable directory exists
        if [ ! -d "$REMARKABLE_DIR" ]; then
            echo -e "${RED}${BOLD}Error:${RESET} ${RED}Directory $REMARKABLE_DIR does not exist${RESET}"
            echo -e "${RED}The tablet may have been updated and the file structure could have changed.${RESET}"
            echo -e "${RED}Unless there's a new version of this script on GitHub, you'll have to complete this process manually.${RESET}"
            exit 1
        fi

        # Check if the custom backgrounds directory exists
        if [ ! -d "$CUSTOM_BACKGROUNDS_DIR" ]; then
            echo -e "${RED}${BOLD}Error:${RESET} ${RED}Directory $CUSTOM_BACKGROUNDS_DIR does not exist${RESET}"
            echo -e "${RED}Make sure the 'custom-backgrounds' folder is in the same directory as this script.${RESET}"
            echo -e "${RED}Please redownload the repository from GitHub and run the start script again.${RESET}"
            exit 1
        fi

        update_wallpapers
        ;;
    "3")
        # Display warning and prompt for confirmation
        echo
        echo -e "${RED}${BOLD}WARNING:${RESET} ${YELLOW}This script modifies system files on your reMarkable device.${RESET}"
        echo -e "${YELLOW}Proceeding with this script could potentially brick your device.${RESET}"
        echo -e "${YELLOW}Neither the script author nor reMarkable provides any support for this process.${RESET}"
        echo -e "${YELLOW}Use this script at your own risk.${RESET}"
        echo
        echo -e "${BOLD}Type 'yes' to continue or anything else to cancel:${RESET}"
        read -r CONFIRMATION

        if [ "$CONFIRMATION" != "yes" ]; then
            echo -e "${YELLOW}Operation canceled by the user.${RESET}"
            exit 0
        fi

        # Check if the remarkable directory exists
        if [ ! -d "$REMARKABLE_DIR" ]; then
            echo -e "${RED}${BOLD}Error:${RESET} ${RED}Directory $REMARKABLE_DIR does not exist${RESET}"
            echo -e "${RED}The tablet may have been updated and the file structure could have changed.${RESET}"
            echo -e "${RED}Unless there's a new version of this script on GitHub, you'll have to complete this process manually.${RESET}"
            exit 1
        fi

        restore_original_wallpapers
        ;;
    "4")
        echo -e "${BLUE}Exiting program.${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}${BOLD}Error:${RESET} ${RED}Invalid option. Please run the script again and select a valid option (1-4).${RESET}"
        exit 1
        ;;
esac

exit 0
