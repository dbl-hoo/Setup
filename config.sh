#!/bin/bash
clear

# ------------------------------------------------------
# Set System Time
# ------------------------------------------------------
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
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
pacman --noconfirm -S grub mesa efibootmgr nano dracut vivaldi wpa_supplicant avahi nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call ipset acpid os-prober ntfs-3g terminus-font htop neofetch grub-btrfs xf86-video-amdgpu xf86-video-nouveau xf86-video-intel xf86-video-qxl man-db openssh pacman-contrib reflector sudo terminus-font brightnessctl pacman-contrib inxi
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
#echo "KEYMAP=$keyboardlayout" >> /etc/vconsole.conf
# ------------------------------------------------------
# Set hostname and localhost
# ------------------------------------------------------
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
clear
# ------------------------------------------------------
# Set Root Password
# ------------------------------------------------------
echo "Set root password"
passwd 
# ------------------------------------------------------
# Add User
# ------------------------------------------------------

useradd -m -G wheel kirkham
passwd kirkham
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
systemctl enable acpid


#Set a system-wide default editor (example: neovim) ...
echo "EDITOR=nano" > /etc/environment

useradd -m -G wheel -s /bin/bash kirkham

#Activate wheel group access for sudo ...
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

#set modules
MODULES=(crc32c-intel btrfs)

#set hooks
HOOKS=(base udev keyboard autodetect keymap consolefont modconf block filesystems fsck)

#create initramfs
dracut --hostonly --no-hostonly-cmdline /boot/initramfs-linux.img
dracut -N --force /boot/initramfs-linux-fallback.img

#install grub
grub-install --target=x86_64-efi --bootloader-id=Arch --efi-directory=/boot/efi/
grub-mkconfig -o /boot/grub/grub.cfg
sed -i '#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false' /etc/default/grub

clear
echo "     _                   "
echo "  __| | ___  _ __   ___  "
echo " / _' |/ _ \| '_ \ / _ \ "
echo "| (_| | (_) | | | |  __/ "
echo " \__,_|\___/|_| |_|\___| "
echo "                         "
echo ""

read -p "Press any key to resume ..."
reboot -h now
