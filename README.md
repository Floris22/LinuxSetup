# LinuxSetup

## What to download

- Firstly, download the cursor AppImage from their website (could not automate that...)
- Clone this repo in your $HOME
- run setup.sh
- configure your libvirtd

1. sudo vim /etc/libvirt/libvirtd.conf
2. Uncomment the following lines
  - unix_sock_group = "libvirt"
  - unix_sock_rw_perms = "0770"
3. You might have to add your user to the libvirt group again (sudo usermod -aG libvirt $USER)
