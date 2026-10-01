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

# Working directory
WORK_DIR="/tmp/wkstationz-work"

# Clean up any existing work directory
if [ -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}Cleaning up previous work directory...${NC}"
    rm -rf "$WORK_DIR"
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git not found, installing...${NC}"
    sudo pacman -S --noconfirm git
fi

# Create work directory
mkdir -p "$WORK_DIR"
echo -e "${BLUE}Setting up work directory: $WORK_DIR${NC}"

# Clone repository
echo -e "${BLUE}Downloading repository...${NC}"
if ! git clone https://github.com/Bak0/wkstationz.git "$WORK_DIR" 2>/dev/null; then
    echo -e "${RED}Failed to clone repository${NC}"
    rm -rf "$WORK_DIR"
    exit 1
fi

echo -e "${GREEN}✓ Repository downloaded${NC}"
echo ""

# Run the installer from work directory with terminal input
cd "$WORK_DIR"
./install.sh < /dev/tty
EXIT_CODE=$?

# Cleanup
cd /
rm -rf "$WORK_DIR"
echo ""
echo -e "${GREEN}✓ Cleanup complete${NC}"

exit $EXIT_CODE
