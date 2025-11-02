#!/usr/bin/env bash

# reMarkable Wallpaper Manager
# Manages custom wallpapers on reMarkable devices
# https://github.com/ambercaravalho/rM-Wallpaper-Manager

set -euo pipefail

# Color and formatting definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;96m"
YELLOW="\033[0;93m"
RED="\033[0;31m"
RESET="\033[0m"
SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Constants
REMARKABLE_DIR="/usr/share/remarkable"
CUSTOM_BACKGROUNDS_DIR="./custom-backgrounds"
FILES=(
    "batteryempty.png" "factory.png" "hibernate.png"
    "overheating.png" "poweroff.png" "rebooting.png"
    "restart-crashed.png" "starting.png" "suspended.png"
)

# Functions
show_menu() {
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}    reMarkable Wallpaper Manager${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
    echo -e "${BOLD}1.${RESET} Install Custom Wallpapers"
    echo -e "   ${BLUE}Creates backups of original files${RESET}"
    echo
    echo -e "${BOLD}2.${RESET} Update Wallpapers (after system update)"
    echo -e "   ${BLUE}Reinstalls custom wallpapers with backup${RESET}"
    echo
    echo -e "${BOLD}3.${RESET} Restore Original Wallpapers"
    echo -e "   ${BLUE}Restores from backup files${RESET}"
    echo
    echo -e "${BOLD}4.${RESET} Exit"
    echo
    read -rp "Your choice (1-4): " CHOICE
}

check_directories() {
    if [[ ! -d "$REMARKABLE_DIR" ]]; then
        echo -e "${RED}✗ Error: $REMARKABLE_DIR not found${RESET}"
        echo -e "${RED}System structure may have changed after update${RESET}"
        exit 1
    fi
    
    if [[ ! -d "$CUSTOM_BACKGROUNDS_DIR" ]]; then
        echo -e "${RED}✗ Error: $CUSTOM_BACKGROUNDS_DIR not found${RESET}"
        echo -e "${RED}Ensure this folder is in the same directory as this script${RESET}"
        exit 1
    fi
}

show_warning() {
    echo
    echo -e "${RED}${BOLD}⚠ WARNING${RESET}"
    echo -e "${YELLOW}This modifies system files on your reMarkable${RESET}"
    echo -e "${YELLOW}Use at your own risk - may cause issues${RESET}"
    echo -e "${YELLOW}No official support from reMarkable or author${RESET}"
    echo
    read -rp "Type 'yes' to continue: " CONFIRMATION
    
    if [[ "$CONFIRMATION" != "yes" ]]; then
        echo -e "${BLUE}Operation cancelled${RESET}"
        exit 0
    fi
}

# Function to install wallpapers (creates backups)
install_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}Installing Custom Wallpapers${RESET}"
    echo
    
    local missing_files=0
    local installed_files=0
    
    for file in "${FILES[@]}"; do
        if [[ ! -f "$CUSTOM_BACKGROUNDS_DIR/$file" ]]; then
            echo -e "  ${YELLOW}⚠ Skipping $file (not found)${RESET}"
            ((missing_files++))
            continue
        fi
        
        # Create backup if it doesn't exist
        if [[ -f "$REMARKABLE_DIR/$file" && ! -f "$REMARKABLE_DIR/$file.bak" ]]; then
            mv "$REMARKABLE_DIR/$file" "$REMARKABLE_DIR/$file.bak"
            echo -e "  ${GREEN}✓ Backed up $file${RESET}"
        elif [[ -f "$REMARKABLE_DIR/$file.bak" ]]; then
            echo -e "  ${YELLOW}⚠ Backup for $file already exists${RESET}"
        fi
        
        # Copy custom wallpaper
        cp "$CUSTOM_BACKGROUNDS_DIR/$file" "$REMARKABLE_DIR/$file"
        echo -e "  ${GREEN}✓ Installed $file${RESET}"
        ((installed_files++))
    done
    
    echo
    if [[ $missing_files -gt 0 ]]; then
        echo -e "${YELLOW}Note: $missing_files file(s) were skipped${RESET}"
    fi
    
    if [[ $installed_files -gt 0 ]]; then
        echo -e "${GREEN}✓ Installed $installed_files wallpaper(s)${RESET}"
    else
        echo -e "${YELLOW}No wallpapers were installed${RESET}"
    fi
}

# Function to update wallpapers (after system update)
update_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}Updating Wallpapers After System Update${RESET}"
    echo
    
    install_wallpapers
}

# Function to restore original wallpapers from backup
restore_original_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}Restoring Original Wallpapers${RESET}"
    echo
    
    local restored_files=0
    
    for file in "${FILES[@]}"; do
        if [[ ! -f "$REMARKABLE_DIR/$file.bak" ]]; then
            echo -e "  ${YELLOW}⚠ No backup found for $file${RESET}"
            continue
        fi
        
        # Remove current file
        if [[ -e "$REMARKABLE_DIR/$file" ]]; then
            rm "$REMARKABLE_DIR/$file"
        fi
        
        # Restore from backup
        mv "$REMARKABLE_DIR/$file.bak" "$REMARKABLE_DIR/$file"
        echo -e "  ${GREEN}✓ Restored $file${RESET}"
        ((restored_files++))
    done
    
    echo
    if [[ $restored_files -eq 0 ]]; then
        echo -e "${YELLOW}No backup files found - nothing restored${RESET}"
    else
        echo -e "${GREEN}✓ Restored $restored_files original wallpaper(s)${RESET}"
    fi
}

# Function to prompt for reboot
prompt_reboot() {
    echo
    echo -e "${YELLOW}Reboot required for changes to take effect${RESET}"
    read -rp "Reboot now? (y/N): " REBOOT_CHOICE
    
    if [[ "${REBOOT_CHOICE,,}" =~ ^(y|yes)$ ]]; then
        echo -e "${BLUE}Rebooting...${RESET}"
        reboot
    else
        echo -e "${BLUE}Remember to reboot later for changes to take effect${RESET}"
    fi
}

# Main execution
main() {
    show_menu
    
    case "$CHOICE" in
        1|2)
            show_warning
            check_directories
            
            if [[ "$CHOICE" == "1" ]]; then
                install_wallpapers
            else
                update_wallpapers
            fi
            
            prompt_reboot
            ;;
        3)
            show_warning
            check_directories
            restore_original_wallpapers
            prompt_reboot
            ;;
        4)
            echo -e "${BLUE}Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}✗ Invalid option${RESET}"
            echo -e "${RED}Please run the script again and select 1-4${RESET}"
            exit 1
            ;;
    esac
}

main
