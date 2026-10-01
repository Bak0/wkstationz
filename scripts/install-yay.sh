#!/bin/bash
# Install yay AUR helper

set -e

echo "Installing yay dependencies..."
sudo pacman -S --noconfirm --needed base-devel git

echo "Cloning yay..."
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git

echo "Building yay..."
cd yay
makepkg -si --noconfirm

echo "Cleaning up..."
cd /tmp
rm -rf yay

echo "yay installed successfully!"
