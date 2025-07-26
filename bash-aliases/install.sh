#!/bin/bash
# Claude Flow Aliases Installation Script

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Claude Flow Aliases Installer${NC}"
echo "=============================="

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

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ALIASES_FILE="$SCRIPT_DIR/claude-flow-aliases.sh"

# Check if aliases file exists
if [ ! -f "$ALIASES_FILE" ]; then
    echo -e "${RED}Error: claude-flow-aliases.sh not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Detect shell config file
SHELL_CONFIG=$(detect_shell_config)
echo -e "Detected shell configuration file: ${YELLOW}$SHELL_CONFIG${NC}"

# Check if aliases are already installed
if grep -q "claude-flow-aliases.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}Claude Flow aliases appear to be already installed.${NC}"
    read -p "Do you want to reinstall? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    # Remove existing installation
    sed -i.bak '/# Claude Flow Aliases/,/claude-flow-aliases\.sh"/d' "$SHELL_CONFIG"
    echo "Removed existing installation."
fi

# Create backup of shell config
cp "$SHELL_CONFIG" "${SHELL_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo "Created backup of $SHELL_CONFIG"

# Add source command to shell config
echo "" >> "$SHELL_CONFIG"
echo "# Claude Flow Aliases" >> "$SHELL_CONFIG"
echo "if [ -f \"$ALIASES_FILE\" ]; then" >> "$SHELL_CONFIG"
echo "    source \"$ALIASES_FILE\"" >> "$SHELL_CONFIG"
echo "fi" >> "$SHELL_CONFIG"

echo -e "${GREEN}✓ Aliases installed successfully!${NC}"
echo ""
echo "To start using the aliases, either:"
echo "  1. Restart your terminal, or"
echo "  2. Run: source $SHELL_CONFIG"
echo ""
echo "Type 'cfhelp' to see available aliases and commands."
echo ""
echo "Example usage:"
echo "  cf                           # Run claude-flow"
echo "  cfswarm 'Build a REST API'   # Start a swarm with objective"
echo "  cfhive 'Optimize database'   # Start hive-mind with objective"
