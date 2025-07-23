#!/bin/bash

# VMan Installation Script
# Installs the VMan virtual environment manager

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
VMAN_URL="https://raw.githubusercontent.com/yourusername/vman/main/vman.sh"
INSTALL_DIR="$HOME/.vman"
SHELL_CONFIG=""

# Detect shell configuration file
detect_shell_config() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
    else
        echo -e "${YELLOW}Warning: Unsupported shell. You'll need to manually source the script.${NC}"
        SHELL_CONFIG=""
    fi
}

# Print header
print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║        🐍 VMan Installer             ║"
    echo "║   Smart Virtual Environment Manager  ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check for Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Error: Python 3 is required but not installed.${NC}"
        exit 1
    fi
    
    # Check for venv module
    if ! python3 -m venv --help &> /dev/null; then
        echo -e "${RED}Error: Python venv module is not available.${NC}"
        echo "Please install python3-venv package."
        exit 1
    fi
    
    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        echo -e "${RED}Error: curl or wget is required for installation.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All prerequisites met${NC}"
}

# Download VMan script
download_vman() {
    echo -e "${BLUE}Downloading VMan...${NC}"
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Download with curl or wget
    if command -v curl &> /dev/null; then
        curl -sSL "$VMAN_URL" -o "$INSTALL_DIR/vman.sh"
    else
        wget -q "$VMAN_URL" -O "$INSTALL_DIR/vman.sh"
    fi
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✓ VMan downloaded successfully${NC}"
    else
        echo -e "${RED}Error: Failed to download VMan${NC}"
        exit 1
    fi
}

# Add to shell configuration
setup_shell_integration() {
    if [[ -z "$SHELL_CONFIG" ]]; then
        echo -e "${YELLOW}Manual setup required:${NC}"
        echo "Add this line to your shell configuration file:"
        echo "source $INSTALL_DIR/vman.sh"
        return
    fi
    
    echo -e "${BLUE}Setting up shell integration...${NC}"
    
    # Check if already configured
    if grep -q "source.*vman.sh" "$SHELL_CONFIG" 2>/dev/null; then
        echo -e "${YELLOW}VMan is already configured in $SHELL_CONFIG${NC}"
        return
    fi
    
    # Add to shell config
    echo "" >> "$SHELL_CONFIG"
    echo "# VMan - Virtual Environment Manager" >> "$SHELL_CONFIG"
    echo "source $INSTALL_DIR/vman.sh" >> "$SHELL_CONFIG"
    
    echo -e "${GREEN}✓ Added VMan to $SHELL_CONFIG${NC}"
}

# Verify installation
verify_installation() {
    echo -e "${BLUE}Verifying installation...${NC}"
    
    # Source the script in current session
    source "$INSTALL_DIR/vman.sh"
    
    # Test if virtual function is available
    if declare -f virtual &> /dev/null; then
        echo -e "${GREEN}✓ VMan installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Error: VMan installation verification failed${NC}"
        return 1
    fi
}

# Print success message
print_success() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════╗"
    echo "║      🎉 Installation Complete!       ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Restart your terminal or run: source $SHELL_CONFIG"
    echo "2. Try: virtual --help"
    echo "3. Create your first environment: virtual myproject"
    echo ""
    echo -e "${BLUE}Documentation:${NC} https://github.com/yourusername/vman"
    echo -e "${BLUE}Issues:${NC} https://github.com/yourusername/vman/issues"
}

# Main installation flow
main() {
    print_header
    
    echo "This script will install VMan to: $INSTALL_DIR"
    echo ""
    
    # Ask for confirmation
    read -p "Continue with installation? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    detect_shell_config
    check_prerequisites
    download_vman
    setup_shell_integration
    
    if verify_installation; then
        print_success
    else
        echo -e "${RED}Installation completed but verification failed.${NC}"
        echo "Please restart your terminal and try 'virtual --help'"
    fi
}

# Handle Ctrl+C
trap 'echo -e "\n${RED}Installation cancelled by user${NC}"; exit 1' INT

# Run main function
main "$@"
