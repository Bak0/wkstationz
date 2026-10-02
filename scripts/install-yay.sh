#!/bin/bash
# Install yay AUR helper

set -e

echo "Installing yay dependencies..."
sudo pacman -S --noconfirm --needed base-devel git

echo "Cloning yay..."
cd /tmp
YAY_BUILD_DIR=$(mktemp -d /tmp/wkstationz-yay.XXXXXX)
git clone https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR"

echo "Building yay..."
cd "$YAY_BUILD_DIR"
makepkg -si --noconfirm

echo "Cleaning up..."
cd /
rm -rf "$YAY_BUILD_DIR"

echo "yay installed successfully!"
