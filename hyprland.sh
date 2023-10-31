#!/bin/bash
clear

echo "  _   _                  _                    _ ";
echo " | | | |_   _ _ __  _ __| |    __ _ _ __   __| |";
echo " | |_| | | | | '_ \| '__| |   / _\` | '_ \ / _\` |";
echo " |  _  | |_| | |_) | |  | |__| (_| | | | | (_| |";
echo " |_| |_|\__, | .__/|_|  |_____\__,_|_| |_|\__,_|";
echo "        |___/|_|                                ";
# -----------------------------------------------------
# Confirm Start
# -----------------------------------------------------
#
echo ""
echo "WELCOME TO THE HYPRLAND STARTER INSTALLATION SCRIPT"
echo "------------------------------------------------------"
echo ""
echo ""
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

sudo pacman -S hyprland ttf-font-awesome waybar kitty alacritty thunar xdg-desktop-portal-hyprland qt5-wayland qt6-wayland 
yay -S swaync rofi-lbonn-wayland polkit-dumb-agent-git
