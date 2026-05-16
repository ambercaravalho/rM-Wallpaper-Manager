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

REMARKABLE_BG_DIR="/usr/share/remarkable"
REMARKABLE_CAROUSELS_DIR="/usr/share/remarkable/carousel"
CUSTOM_BACKGROUNDS_DIR="./bg"
CUSTOM_CAROUSELS_DIR="./carousel"
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
    if [[ ! -d "$REMARKABLE_BG_DIR" ]]; then
        echo -e "${RED}✗ error: $REMARKABLE_BG_DIR not found!${RESET}"
        echo -e "${RED}system files may have changed after update, quitting${RESET}"
        exit 1
    fi
    
    if [[ ! -d "$CUSTOM_BACKGROUNDS_DIR" ]]; then
        echo -e "${RED}✗ error: $CUSTOM_BACKGROUNDS_DIR not found!${RESET}"
        echo -e "${RED}ensure that folder is in the same directory as this script, quitting${RESET}"
        exit 1
    fi

    if [[ ! -d "$CUSTOM_CAROUSELS_DIR" ]]; then
        echo -e "${RED}✗ error: $CUSTOM_CAROUSELS_DIR not found!${RESET}"
        echo -e "${RED}ensure that folder is in the same directory as this script, quitting${RESET}"
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
    local missing_files=0
    local installed_files=0

    echo
    echo -e "${BOLD}would you like to install wallpapers / sleep screens?${RESET}"
    read -rp "please choose (y/N): " WALLPAPER_CHOICE
    
    if [[ "$(echo "$WALLPAPER_CHOICE" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        for file in "${FILES[@]}"; do
            if [[ ! -f "$CUSTOM_BACKGROUNDS_DIR/$file" ]]; then
                echo -e "  ${YELLOW}⚠ skipping $file (not found)${RESET}"
                ((missing_files++))
                continue
            fi
            
            if [[ -f "$REMARKABLE_BG_DIR/$file" && ! -f "$REMARKABLE_BG_DIR/$file.bak" ]]; then
                mv "$REMARKABLE_BG_DIR/$file" "$REMARKABLE_BG_DIR/$file.bak"
                echo -e "  ${GREEN}✓ backed up $file${RESET}"
            elif [[ -f "$REMARKABLE_BG_DIR/$file.bak" ]]; then
                echo -e "  ${YELLOW}⚠ backup for $file already exists${RESET}"
            fi
            
            cp "$CUSTOM_BACKGROUNDS_DIR/$file" "$REMARKABLE_BG_DIR/$file"
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
    fi
}

install_carousels() {
    local missing_files=0
    local installed_files=0

    echo
    echo -e "${BOLD}would you like to install carousel images?${RESET}"
    read -rp "please choose (y/N): " CAROUSEL_CHOICE
    
    if [[ "$(echo "$CAROUSEL_CHOICE" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        for src_path in "$CUSTOM_CAROUSELS_DIR"/*.*; do
            local filename
            filename=$(basename "$src_path")

            if [[ ! -f "$src_path" ]]; then
                ((missing_files++))
                continue
            fi

            if cp "$src_path" "$REMARKABLE_CAROUSELS_DIR/$filename"; then
                echo -e "  ${GREEN}✓ installed $filename${RESET}"
                ((installed_files++))
            else
                echo -e "  ${RED}✗ failed to copy $filename${RESET}"
                ((missing_files++))
            fi
        done

        echo
        if [[ $missing_files -gt 0 ]]; then
            echo -e "${YELLOW}note: $missing_files file(s) were skipped or failed${RESET}"
        fi

        if [[ $installed_files -gt 0 ]]; then
            echo -e "${GREEN}✓ installed $installed_files carousel image(s)${RESET}"
        else
            echo -e "${YELLOW}no carousel images were installed${RESET}"
        fi
    fi
}

update_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}updating wallpapers after system update${RESET}"
    echo
    
    install_wallpapers
    install_carousels
}

restore_original_wallpapers() {
    echo
    echo -e "${BOLD}${BLUE}restoring original wallpapers${RESET}"
    echo
    
    local restored_files=0
    
    for file in "${FILES[@]}"; do
        if [[ ! -f "$REMARKABLE_BG_DIR/$file.bak" ]]; then
            echo -e "  ${YELLOW}⚠ no backup found for $file${RESET}"
            continue
        fi
        
        if [[ -e "$REMARKABLE_BG_DIR/$file" ]]; then
            rm "$REMARKABLE_BG_DIR/$file"
        fi
        
        mv "$REMARKABLE_BG_DIR/$file.bak" "$REMARKABLE_BG_DIR/$file"
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
                install_carousels
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
            echo -e "${BLUE}kay, bye!${RESET}"
            echo
            exit 0
            ;;
        *)
            echo -e "${RED}✗ invalid option!${RESET}"
            echo -e "${RED}plz run the script again and select 1-4${RESET}"
            echo
            exit 1
            ;;
    esac
}

main
