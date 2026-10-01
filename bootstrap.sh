#!/bin/bash

# Bootstrap script - downloaded via curl
# This script clones the repository and runs the actual installer

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Arch Setup - Desktop Installer     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git not found, installing...${NC}"
    sudo pacman -S --noconfirm git
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
echo -e "${BLUE}Downloading repository to $TEMP_DIR...${NC}"

# Clone repository
if ! git clone https://github.com/Bak0/wkstationz.git "$TEMP_DIR"; then
    echo -e "${RED}Failed to clone repository${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "${GREEN}✓ Repository downloaded${NC}"
echo ""

# Run the actual installer
cd "$TEMP_DIR"
./install.sh

# Cleanup
cd /
rm -rf "$TEMP_DIR"
echo ""
echo -e "${GREEN}✓ Cleanup complete${NC}"
