#!/bin/bash

# Update package database and upgrade system
echo "Updating and upgrading the system..."
sudo pacman -Syy --noconfirm
suod pacman -S archlinux-keyring --noconfirm
sudo pacman -Syu --noconfirm

# Clean up unused packages and cache
echo "Cleaning up..."
sudo pacman -Rns $(pacman -Qdtq) --noconfirm
sudo pacman -Sc --noconfirm

echo "System is up to date!"

#####################
# Download packages #
#####################
echo "Downloading packages..."
sudo pacman -S vim zsh unzip curl fuse2 wget vlc ufw obsidian htop fastfetch discord android-tools libreoffice-fresh docker docker-compose docker-buildx qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode ebtables iptables libguestfs --noconfirm

echo "Packages downloaded"

###########################################
# Give permissions for docker and libvirt #
###########################################
echo "Adding user permissions for docker and vir-manager"
sudo usermod -aG docker $USER
sudo usermod -aG libvirt $USER

newgrp docker
newgrp libvirt

echo "Permissions set"

##############################
# Downloading Jetbrains mono #
##############################
echo "Downloading jetbrains mono font"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
echo "Jetbrains mono setup complete"

#############################################
# Setting up terminal with starship and zsh #
#############################################
echo "Setting up terminal"
echo "Downloading starship"
sudo curl -sS https://starship.rs/install.sh | sh

echo "Starship downloaded, moving files from github to the right directories..."
mv ~/LinuxSetup/.zshrc ..
mv ~/LinuxSetup/starship.toml ~/.config/

echo "Installing autosuggestions for zsh"
mkdir ~/.config/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/.zsh/zsh-autosuggestions

echo "Setting zsh as default"
chsh

################
# Setup cursor #
################
echo "Setting up cursor"

mkdir ~/AppImages
mkdir ~/.local/share/applications

mv ~/Downloads/*.AppImage ~/AppImages/cursor/cursor.AppImage
mv ~/LinuxSetup/cursor_icon.jpg ~/AppImages/cursor/

CURSOR_DESKTOP_FILE="$HOME/.local/share/applications/cursor.desktop"

cat > "$CURSOR_DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=Cursor
Exec=/home/flo/AppImages/cursor/cursor.AppImage
Icon=/home/flo/AppImages/cursor/cursor_icon.jpg
Type=Application
Categories=Utility;
EOL

chmod +x "$CURSOR_DESKTOP_FILE"
echo "Cursor setup complete"

##########################################################################
# Set battery threshold service so that battery is only charged till 60% #
##########################################################################
echo "Setting up threshold service for battery"

BATTERY_NAME=$(ls /sys/class/power_supply | grep BAT)

if [ -z "$BATTERY_NAME" ]; then
    echo "No battery detected. Exiting..."
    exit 1
fi

THRESHOLD_PATH="/sys/class/power_supply/${BATTERY_NAME}/charge_control_end_threshold"

if [ ! -f "$THRESHOLD_PATH" ]; then
    echo "Battery threshold control is not supported on this laptop."
    exit 1
fi

echo "Battery detected: $BATTERY_NAME"
echo "Battery threshold control is supported."

# Create the systemd service file
SERVICE_FILE="/etc/systemd/system/battery-charge-threshold.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Set the battery charge threshold
After=multi-user.target
StartLimitBurst=0

[Service]
Type=oneshot
Restart=on-failure
ExecStart=/bin/bash -c 'echo 60 > /sys/class/power_supply/$BATTERY_NAME/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
sudo systemctl enable battery-charge-threshold.service
sudo systemctl start battery-charge-threshold.service

# Verify the service
BATTERY_STATUS=$(cat /sys/class/power_supply/${BATTERY_NAME}/status)
echo "Battery status: $BATTERY_STATUS"

echo "To apply changes to the threshold, edit the service file at $SERVICE_FILE and restart the service with:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart battery-charge-threshold.service"
