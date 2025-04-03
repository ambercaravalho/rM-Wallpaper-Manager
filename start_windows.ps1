# reMarkable Wallpaper Manager installer script for Windows
# Copies rm-background-manager folder to remote reMarkable tablet

# Define separator
$SEPARATOR = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Welcome header
Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host "        reMarkable Wallpaper Manager Installer" -ForegroundColor Cyan
Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host
Write-Host "Welcome to " -NoNewline
Write-Host "reMarkable Wallpaper Manager!" -ForegroundColor White
Write-Host "For updates and more information, visit:"
Write-Host "https://github.com/ambercaravalho/rM-Wallpaper-Manager" -ForegroundColor Cyan
Write-Host

# List of background files
$BACKGROUND_FILES = @(
    "batteryempty.png",
    "factory.png",
    "hibernate.png",
    "overheating.png",
    "poweroff.png",
    "rebooting.png",
    "restart-crashed.png",
    "starting.png",
    "suspended.png"
)

# Function to display installation mode menu
function Display-ModeMenu {
    Write-Host "Choose your installation mode:" -ForegroundColor White
    Write-Host "1. Guided Mode " -NoNewline -ForegroundColor White
    Write-Host "(Add your own images for each background type)" -ForegroundColor Cyan
    Write-Host "2. Manual Mode " -NoNewline -ForegroundColor White
    Write-Host "(Upload predefined images from custom-backgrounds folder)" -ForegroundColor Cyan
    Write-Host "3. Exit" -ForegroundColor White
    Write-Host
    
    $script:MODE_CHOICE = Read-Host "Enter your choice (1-3)"
}

# Function to handle guided installation
function Start-GuidedInstallation {
    Write-Host $SEPARATOR -ForegroundColor Cyan
    Write-Host "           Guided Wallpaper Setup" -ForegroundColor Cyan
    Write-Host $SEPARATOR -ForegroundColor Cyan
    Write-Host
    
    # Create custom-backgrounds directory if it doesn't exist
    $customBgPath = "rm-background-manager\custom-backgrounds"
    if (-Not (Test-Path -Path $customBgPath -PathType Container)) {
        New-Item -Path $customBgPath -ItemType Directory | Out-Null
        Write-Host "Created custom-backgrounds directory" -ForegroundColor Green
    }
    
    Write-Host "For each background type, provide the path to your custom image." -ForegroundColor Yellow
    Write-Host "You can drag and drop image files into the terminal window." -ForegroundColor Yellow
    Write-Host "Enter 'skip' to leave any background unchanged." -ForegroundColor Yellow
    Write-Host
    
    # Process each background file
    foreach ($bgFile in $BACKGROUND_FILES) {
        Write-Host "Background type: " -NoNewline -ForegroundColor White
        Write-Host $bgFile -ForegroundColor Cyan
        Write-Host "Description: " -NoNewline
        Write-Host (Get-BackgroundDescription $bgFile)
        Write-Host "Enter path to custom image or type 'skip':"
        $imagePath = Read-Host
        
        # Skip if user entered 'skip'
        if ($imagePath -eq "skip") {
            Write-Host "Skipping $bgFile" -ForegroundColor Yellow
            Write-Host
            continue
        }
        
        # Remove quotes if present (happens with drag and drop on some terminals)
        $imagePath = $imagePath -replace "[`"']", ""
        
        # Check if file exists
        if (-Not (Test-Path -Path $imagePath -PathType Leaf)) {
            Write-Host "Error: " -ForegroundColor Red -NoNewline
            Write-Host "File not found: $imagePath" -ForegroundColor Red
            Write-Host "Skipping this background type." -ForegroundColor Red
            Write-Host
            continue
        }
        
        # Check if it's an image file
        if ($imagePath -notmatch "\.(png|jpg|jpeg|PNG|JPG|JPEG)$") {
            Write-Host "Error: " -ForegroundColor Red -NoNewline
            Write-Host "Not an image file: $imagePath" -ForegroundColor Red
            Write-Host "Please provide a PNG or JPEG image file." -ForegroundColor Red
            Write-Host "Skipping this background type." -ForegroundColor Red
            Write-Host
            continue
        }
        
        # Copy the file to the custom-backgrounds folder with the correct name
        Copy-Item -Path $imagePath -Destination "$customBgPath\$bgFile"
        Write-Host "✓ Added custom image for $bgFile" -ForegroundColor Green
        Write-Host
    }
    
    Write-Host "✓ Success! " -ForegroundColor Green -NoNewline
    Write-Host "Custom backgrounds have been prepared." -ForegroundColor Green
    Write-Host "Now proceeding to copy files to your reMarkable tablet..." -ForegroundColor Yellow
    Write-Host
}

# Function to get description of each background type
function Get-BackgroundDescription {
    param(
        [string]$fileName
    )
    
    switch ($fileName) {
        "batteryempty.png" { "Shown when battery is completely depleted" }
        "factory.png" { "Factory reset screen" }
        "hibernate.png" { "Shown when device enters deep sleep mode" }
        "overheating.png" { "Warning screen when device overheats" }
        "poweroff.png" { "Shown when device is powering off" }
        "rebooting.png" { "Displayed during reboot process" }
        "restart-crashed.png" { "Shown after a system crash" }
        "starting.png" { "Boot/startup screen" }
        "suspended.png" { "Sleep/suspend mode screen" }
        default { "System background image" }
    }
}

# Important information section
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "• If you are using a reMarkable Paper Pro, you must enable developer mode:" -ForegroundColor Yellow
Write-Host "  https://support.remarkable.com/s/article/Developer-mode" -ForegroundColor Cyan
Write-Host "• On reMarkable 2 or Paper Pro, please enable full device encryption:" -ForegroundColor Yellow
Write-Host "  Settings > Security > Data Protection > Security Level" -ForegroundColor Yellow
Write-Host

Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host "                Installation Process" -ForegroundColor Cyan
Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host

# Check if rm-background-manager folder exists
if (-Not (Test-Path -Path "rm-background-manager" -PathType Container)) {
    Write-Host "Error: " -ForegroundColor Red -NoNewline
    Write-Host "rm-background-manager folder not found in current directory." -ForegroundColor Red
    Write-Host "Please redownload the repository from GitHub and run the start script again." -ForegroundColor Red
    exit 1
}

# Display mode menu and get user's choice
Display-ModeMenu

switch ($MODE_CHOICE) {
    "1" {
        # Guided Mode
        Start-GuidedInstallation
    }
    "2" {
        # Manual Mode - continue with original flow
        Write-Host "Proceeding with manual installation using existing files..." -ForegroundColor Yellow
        Write-Host
    }
    "3" {
        Write-Host "Exiting program." -ForegroundColor Cyan
        exit 0
    }
    default {
        Write-Host "Error: " -ForegroundColor Red -NoNewline
        Write-Host "Invalid option. Using Manual Mode by default." -ForegroundColor Red
        Write-Host
    }
}

# Get the IP address of the reMarkable
Write-Host "Step 1: " -NoNewline
Write-Host "Enter your device information"
$REMARKABLE_IP = Read-Host "Enter your reMarkable's IP address"

# Copy files to the reMarkable
Write-Host
Write-Host "Step 2: " -NoNewline
Write-Host "Copying files to your reMarkable tablet..."
Write-Host "Note: " -ForegroundColor Yellow -NoNewline
Write-Host "You'll need to enter the password when prompted (found in your device's settings)."

try {
    # Using pscp.exe (PuTTY SCP) which should be installed separately
    # Alternatively, users can install OpenSSH client feature in Windows 10/11
    $copySuccessful = $false
    
    if (Get-Command pscp.exe -ErrorAction SilentlyContinue) {
        try {
            pscp.exe -r rm-background-manager root@${REMARKABLE_IP}:/home/root/
            $copySuccessful = $true
        } catch {
            # Check if error message contains SSH key related errors
            if ($_.Exception.Message -match "key does not match|host key verification failed") {
                Write-Host "✗ SSH Key Error Detected: " -ForegroundColor Red -NoNewline
                Write-Host "Attempting to fix..." -ForegroundColor Red
                
                # Try to remove the old SSH key
                if (Get-Command ssh-keygen.exe -ErrorAction SilentlyContinue) {
                    ssh-keygen.exe -R $REMARKABLE_IP
                    Write-Host "Old SSH key removed. Retrying file copy..." -ForegroundColor Yellow
                    
                    # Retry the copy operation
                    pscp.exe -r rm-background-manager root@${REMARKABLE_IP}:/home/root/
                    $copySuccessful = $true
                } else {
                    throw "SSH key error detected but ssh-keygen.exe not found. Please remove the key manually."
                }
            } else {
                throw  # Re-throw the original exception
            }
        }
    } elseif (Get-Command scp.exe -ErrorAction SilentlyContinue) {
        try {
            scp.exe -r rm-background-manager root@${REMARKABLE_IP}:/home/root/
            $copySuccessful = $true
        } catch {
            # Check if error message contains SSH key related errors
            if ($_.Exception.Message -match "key does not match|host key verification failed") {
                Write-Host "✗ SSH Key Error Detected: " -ForegroundColor Red -NoNewline
                Write-Host "Attempting to fix..." -ForegroundColor Red
                
                # Try to remove the old SSH key
                if (Get-Command ssh-keygen.exe -ErrorAction SilentlyContinue) {
                    ssh-keygen.exe -R $REMARKABLE_IP
                    Write-Host "Old SSH key removed. Retrying file copy..." -ForegroundColor Yellow
                    
                    # Retry the copy operation
                    scp.exe -r rm-background-manager root@${REMARKABLE_IP}:/home/root/
                    $copySuccessful = $true
                } else {
                    throw "SSH key error detected but ssh-keygen.exe not found. Please remove the key manually."
                }
            } else {
                throw  # Re-throw the original exception
            }
        }
    } else {
        throw "Neither pscp.exe nor scp.exe was found. Please install PuTTY or OpenSSH Client."
    }
    
    Write-Host
    if ($copySuccessful) {
        Write-Host "✓ Success! " -ForegroundColor Green -NoNewline
        Write-Host "rm-background-manager has been installed to your reMarkable." -ForegroundColor Green
        Write-Host "Automatically connecting to your device using SSH..." -ForegroundColor Green
        Write-Host "Once connected, you can:" -ForegroundColor Yellow
        Write-Host "  • Navigate to the folder:" -ForegroundColor Yellow -NoNewline
        Write-Host " cd /home/root/rm-background-manager" -ForegroundColor White
        Write-Host "  • Run the application:" -ForegroundColor Yellow -NoNewline
        Write-Host " bash wallpaper-manager.sh" -ForegroundColor White
        Write-Host
        Write-Host $SEPARATOR -ForegroundColor Cyan
        Write-Host "             Connecting to reMarkable..." -ForegroundColor Cyan
        Write-Host $SEPARATOR -ForegroundColor Cyan
        Write-Host
        
        # Connect via SSH
        if (Get-Command ssh.exe -ErrorAction SilentlyContinue) {
            ssh.exe root@$REMARKABLE_IP
        } elseif (Get-Command plink.exe -ErrorAction SilentlyContinue) {
            plink.exe -ssh root@$REMARKABLE_IP
        } else {
            Write-Host "✗ Warning: " -ForegroundColor Yellow -NoNewline
            Write-Host "SSH client not found (ssh.exe or plink.exe)." -ForegroundColor Yellow
            Write-Host "Please connect manually using an SSH client with:" -ForegroundColor Yellow
            Write-Host "  Host: root@$REMARKABLE_IP" -ForegroundColor White
        }
    } else {
        throw "File copy operation failed."
    }
} catch {
    Write-Host
    Write-Host "✗ Error: " -ForegroundColor Red -NoNewline
    Write-Host "Failed to copy files to the reMarkable." -ForegroundColor Red
    Write-Host "Please check the IP address and make sure your tablet is connected to your computer." -ForegroundColor Red
    Write-Host "Technical error: $_" -ForegroundColor Red
}
