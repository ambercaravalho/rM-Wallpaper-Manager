#!/bin/bash

# reMarkable Wallpaper Manager installer script
# Copies rm-background-manager folder to remote reMarkable tablet

# Color and formatting definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
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

# Get the IP address of the reMarkable
echo -e "${BOLD}Step 1:${RESET} Enter your device information"
read -p "Enter your reMarkable's IP address: " REMARKABLE_IP

# Copy files to the reMarkable
echo
echo -e "${BOLD}Step 2:${RESET} Copying files to your reMarkable tablet..."
echo -e "${YELLOW}Note:${RESET} You'll need to enter the password when prompted (found in your device's settings)."
scp -r rm-background-manager root@$REMARKABLE_IP:/home/root/

# Check if the copy operation was successful
if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}${BOLD}✓ Success!${RESET} ${GREEN}rm-background-manager has been installed to your reMarkable.${RESET}"
    echo -e "${GREEN}Connect to your device using SSH to run the application.${RESET}"
else
    echo
    echo -e "${RED}${BOLD}✗ Error:${RESET} ${RED}Failed to copy files to the reMarkable.${RESET}"
    echo -e "${RED}Please check the IP address and make sure your tablet is connected to your computer.${RESET}"
fi