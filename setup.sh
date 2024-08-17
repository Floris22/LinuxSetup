#!/bin/bash

# First update and upgrade
sudo apt update && sudo apt upgrade -y

# Installing some packages
echo "Installing zsh, git, python, vlc and flatpak"
sudo apt install -y zsh git python3 python3-pip python3-venv vlc flatpak

# Flatpak setup
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installing flatpaks
echo "Installing flatpaks..."

flatpak install flathub com.discordapp.Discord
flatpak install flathub com.brave.Browser
flatpak install flathub org.onlyoffice.desktopeditors

####################
## DOCKER INSTALL ##
####################

echo "Installing docker"
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Install docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Checking docker version"
docker --version

echo "Adding user to Docker group"
sudo usermod -aG docker $USER

###############################
## BATTERY TRHESHOLD SERVICE ##
###############################

# Check if the battery threshold file exists to ensure compatibility
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

# Prompt user for the charge stop threshold
read -p "Enter the desired charge stop threshold (e.g., 60, 80, 100): " CHARGE_STOP_THRESHOLD

# Validate the input
if ! [[ "$CHARGE_STOP_THRESHOLD" =~ ^[0-9]+$ ]] || [ "$CHARGE_STOP_THRESHOLD" -lt 0 ] || [ "$CHARGE_STOP_THRESHOLD" -gt 100 ]; then
    echo "Invalid charge stop threshold. Please enter a number between 0 and 100."
    exit 1
fi

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
ExecStart=/bin/bash -c 'echo $CHARGE_STOP_THRESHOLD > /sys/class/power_supply/$BATTERY_NAME/charge_control_end_threshold'

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

#############################
## VIRTUAL MACHINE MANAGER ##
#############################

# Update package lists and upgrade existing packages
echo "Updating package lists and upgrading existing packages..."
sudo apt update && sudo apt upgrade -y

# Install KVM and related packages
echo "Installing KVM and related packages..."
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Verify KVM installation
echo "Verifying KVM installation..."
sudo systemctl status libvirtd

# Add current user to libvirt and kvm groups
echo "Adding current user to libvirt and kvm groups..."
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

# Install Virtual Machine Manager
echo "Installing Virtual Machine Manager..."
sudo apt install -y virt-manager

# Enable and start the libvirtd service
echo "Enabling and starting the libvirtd service..."
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Print completion message
echo "Installation complete. You may need to log out and log back in for the group changes to take effect."

# Check if the system supports hardware virtualization
echo "Checking if the system supports hardware virtualization..."
if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
    echo "Hardware virtualization is supported on this system."
else
    echo "Hardware virtualization is not supported on this system."
fi

echo "You can now launch Virtual Machine Manager using 'virt-manager' command."
