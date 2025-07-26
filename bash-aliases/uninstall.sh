#!/bin/bash
# Claude Flow Aliases Uninstallation Script

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Claude Flow Aliases Uninstaller${NC}"
echo "================================"

# Detect shell configuration file
detect_shell_config() {
    if [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            echo "$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.bashrc"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            echo "$HOME/.zshrc"
        else
            echo "$HOME/.zshrc"
        fi
    else
        echo "$HOME/.bashrc"
    fi
}

# Detect shell config file
SHELL_CONFIG=$(detect_shell_config)
echo -e "Detected shell configuration file: ${YELLOW}$SHELL_CONFIG${NC}"

# Check if aliases are installed
if ! grep -q "claude-flow-aliases.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}Claude Flow aliases are not installed in $SHELL_CONFIG${NC}"
    exit 0
fi

# Confirm uninstallation
read -p "Are you sure you want to uninstall Claude Flow aliases? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Create backup before removing
cp "$SHELL_CONFIG" "${SHELL_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo "Created backup of $SHELL_CONFIG"

# Remove aliases from shell config
sed -i.bak '/# Claude Flow Aliases/,/claude-flow-aliases\.sh"/d' "$SHELL_CONFIG"

# Clean up empty lines if any
sed -i '/^$/N;/^\n$/d' "$SHELL_CONFIG"

echo -e "${GREEN}✓ Claude Flow aliases uninstalled successfully!${NC}"
echo ""
echo "The aliases will no longer be available in new terminal sessions."
echo "To remove them from the current session, restart your terminal."
