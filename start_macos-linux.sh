#!/usr/bin/env bash

# reMarkable Wallpaper Manager - Installation Script
# Copies wallpaper manager to your reMarkable tablet
# For updates: https://github.com/ambercaravalho/rM-Wallpaper-Manager

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color and formatting definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;96m"
YELLOW="\033[0;93m"
RED="\033[0;31m"
RESET="\033[0m"
SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Functions
show_header() {
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}    reMarkable Wallpaper Manager${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
}

show_important_info() {
    echo -e "${YELLOW}${BOLD}Before You Start:${RESET}"
    echo
    echo -e "${YELLOW}Paper Pro users:${RESET} Enable developer mode first"
    echo -e "  ${BLUE}→ https://support.remarkable.com/s/article/Developer-mode${RESET}"
    echo
    echo -e "${YELLOW}Security recommendation:${RESET} Enable device encryption"
    echo -e "  Settings → Security → Data Protection"
    echo
}

check_prerequisites() {
    if [[ ! -d "rm-background-manager" ]]; then
        echo -e "${RED}${BOLD}✗ Error:${RESET} Missing rm-background-manager folder${RESET}"
        echo -e "${RED}  Please run this script from the repository root directory${RESET}"
        exit 1
    fi
}

# List of background files
BACKGROUND_FILES=(
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

# Device resolution constants
RM1_WIDTH=1404
RM1_HEIGHT=1872
RM2_WIDTH=1404
RM2_HEIGHT=1872
RMPRO_WIDTH=1872
RMPRO_HEIGHT=2404
RMPRO_MOVE_WIDTH=1696
RMPRO_MOVE_HEIGHT=954

# Function to check if ImageMagick is installed
check_imagemagick() {
    if ! command -v convert &>/dev/null; then
        echo -e "${YELLOW}${BOLD}Note:${RESET} ImageMagick not found${RESET}"
        echo -e "${YELLOW}Images won't be automatically converted/resized${RESET}"
        echo
        echo -e "To install ImageMagick:"
        echo -e "  ${BLUE}macOS:${RESET} brew install imagemagick"
        echo -e "  ${BLUE}Linux:${RESET} sudo apt-get install imagemagick"
        echo
        read -rp "Continue anyway? (y/N): " CONTINUE
        if [[ ! "${CONTINUE,,}" =~ ^(y|yes)$ ]]; then
            echo -e "${BLUE}Installation cancelled${RESET}"
            exit 0
        fi
        return 1
    fi
    return 0
}

# Function to convert and resize image
convert_and_resize_image() {
    local source="$1"
    local destination="$2"
    local device_width="$3"
    local device_height="$4"
    
    if ! command -v convert &>/dev/null; then
        cp "$source" "$destination"
        return
    fi
    
    echo -e "${BLUE}  Processing image...${RESET}"
    
    if convert "$source" -resize "${device_width}x${device_height}" \
        -background white -gravity center -extent "${device_width}x${device_height}" \
        "$destination" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Image converted successfully${RESET}"
    else
        echo -e "${YELLOW}  Warning: Conversion failed, copying original${RESET}"
        cp "$source" "$destination"
    fi
}

# Function to display installation mode menu
display_mode_menu() {
    echo -e "${BOLD}Choose Installation Mode:${RESET}"
    echo
    echo -e "${BOLD}1.${RESET} Guided - Select images interactively"
    echo -e "${BOLD}2.${RESET} Manual - Use pre-prepared images"
    echo -e "${BOLD}3.${RESET} Exit"
    echo
    read -rp "Your choice (1-3): " MODE_CHOICE
}

# Function to select device model
select_device_model() {
    echo -e "${BOLD}Select Your Device:${RESET}"
    echo
    echo -e "${BOLD}1.${RESET} reMarkable 1"
    echo -e "${BOLD}2.${RESET} reMarkable 2"
    echo -e "${BOLD}3.${RESET} reMarkable Paper Pro"
    echo -e "${BOLD}4.${RESET} reMarkable Paper Pro Move"
    echo
    read -rp "Your choice (1-4): " DEVICE_CHOICE
    
    case "$DEVICE_CHOICE" in
        1)
            echo -e "${GREEN}✓ reMarkable 1 selected${RESET}"
            DEVICE_WIDTH=$RM1_WIDTH
            DEVICE_HEIGHT=$RM1_HEIGHT
            ;;
        2)
            echo -e "${GREEN}✓ reMarkable 2 selected${RESET}"
            DEVICE_WIDTH=$RM2_WIDTH
            DEVICE_HEIGHT=$RM2_HEIGHT
            ;;
        3)
            echo -e "${GREEN}✓ reMarkable Paper Pro selected${RESET}"
            DEVICE_WIDTH=$RMPRO_WIDTH
            DEVICE_HEIGHT=$RMPRO_HEIGHT
            ;;
        4)
            echo -e "${GREEN}✓ reMarkable Paper Pro Move selected${RESET}"
            DEVICE_WIDTH=$RMPRO_MOVE_WIDTH
            DEVICE_HEIGHT=$RMPRO_MOVE_HEIGHT
            ;;
        *)
            echo -e "${YELLOW}Invalid selection, defaulting to reMarkable 2${RESET}"
            DEVICE_WIDTH=$RM2_WIDTH
            DEVICE_HEIGHT=$RM2_HEIGHT
            ;;
    esac
    echo
}

# Function to handle guided installation
guided_installation() {
    echo
    echo -e "${BOLD}${BLUE}Guided Wallpaper Setup${RESET}"
    echo -e "${BLUE}$SEPARATOR${RESET}"
    echo
    
    select_device_model
    
    local has_imagemagick=false
    check_imagemagick && has_imagemagick=true
    
    mkdir -p "rm-background-manager/custom-backgrounds"
    
    echo -e "${YELLOW}Tips:${RESET}"
    echo -e "  • Drag and drop image files into the terminal"
    echo -e "  • Type 'skip' to keep default background"
    [[ "$has_imagemagick" == true ]] && echo -e "  • Images will be auto-converted and resized"
    echo
    
    local added_count=0
    for bg_file in "${BACKGROUND_FILES[@]}"; do
        echo -e "${BOLD}${bg_file}${RESET}"
        echo -e "  $(get_description "$bg_file")"
        read -rp "  Image path (or 'skip'): " IMAGE_PATH
        
        [[ "${IMAGE_PATH,,}" == "skip" ]] && { echo -e "${YELLOW}  Skipped${RESET}\n"; continue; }
        
        IMAGE_PATH="${IMAGE_PATH//[\'\"]}"  # Remove quotes
        
        if [[ ! -f "$IMAGE_PATH" ]]; then
            echo -e "${RED}  ✗ File not found, skipping${RESET}\n"
            continue
        fi
        
        if [[ ! "$IMAGE_PATH" =~ \.(png|jpg|jpeg|gif|bmp|tiff)$ ]]; then
            echo -e "${RED}  ✗ Not a supported image format, skipping${RESET}\n"
            continue
        fi
        
        local dest_file="rm-background-manager/custom-backgrounds/$bg_file"
        convert_and_resize_image "$IMAGE_PATH" "$dest_file" "$DEVICE_WIDTH" "$DEVICE_HEIGHT"
        echo -e "${GREEN}  ✓ Added $bg_file${RESET}\n"
        ((added_count++))
    done
    
    if [[ $added_count -eq 0 ]]; then
        echo -e "${YELLOW}No images added. Please prepare images manually.${RESET}"
        exit 0
    fi
    
    echo -e "${GREEN}✓ Prepared $added_count custom background(s)${RESET}"
    echo
}

# Function to get description of each background type
get_description() {
    local file="$1"
    case "$file" in
        batteryempty.png) echo "Battery depleted screen" ;;
        factory.png) echo "Factory reset screen" ;;
        hibernate.png) echo "Deep sleep mode" ;;
        overheating.png) echo "Overheating warning" ;;
        poweroff.png) echo "Power off screen" ;;
        rebooting.png) echo "Reboot screen" ;;
        restart-crashed.png) echo "Crash recovery screen" ;;
        starting.png) echo "Boot/startup screen" ;;
        suspended.png) echo "Sleep/suspend screen" ;;
        *) echo "System background" ;;
    esac
}

copy_to_remarkable() {
    local ip="$1"
    
    echo
    echo -e "${BOLD}Copying files to reMarkable...${RESET}"
    echo -e "${YELLOW}Enter your SSH password when prompted${RESET}"
    echo -e "${YELLOW}(Find it in: Settings → Copyrights and licenses → GPLv3)${RESET}"
    echo
    
    if scp -r rm-background-manager "root@${ip}:/home/root/" 2>/dev/null; then
        return 0
    fi
    
    # SSH key error - try to fix
    echo -e "${YELLOW}Fixing SSH key issue...${RESET}"
    ssh-keygen -R "$ip" &>/dev/null
    
    if scp -r rm-background-manager "root@${ip}:/home/root/" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

connect_to_remarkable() {
    local ip="$1"
    
    echo
    echo -e "${GREEN}✓ Files copied successfully!${RESET}"
    echo
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}Next Steps${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
    echo -e "Once connected to your reMarkable:"
    echo -e "  ${BOLD}1.${RESET} cd /home/root/rm-background-manager"
    echo -e "  ${BOLD}2.${RESET} bash wallpaper-manager.sh"
    echo
    echo -e "${BOLD}Connecting via SSH...${RESET}"
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
            echo -e "${BLUE}Using manual mode with existing files${RESET}"
            echo
            ;;
        3)
            echo -e "${BLUE}Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option, defaulting to manual mode${RESET}"
            echo
            ;;
    esac
    
    read -rp "Enter your reMarkable's IP address: " REMARKABLE_IP
    
    if copy_to_remarkable "$REMARKABLE_IP"; then
        connect_to_remarkable "$REMARKABLE_IP"
    else
        echo
        echo -e "${RED}✗ Failed to copy files${RESET}"
        echo -e "${RED}Check your IP address and device connection${RESET}"
        exit 1
    fi
}

main