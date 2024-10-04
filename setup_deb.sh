#!/bin/bash

# Echo function
echo_custom(s) {
    echo "============================================"
    echo $s
    echo "============================================"
}

# Update package list
echo_custom "Updating package list"
sudo apt update
sudo apt upgrade -y

# Install necessary dependencies
echo_custom "Installing necessary dependencies"
sudo apt install -y python3-virtualenv unzip curl fuse2 wget vlc ufw htop fastfetch

#########################################################
## Install virtual machine manager
#########################################################
echo_custom "Installing virtual machine manager"
sudo apt install -y qemu virt-manager virt-viewer dnsmasq bridge-utils dmidecode

# Add user to libvirt group
sudo usermod -aG libvirt $USER

#########################################################
## Install docker
#########################################################

echo_custom "Installing docker"
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add docker to sudo group
sudo usermod -aG docker $USER

#########################################################
## Jetbrains mono font
#########################################################

echo_custom "Installing Jetbrains mono font"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

#########################################################
## Setting up terminal
#########################################################

echo_custom "Setting up terminal"
echo_custom "Downloading starship"

# Starship
sudo curl -sS https://starship.rs/install.sh | sh

# Add custom functions and eval to .bashrc
echo_custom "Adding custom functions and eval to .bashrc"
cat >> ~/.bashrc <<EOL
cd() {
    builtin cd "$@" && ls -lh --color
}

# create dir and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# extract func
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# find file using pattern
ff() {
    find . -type f -iname '*'"$*"'*' -ls
}

# Aliases
alias ls='ls --color'
alias ytd=~/AppImages/ytd/yt.sh

# Exports
echo 'eval "$(starship init bash)"' >> ~/.bashrc
EOL

# Reload .bashrc
source ~/.bashrc
echo_custom "Done setting up terminal"

#########################################################
## Cursor
#########################################################

echo_custom "Installing Cursor"

chmod +x cursor_setup.sh
./cursor_setup.sh

echo_custom "Done installing Cursor"

#########################################################
## Setting up ytd
#########################################################

echo_custom "Setting up ytd"

chmod +x ytd/yt.sh

if [ -z "ytd/.venv" ]; then
    echo_custom "Setting up virtual environment"
    python3 -m venv ytd/.venv
    source ytd/.venv/bin/activate
    pip install -r ytd/requirements.txt
fi

echo_custom "Done setting up ytd"

#########################################################
## Setting up battery limit threshold
#########################################################

echo_custom "Setting up battery limit threshold"

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

echo_custom "Done setting up battery limit threshold"

#########################################################
## Setting up ufw
#########################################################

echo_custom "Setting up ufw"

sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo_custom "Done setting up ufw"
