#!/usr/bin/env bash

# reMarkable wallpaper manager, device side
# https://github.com/ambercaravalho/rM-Wallpaper-Manager

set -euo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;96m"
YELLOW="\033[0;93m"
RED="\033[0;31m"
RESET="\033[0m"
SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REMARKABLE_DIR="/usr/share/remarkable"
CUSTOM_BACKGROUNDS_DIR="./bg"
FILES=(
    "batteryempty.png" "factory.png" "overheating.png"
    "poweroff.png" "remotewipe.png" "rebooting.png"
    "restart-crashed.png" "starting.png" "suspended.png"
)

show_menu() {
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}      reMarkable wallpaper manager (device side)${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
    echo -e "${BOLD}1.${RESET} install custom wallpapers"
    echo -e "${BOLD}2.${RESET} update wallpapers (after system update)"
    echo -e "${BOLD}3.${RESET} restore original wallpapers"
    echo -e "${BOLD}4.${RESET} exit"
    echo
    read -rp "ur choice (1-4): " CHOICE
}

check_directories() {
    if [[ ! -d "$REMARKABLE_DIR" ]]; then
        echo -e "${RED}✗ error: $REMARKABLE_DIR not found!${RESET}"
        echo -e "${RED}system files may have changed after update${RESET}"
        exit 1
    fi
    
    if [[ ! -d "$CUSTOM_BACKGROUNDS_DIR" ]]; then
        echo -e "${RED}✗ error: $CUSTOM_BACKGROUNDS_DIR not found!${RESET}"
        echo -e "${RED}ensure that folder is in the same directory as this script${RESET}"
        exit 1
    fi
}

show_warning() {
    echo
    echo -e "${RED}${BOLD}⚠ WARNING${RESET}"
    echo -e "${YELLOW}this modifies system files on your reMarkable${RESET}"
    echo -e "${YELLOW}use at your own risk - may cause issues${RESET}"
    echo -e "${YELLOW}no official support from reMarkable or author${RESET}"
    echo
    read -rp "type 'yes' to continue: " CONFIRMATION
    
    if [[ "$CONFIRMATION" != "yes" ]]; then
        echo -e "${BLUE}operations cancelled${RESET}"
        exit 0
    fi
}

install_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}installing custom wallpapers${RESET}"
    echo
    
    local missing_files=0
    local installed_files=0
    
    for file in "${FILES[@]}"; do
        if [[ ! -f "$CUSTOM_BACKGROUNDS_DIR/$file" ]]; then
            echo -e "  ${YELLOW}⚠ skipping $file (not found)${RESET}"
            ((missing_files++))
            continue
        fi
        
        if [[ -f "$REMARKABLE_DIR/$file" && ! -f "$REMARKABLE_DIR/$file.bak" ]]; then
            mv "$REMARKABLE_DIR/$file" "$REMARKABLE_DIR/$file.bak"
            echo -e "  ${GREEN}✓ backed up $file${RESET}"
        elif [[ -f "$REMARKABLE_DIR/$file.bak" ]]; then
            echo -e "  ${YELLOW}⚠ backup for $file already exists${RESET}"
        fi
        
        cp "$CUSTOM_BACKGROUNDS_DIR/$file" "$REMARKABLE_DIR/$file"
        echo -e "  ${GREEN}✓ installed $file${RESET}"
        ((installed_files++))
    done
    
    echo
    if [[ $missing_files -gt 0 ]]; then
        echo -e "${YELLOW}note: $missing_files file(s) were skipped${RESET}"
    fi
    
    if [[ $installed_files -gt 0 ]]; then
        echo -e "${GREEN}✓ installed $installed_files wallpaper(s)${RESET}"
    else
        echo -e "${YELLOW}no wallpapers were installed${RESET}"
    fi
}

update_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}updating wallpapers after system update${RESET}"
    echo
    
    install_wallpapers
}

restore_original_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}restoring original wallpapers${RESET}"
    echo
    
    local restored_files=0
    
    for file in "${FILES[@]}"; do
        if [[ ! -f "$REMARKABLE_DIR/$file.bak" ]]; then
            echo -e "  ${YELLOW}⚠ no backup found for $file${RESET}"
            continue
        fi
        
        if [[ -e "$REMARKABLE_DIR/$file" ]]; then
            rm "$REMARKABLE_DIR/$file"
        fi
        
        mv "$REMARKABLE_DIR/$file.bak" "$REMARKABLE_DIR/$file"
        echo -e "  ${GREEN}✓ restored $file${RESET}"
        ((restored_files++))
    done
    
    echo
    if [[ $restored_files -eq 0 ]]; then
        echo -e "${YELLOW}no backup files found - nothing restored${RESET}"
    else
        echo -e "${GREEN}✓ restored $restored_files original wallpaper(s)${RESET}"
    fi
}

prompt_reboot() {
    echo
    echo -e "${YELLOW}reboot required for changes to take effect${RESET}"
    read -rp "reboot now? (y/N): " REBOOT_CHOICE
    
    if [[ "${REBOOT_CHOICE,,}" =~ ^(y|yes)$ ]]; then
        echo -e "${BLUE}rebooting...${RESET}"
        reboot
    else
        echo -e "${BLUE}remember to reboot later for changes to take effect!${RESET}"
    fi
}

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
            echo -e "${BLUE}okay, goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}✗ invalid option!${RESET}"
            echo -e "${RED}plz run the script again and select 1-4${RESET}"
            exit 1
            ;;
    esac
}

main
