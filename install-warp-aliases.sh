#!/bin/bash

# Warp Settings Manager - Auto-Installer for Shell Aliases
# Detects shell and installs appropriate aliases (bash/fish, NO ZSH)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Warp Settings Manager - Shell Alias Installer"
print_status "Detecting shell and installing appropriate aliases..."

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
print_status "Detected shell: $CURRENT_SHELL"

# Function to install bash aliases
install_bash_aliases() {
    local bash_rc="$HOME/.bashrc"
    
    print_status "Installing bash aliases..."
    
    # Check if aliases are already installed
    if grep -q "# Warp Settings Manager aliases" "$bash_rc" 2>/dev/null; then
        print_warning "Bash aliases already installed in $bash_rc"
        return 0
    fi
    
    # Add aliases to .bashrc
    cat >> "$bash_rc" << 'EOF'

# Warp Settings Manager aliases
if [ -f ~/WarpManualSync/warp-aliases.bash ]; then
    source ~/WarpManualSync/warp-aliases.bash
elif [ -f ./warp-aliases.bash ]; then
    source ./warp-aliases.bash
fi
EOF
    
    print_success "Bash aliases added to $bash_rc"
    print_status "Run 'source ~/.bashrc' or restart terminal to activate"
}

# Function to install fish aliases
install_fish_aliases() {
    local fish_config="$HOME/.config/fish/config.fish"
    
    print_status "Installing fish aliases..."
    
    # Create fish config directory if it doesn't exist
    mkdir -p "$(dirname "$fish_config")"
    
    # Check if aliases are already installed
    if grep -q "# Warp Settings Manager aliases" "$fish_config" 2>/dev/null; then
        print_warning "Fish aliases already installed in $fish_config"
        return 0
    fi
    
    # Add aliases to fish config
    cat >> "$fish_config" << 'EOF'

# Warp Settings Manager aliases
if test -f ~/WarpManualSync/warp-aliases.fish
    source ~/WarpManualSync/warp-aliases.fish
else if test -f ./warp-aliases.fish
    source ./warp-aliases.fish
end
EOF
    
    print_success "Fish aliases added to $fish_config"
    print_status "Restart fish shell or run 'source ~/.config/fish/config.fish' to activate"
}

# Function to reject zsh
reject_zsh() {
    print_error "ZSH is not supported by this system!"
    print_error "Please switch to bash or fish shell:"
    echo ""
    echo "To switch to bash:"
    echo "  chsh -s /bin/bash"
    echo ""
    echo "To switch to fish:"
    echo "  chsh -s /usr/bin/fish"
    echo ""
    echo "Then restart your terminal and run this installer again."
    exit 1
}

# Main installation logic
case "$CURRENT_SHELL" in
    "bash")
        install_bash_aliases
        
        # Also offer to install fish aliases if fish is available
        if command -v fish >/dev/null 2>&1; then
            echo ""
            read -p "Fish shell detected. Install fish aliases too? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_fish_aliases
            fi
        fi
        ;;
    "fish")
        install_fish_aliases
        
        # Also install bash aliases since bash is usually available
        if command -v bash >/dev/null 2>&1; then
            echo ""
            read -p "Install bash aliases too for compatibility? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                install_bash_aliases
            fi
        fi
        ;;
    "zsh")
        reject_zsh
        ;;
    *)
        print_warning "Unknown shell: $CURRENT_SHELL"
        print_status "Attempting to install bash aliases as fallback..."
        install_bash_aliases
        ;;
esac

# Make scripts executable
print_status "Making scripts executable..."
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true

# Test if backup system is available
print_status "Checking backup system availability..."
if [ -d ~/.warp-settings-manager ]; then
    print_success "Backup system found and ready"
else
    print_warning "Backup system not found at ~/.warp-settings-manager"
    print_status "You may need to set up the full Warp Settings Manager first"
fi

# Final instructions
echo ""
print_success "🎉 Installation completed!"
echo ""
print_status "Next steps:"
case "$CURRENT_SHELL" in
    "bash")
        echo "1. Run: source ~/.bashrc"
        echo "2. Test: warp-status"
        ;;
    "fish")
        echo "1. Restart fish shell or run: source ~/.config/fish/config.fish"
        echo "2. Test: warp-status"
        ;;
esac
echo "3. Create your first backup: warp-backup-enhanced"
echo "4. List available commands: warp-status"
echo ""
print_status "Available commands after activation:"
echo "  warp-backup [name]         - Create complete backup"
echo "  warp-backup-enhanced [name] - Create enhanced backup (recommended)"
echo "  warp-restore <name>        - Restore from backup"
echo "  warp-list-backups          - List all backups"
echo "  warp-health                - Check MCP status"
echo "  warp-status                - Check system status"
echo ""
print_warning "🚫 ZSH is NOT supported - use bash or fish only"
print_success "✅ Bash and Fish are fully supported"
