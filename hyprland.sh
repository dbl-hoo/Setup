#!/bin/bash

clear

echo "  _   _                  _                 _ ";
echo " | | | |_   _ _ __  _ __| | __ _ _ __   __| |";
echo " | |_| | | | | '_ \| '__| |/ _\` | '_ \ / _\` |";
echo " |  _  | |_| | |_) | |  | | (_| | | | | (_| |";
echo " |_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|";
echo "        |___/|_|                             ";

# -----------------------------------------------------
# Confirm Start
# -----------------------------------------------------
while true; do
    read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."
        break;;
        [Nn]* ) 
            exit;
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# -----------------------------------------------------
# Install zram
# -----------------------------------------------------

pacman --noconfirm -S hyprland qt5-wayland qt6-wayland xdg-desktop-portal-hyprland polkit-gnome
yay --noconfirm -S waybar-hyprland-cava-git swaync swww

echo "DONE!"


