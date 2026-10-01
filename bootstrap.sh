#!/bin/bash

# Bootstrap script - downloads and runs the installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Bak0/wkstationz/main/bootstrap.sh | bash

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
echo -e "${BLUE}Downloading repository...${NC}"

# Clone repository
if ! git clone https://github.com/Bak0/wkstationz.git "$TEMP_DIR" 2>/dev/null; then
    echo -e "${RED}Failed to clone repository${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "${GREEN}✓ Repository downloaded${NC}"
echo ""

# Run the installer (not piped, so stdin works normally)
cd "$TEMP_DIR"
./install.sh
EXIT_CODE=$?

# Cleanup
cd /
rm -rf "$TEMP_DIR"

exit $EXIT_CODE
