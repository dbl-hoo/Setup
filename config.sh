
#!/bin/bash

#   ____             __ _                       _   _             
#  / ___|___  _ __  / _(_) __ _ _   _ _ __ __ _| |_(_) ___  _ __  
# | |   / _ \| '_ \| |_| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \ 
# | |__| (_) | | | |  _| | (_| | |_| | | | (_| | |_| | (_) | | | |
#  \____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|
#                         |___/                                   
# by Stephan Raabe (2023)
# ------------------------------------------------------
clear
keyboardlayout="de-latin1"
zoneinfo="Europe/Berlin"
hostname="arch"
username="raabe"

# ------------------------------------------------------
# Set System Time
# ------------------------------------------------------
ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc

# ------------------------------------------------------
# Update reflector
# ------------------------------------------------------
echo "Start reflector..."
reflector -c "US," -p https -a 3 --sort rate --save /etc/pacman.d/mirrorlist

# ------------------------------------------------------
# Synchronize mirrors
# ------------------------------------------------------
pacman -Syy

# ------------------------------------------------------
# Install Packages
# ------------------------------------------------------
pacman -S --noconfirm  base-devel linux-headers grub efibootmgr networkmanager git xdg-{utils,user-dirs} pipewire pipewire-{alsa,jack,media-session,pulse} alsa-utils acpi acpi_call bluez bluez-utils bash-completion wpa_supplicant openssh spotify-launcher cups hplip pyqt5 needrestart eza pacman-contrib xorg-xhost vivaldi kitty qt5-wayland qt6-waylandand snap-pac grub-brtfs tlpui gnome-polkit waybar ttf-font-awesome variety pavucontrol tlp libnotify swayidle sddm blueman clight font-manager

# ------------------------------------------------------
# set lang utf8 US
# ------------------------------------------------------
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# ------------------------------------------------------
# Set Keyboard
# ------------------------------------------------------
echo "FONT=ter-v18n" >> /etc/vconsole.conf
echo "KEYMAP=$keyboardlayout" >> /etc/vconsole.conf

# ------------------------------------------------------
# Set hostname and localhost
# ------------------------------------------------------
echo "$hostname" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts
clear

# ------------------------------------------------------
# Set Root Password
# ------------------------------------------------------
echo "Set root password"
passwd root

# ------------------------------------------------------
# Add User
# ------------------------------------------------------
echo "Add user $username"
useradd -m -G wheel $username
passwd $username

[stopped]

# ------------------------------------------------------
# Enable Services
# ------------------------------------------------------
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid

# ------------------------------------------------------
# Grub installation
# ------------------------------------------------------
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable
grub-mkconfig -o /boot/grub/grub.cfg

# ------------------------------------------------------
# Add btrfs and setfont to mkinitcpio
# ------------------------------------------------------
# Before: BINARIES=()
# After:  BINARIES=(btrfs setfont)
sed -i 's/BINARIES=()/BINARIES=(btrfs setfont)/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

# ------------------------------------------------------
# Add user to wheel
# ------------------------------------------------------
clear
echo "Uncomment %wheel group in sudoers (around line 85):"
echo "Before: #%wheel ALL=(ALL:ALL) ALL"
echo "After:  %wheel ALL=(ALL:ALL) ALL"
echo ""
read -p "Open sudoers now?" c
EDITOR=vim sudo -E visudo
usermod -aG wheel $username

# ------------------------------------------------------
# Copy installation scripts to home directory 
# ------------------------------------------------------
cp /archinstall/3-yay.sh /home/$username
cp /archinstall/4-zram.sh /home/$username
cp /archinstall/5-timeshift.sh /home/$username
cp /archinstall/6-preload.sh /home/$username
cp /archinstall/snapshot.sh /home/$username

clear
echo "     _                   "
echo "  __| | ___  _ __   ___  "
echo " / _' |/ _ \| '_ \ / _ \ "
echo "| (_| | (_) | | | |  __/ "
echo " \__,_|\___/|_| |_|\___| "
echo "                         "
echo ""
