#!/bin/bash

# reMarkable Wallpaper Manager installer script
# Copies rm-background-manager folder to remote reMarkable tablet

# Color and formatting definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;96m"
YELLOW="\033[0;93m"
RED="\033[0;31m"
RESET="\033[0m"
SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Welcome header
echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
echo -e "${BOLD}${BLUE}        reMarkable Wallpaper Manager Installer${RESET}"
echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
echo
echo -e "Welcome to ${BOLD}reMarkable Wallpaper Manager!${RESET}"
echo -e "For updates and more information, visit:"
echo -e "${BLUE}https://github.com/ambercaravalho/rM-Wallpaper-Manager${RESET}"
echo

# Important information section
echo -e "${YELLOW}${BOLD}IMPORTANT:${RESET}"
echo -e "${YELLOW}• If you are using a reMarkable Paper Pro, you must enable developer mode:${RESET}"
echo -e "  ${BLUE}https://support.remarkable.com/s/article/Developer-mode${RESET}"
echo -e "${YELLOW}• On reMarkable 2 or Paper Pro, please enable full device encryption:${RESET}"
echo -e "  ${YELLOW}Settings > Security > Data Protection > Security Level${RESET}"
echo

echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
echo -e "${BOLD}${BLUE}                Installation Process${RESET}"
echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
echo

# Check if rm-background-manager folder exists
if [ ! -d "rm-background-manager" ]; then
    echo -e "${RED}${BOLD}Error:${RESET} ${RED}rm-background-manager folder not found in current directory.${RESET}"
    echo -e "${RED}Please redownload the repository from GitHub and run the start script again.${RESET}"
    exit 1
fi

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

# Function to check if ImageMagick is installed
check_imagemagick() {
    if ! command -v convert >/dev/null 2>&1; then
        echo -e "${YELLOW}${BOLD}Warning:${RESET} ${YELLOW}ImageMagick is not installed.${RESET}"
        echo -e "${YELLOW}Without ImageMagick, images cannot be automatically converted or resized.${RESET}"
        echo -e "${YELLOW}Please install ImageMagick for the best experience:${RESET}"
        echo -e "  ${BLUE}macOS:${RESET} brew install imagemagick"
        echo -e "  ${BLUE}Linux:${RESET} sudo apt-get install imagemagick"
        echo
        read -p "Continue without image conversion? (y/n): " CONTINUE
        if [[ $CONTINUE != "y" && $CONTINUE != "Y" ]]; then
            echo -e "${RED}Installation aborted.${RESET}"
            exit 1
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
    
    if ! check_imagemagick; then
        # Just copy the file if ImageMagick is not available
        cp "$source" "$destination"
        return
    fi
    
    echo -e "${BLUE}Converting and resizing image...${RESET}"
    
    # Convert to PNG and resize while maintaining aspect ratio
    convert "$source" -resize "${device_width}x${device_height}" \
        -background white -gravity center -extent "${device_width}x${device_height}" \
        "$destination"
        
    echo -e "${GREEN}Image processed successfully.${RESET}"
}

# Function to display installation mode menu
display_mode_menu() {
    echo -e "${BOLD}Choose your installation mode:${RESET}"
    echo -e "${BOLD}1.${RESET} Guided Mode ${BLUE}(Add your own images for each background type)${RESET}"
    echo -e "${BOLD}2.${RESET} Manual Mode ${BLUE}(Upload predefined images from custom-backgrounds folder)${RESET}"
    echo -e "${BOLD}3.${RESET} Exit"
    echo
    read -p "Enter your choice (1-3): " MODE_CHOICE
}

# Function to select device model
select_device_model() {
    echo -e "${BOLD}Select your reMarkable device model:${RESET}"
    echo -e "${BOLD}1.${RESET} reMarkable 1"
    echo -e "${BOLD}2.${RESET} reMarkable 2"
    echo -e "${BOLD}3.${RESET} reMarkable Paper Pro"
    echo
    read -p "Enter your choice (1-3): " DEVICE_CHOICE
    
    case "$DEVICE_CHOICE" in
        "1")
            echo -e "${GREEN}Selected: reMarkable 1${RESET}"
            DEVICE_WIDTH=$RM1_WIDTH
            DEVICE_HEIGHT=$RM1_HEIGHT
            ;;
        "2")
            echo -e "${GREEN}Selected: reMarkable 2${RESET}"
            DEVICE_WIDTH=$RM2_WIDTH
            DEVICE_HEIGHT=$RM2_HEIGHT
            ;;
        "3")
            echo -e "${GREEN}Selected: reMarkable Paper Pro${RESET}"
            DEVICE_WIDTH=$RMPRO_WIDTH
            DEVICE_HEIGHT=$RMPRO_HEIGHT
            ;;
        *)
            echo -e "${YELLOW}Invalid selection. Using reMarkable 2 dimensions by default.${RESET}"
            DEVICE_WIDTH=$RM2_WIDTH
            DEVICE_HEIGHT=$RM2_HEIGHT
            ;;
    esac
    echo
}

# Function to handle guided installation
guided_installation() {
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}           Guided Wallpaper Setup${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo
    
    # Select device model to set correct dimensions
    select_device_model
    
    # Check for ImageMagick
    HAS_IMAGEMAGICK=true
    check_imagemagick || HAS_IMAGEMAGICK=false
    
    # Create custom-backgrounds directory if it doesn't exist
    if [ ! -d "rm-background-manager/custom-backgrounds" ]; then
        mkdir -p "rm-background-manager/custom-backgrounds"
        echo -e "${GREEN}Created custom-backgrounds directory${RESET}"
    fi
    
    echo -e "${YELLOW}For each background type, provide the path to your custom image.${RESET}"
    echo -e "${YELLOW}You can drag and drop image files into the terminal window.${RESET}"
    echo -e "${YELLOW}Enter 'skip' to leave any background unchanged.${RESET}"
    if [ "$HAS_IMAGEMAGICK" = true ]; then
        echo -e "${GREEN}Images will be automatically converted to PNG and resized to fit your device.${RESET}"
    fi
    echo
    
    # Process each background file
    for bg_file in "${BACKGROUND_FILES[@]}"; do
        echo -e "${BOLD}Background type:${RESET} ${BLUE}$bg_file${RESET}"
        echo -e "Description: $(get_description "$bg_file")"
        echo -e "Enter path to custom image or type 'skip':"
        read -r IMAGE_PATH
        
        # Skip if user entered 'skip'
        if [ "$IMAGE_PATH" = "skip" ]; then
            echo -e "${YELLOW}Skipping $bg_file${RESET}"
            echo
            continue
        fi
        
        # Remove quotes if present (happens with drag and drop on some terminals)
        IMAGE_PATH=$(echo "$IMAGE_PATH" | tr -d "'\"")
        
        # Check if file exists
        if [ ! -f "$IMAGE_PATH" ]; then
            echo -e "${RED}${BOLD}Error:${RESET} ${RED}File not found: $IMAGE_PATH${RESET}"
            echo -e "${RED}Skipping this background type.${RESET}"
            echo
            continue
        fi
        
        # Check if it's an image file
        if [[ ! "$IMAGE_PATH" =~ \.(png|jpg|jpeg|PNG|JPG|JPEG|gif|GIF|bmp|BMP|tiff|TIFF)$ ]]; then
            echo -e "${RED}${BOLD}Error:${RESET} ${RED}Not a supported image file: $IMAGE_PATH${RESET}"
            echo -e "${RED}Please provide a supported image format.${RESET}"
            echo -e "${RED}Skipping this background type.${RESET}"
            echo
            continue
        fi
        
        # Destination file path
        DEST_FILE="rm-background-manager/custom-backgrounds/$bg_file"
        
        # Convert and resize image
        if [ "$HAS_IMAGEMAGICK" = true ]; then
            convert_and_resize_image "$IMAGE_PATH" "$DEST_FILE" "$DEVICE_WIDTH" "$DEVICE_HEIGHT"
        else
            # Just copy the file if ImageMagick is not available
            cp "$IMAGE_PATH" "$DEST_FILE"
        fi
        
        echo -e "${GREEN}${BOLD}✓${RESET} ${GREEN}Added custom image for $bg_file${RESET}"
        echo
    done
    
    echo -e "${GREEN}${BOLD}✓ Success!${RESET} ${GREEN}Custom backgrounds have been prepared.${RESET}"
    echo -e "${YELLOW}Now proceeding to copy files to your reMarkable tablet...${RESET}"
    echo
}

# Function to get description of each background type
get_description() {
    local file="$1"
    case "$file" in
        "batteryempty.png") echo "Shown when battery is completely depleted" ;;
        "factory.png") echo "Factory reset screen" ;;
        "hibernate.png") echo "Shown when device enters deep sleep mode" ;;
        "overheating.png") echo "Warning screen when device overheats" ;;
        "poweroff.png") echo "Shown when device is powering off" ;;
        "rebooting.png") echo "Displayed during reboot process" ;;
        "restart-crashed.png") echo "Shown after a system crash" ;;
        "starting.png") echo "Boot/startup screen" ;;
        "suspended.png") echo "Sleep/suspend mode screen" ;;
        *) echo "System background image" ;;
    esac
}

# Display mode menu and get user's choice
display_mode_menu

case "$MODE_CHOICE" in
    "1")
        # Guided Mode
        guided_installation
        ;;
    "2")
        # Manual Mode - continue with original flow
        echo -e "${YELLOW}Proceeding with manual installation using existing files...${RESET}"
        echo
        ;;
    "3")
        echo -e "${BLUE}Exiting program.${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}${BOLD}Error:${RESET} ${RED}Invalid option. Using Manual Mode by default.${RESET}"
        echo
        ;;
esac

# Get the IP address of the reMarkable
echo -e "${BOLD}Step 1:${RESET} Enter your device information"
read -p "Enter your reMarkable's IP address: " REMARKABLE_IP

# Copy files to the reMarkable
echo
echo -e "${BOLD}Step 2:${RESET} Copying files to your reMarkable tablet..."
echo -e "${YELLOW}Note:${RESET} You'll need to enter the password when prompted (found in your device's settings)."

scp -r rm-background-manager root@$REMARKABLE_IP:/home/root/
if [ $? -ne 0 ]; then
    echo -e "${RED}${BOLD}✗ SSH Key Error Detected:${RESET} ${RED}Attempting to fix...${RESET}"
    ssh-keygen -R $REMARKABLE_IP
    echo -e "${YELLOW}Old SSH key removed. Retrying file copy...${RESET}"
    scp -r rm-background-manager root@$REMARKABLE_IP:/home/root/
fi

# Check if the copy operation was successful
if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}${BOLD}✓ Success!${RESET} ${GREEN}rm-background-manager has been installed to your reMarkable.${RESET}"
    echo -e "${GREEN}Automatically connecting to your device using SSH...${RESET}"
    echo -e "${YELLOW}Once connected, you can:${RESET}"
    echo -e "  ${YELLOW}• Navigate to the folder:${RESET} cd /home/root/rm-background-manager"
    echo -e "  ${YELLOW}• Run the application:${RESET} bash wallpaper-manager.sh"
    echo
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo -e "${BOLD}${BLUE}             Connecting to reMarkable...${RESET}"
    echo -e "${BOLD}${BLUE}$SEPARATOR${RESET}"
    echo

    # Connect via SSH
    ssh root@$REMARKABLE_IP
else
    echo
    echo -e "${RED}${BOLD}✗ Error:${RESET} ${RED}Failed to copy files to the reMarkable.${RESET}"
    echo -e "${RED}Please check the IP address and make sure your tablet is connected to your computer.${RESET}"
fi