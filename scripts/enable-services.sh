#!/bin/bash
# Enable system services

set -e

echo "Enabling SDDM (display manager)..."
sudo systemctl enable sddm

echo "Enabling PulseAudio..."
systemctl --user enable pulseaudio
systemctl --user start pulseaudio

echo "Enabling swaync (notification daemon)..."
systemctl --user enable swaync
systemctl --user start swaync

echo "Services enabled successfully!"
