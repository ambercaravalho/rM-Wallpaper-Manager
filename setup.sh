#!/usr/bin/env bash

# reMarkable wallpaper manager, computer side
# https://github.com/ambercaravalho/rM-Wallpaper-Manager

set -euo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;96m"
YELLOW="\033[0;93m"
RED="\033[0;31m"
RESET="\033[0m"
SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BACKGROUND_FILES=(
    "batteryempty.png"
    "factory.png"
    "overheating.png"
    "poweroff.png"
    "rebooting.png"
    "remotewipe.png"
    "restart-crashed.png"
    "starting.png"
    "suspended.png"
)

show_header() {
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}    reMarkable wallpaper manager (computer side)${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
}

show_important_info() {
    echo -e "${YELLOW}${BOLD}before u start:${RESET}"
    echo
    echo -e "${YELLOW}for Paper Pro (or Move):${RESET} enable developer mode first!"
    echo -e "  ${BLUE}→ https://support.remarkable.com/s/article/Developer-mode${RESET}"
    echo
    echo -e "${YELLOW}for everyone (especially reMarkable 2):${RESET} enable device encryption!"
    echo -e "  > Settings → Security → Data Protection → Security level"
    echo
}

check_prerequisites() {
    if [[ ! -d "device" ]]; then
        echo -e "${RED}${BOLD}✗ error:${RESET} missing device folder!!${RESET}"
        echo -e "${RED}  please run this script from the repo's root directory${RESET}"
        exit 1
    fi
}

display_mode_menu() {
    echo -e "${BOLD}choose the install mode:${RESET}"
    echo
    echo -e "${BOLD}1.${RESET} guided - select images interactively"
    echo -e "${BOLD}2.${RESET} manual - use pre-prepared images"
    echo -e "${BOLD}3.${RESET} exit"
    echo
    read -rp "ur choice (1-3): " MODE_CHOICE
}

guided_installation() {
    echo
    echo -e "${BOLD}${BLUE}               guided wallpaper setup${RESET}"
    echo -e "${BLUE}$SEPARATOR${RESET}"
    echo
    
    mkdir -p "device/bg"
    
    echo -e "${YELLOW}tips:${RESET}"
    echo -e "  • you can drag and drop ur files into the terminal window"
    echo -e "  • type 'skip' to keep the default background"
    echo
    
    local added_count=0

    for bg_file in "${BACKGROUND_FILES[@]}"; do
        echo -e "${BOLD}${bg_file}${RESET}"
        read -rp "  image path (or 'skip'): " IMAGE_PATH
        
        [[ "${IMAGE_PATH,,}" == "skip" ]] && { echo -e "${YELLOW}  skipped${RESET}\n"; continue; }
        
        IMAGE_PATH="${IMAGE_PATH//[\'\"]}"
        
        if [[ ! -f "$IMAGE_PATH" ]]; then
            echo -e "${RED}  ✗ file not found, skipping${RESET}\n"
            continue
        fi
        
        if [[ ! "$IMAGE_PATH" =~ \.(png)$ ]]; then
            echo -e "${RED}  ✗ not a .PNG image file, skipping${RESET}\n"
            continue
        fi
        
        local dest_file="device/bg/$bg_file"
        echo -e "${GREEN}  ✓ added $bg_file${RESET}\n"
        ((added_count++))
    done
    
    if [[ $added_count -eq 0 ]]; then
        echo -e "${YELLOW}no images added. please prepare images manually.${RESET}"
        exit 0
    fi
    
    echo -e "${GREEN}✓ prep'd $added_count background(s)${RESET}"
    echo
}

copy_to_remarkable() {
    local ip="$1"
    
    echo
    echo -e "${BOLD}copying files to reMarkable...${RESET}"
    echo -e "${YELLOW}enter your SSH password when prompted${RESET}"
    echo -e "${YELLOW}(you can find it in: Settings → Help → Copyrights and licenses → GPLv3 Compliance)${RESET}"
    echo
    
    if scp -r device "root@${ip}:/home/root/" 2>/dev/null; then
        return 0
    fi
    
    echo -e "${YELLOW}fixing SSH key issue...${RESET}"
    ssh-keygen -R "$ip" &>/dev/null
    
    if scp -r device "root@${ip}:/home/root/" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

connect_to_remarkable() {
    local ip="$1"
    
    echo
    echo -e "${GREEN}✓ files copied successfully!${RESET}"
    echo
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}next steps${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
    echo -e "once connected to your reMarkable:"
    echo -e "  ${BOLD}1.${RESET} cd /home/root/device"
    echo -e "  ${BOLD}2.${RESET} bash run.sh"
    echo
    echo -e "${BOLD}connecting via SSH...${RESET}"
    echo
    
    ssh "root@${ip}"
}

# Main execution
main() {
    show_header
    show_important_info
    check_prerequisites
    
    display_mode_menu
    
    case "$MODE_CHOICE" in
        1)
            guided_installation
            ;;
        2)
            echo -e "${BLUE}using manual mode with existing files${RESET}"
            echo
            ;;
        3)
            echo -e "${BLUE}love u, goodbye!!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}invalid option, defaulting to guided mode${RESET}"
            echo
            ;;
    esac
    
    read -rp "enter your reMarkable's IP address: " REMARKABLE_IP
    
    if copy_to_remarkable "$REMARKABLE_IP"; then
        connect_to_remarkable "$REMARKABLE_IP"
    else
        echo
        echo -e "${RED}✗ failed to copy files!${RESET}"
        echo -e "${RED}check your IP address and device connection${RESET}"
        exit 1
    fi
}

main