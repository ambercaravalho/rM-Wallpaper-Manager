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
