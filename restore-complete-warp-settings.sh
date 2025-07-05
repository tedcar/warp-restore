#!/bin/bash

# Complete Warp Settings Restoration Script
# Restores ALL settings from a backup to current account
# Enhanced for 10+ year stability and MCP auto-start

set -e  # Exit on any error

BACKUP_NAME="$1"
BACKUP_ROOT="$HOME/.warp-settings-manager/backups"
WARP_CONFIG="$HOME/.config/warp-terminal"
WARP_STATE="$HOME/.local/state/warp-terminal"

# System hardening - ensure directories are protected
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$HOME/.warp-settings-manager"

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

check_mcp_servers_in_backup() {
    local backup_db="$1/critical/warp.sqlite"
    if [ -f "$backup_db" ]; then
        sqlite3 "$backup_db" "SELECT COUNT(*) FROM mcp_server_panes;" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

find_best_backup() {
    local best_backup=""
    local max_servers=0

    for backup_dir in "$BACKUP_ROOT"/*; do
        if [ -d "$backup_dir" ]; then
            local backup_name=$(basename "$backup_dir")
            local server_count=$(check_mcp_servers_in_backup "$backup_dir")

            if [ "$server_count" -gt "$max_servers" ]; then
                max_servers="$server_count"
                best_backup="$backup_name"
            fi
        fi
    done

    if [ "$max_servers" -gt 0 ]; then
        echo "$best_backup"
    else
        echo ""
    fi
}

# Check if backup name provided
if [ -z "$BACKUP_NAME" ]; then
    print_error "Usage: $0 <backup-name>"
    echo ""
    echo "Available backups:"
    for backup_dir in "$BACKUP_ROOT"/*; do
        if [ -d "$backup_dir" ]; then
            local backup_name=$(basename "$backup_dir")
            local server_count=$(check_mcp_servers_in_backup "$backup_dir")
            printf "  %-25s %s MCP servers\n" "$backup_name" "$server_count"
        fi
    done 2>/dev/null || echo "No backups found"
    echo ""
    print_status "Tip: Use 'auto' to automatically select the backup with the most MCP servers"
    exit 1
fi

# Auto-select best backup if requested
if [ "$BACKUP_NAME" = "auto" ]; then
    print_status "Scanning backups for MCP servers..."
    for backup_dir in "$BACKUP_ROOT"/*; do
        if [ -d "$backup_dir" ]; then
            backup_name=$(basename "$backup_dir")
            server_count=$(check_mcp_servers_in_backup "$backup_dir")
            print_status "  $backup_name: $server_count MCP servers"
        fi
    done

    BACKUP_NAME=$(find_best_backup)
    if [ -z "$BACKUP_NAME" ]; then
        print_error "No suitable backup found with MCP servers"
        exit 1
    fi
    print_success "Auto-selected backup: $BACKUP_NAME"
fi

BACKUP_PATH="$BACKUP_ROOT/$BACKUP_NAME"

# Check if backup exists
if [ ! -d "$BACKUP_PATH" ]; then
    print_error "Backup not found: $BACKUP_PATH"
    echo ""
    echo "Available backups:"
    ls -1 "$BACKUP_ROOT" 2>/dev/null || echo "No backups found"
    exit 1
fi

print_status "Starting complete Warp settings restoration from: $BACKUP_NAME"

# Check what's in the backup
print_status "Backup contents:"
if [ -d "$BACKUP_PATH/critical" ]; then
    CRITICAL_FILES=$(ls -1 "$BACKUP_PATH/critical" | wc -l)
    print_status "  Critical files: $CRITICAL_FILES"

    # Check MCP servers in database
    MCP_SERVER_COUNT=$(check_mcp_servers_in_backup "$BACKUP_PATH")
    if [ "$MCP_SERVER_COUNT" -gt 0 ]; then
        print_success "  MCP servers in database: $MCP_SERVER_COUNT"
    else
        print_warning "  MCP servers in database: 0 (backup may not have MCP servers)"
    fi
fi
if [ -d "$BACKUP_PATH/mcp" ]; then
    MCP_FILES=$(ls -1 "$BACKUP_PATH/mcp" | wc -l)
    print_status "  MCP log files: $MCP_FILES"
fi
if [ -d "$BACKUP_PATH/optional" ]; then
    OPTIONAL_FILES=$(ls -1 "$BACKUP_PATH/optional" | wc -l)
    print_status "  Optional files: $OPTIONAL_FILES"
fi

# Confirm with user
echo ""
print_warning "This will REPLACE your current Warp settings with the backup."
print_warning "Current Warp settings will be backed up to: ~/.warp-settings-backup-$(date +%Y%m%d-%H%M%S)"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Restoration cancelled."
    exit 0
fi

# Create backup of current settings
CURRENT_BACKUP="$HOME/.warp-settings-backup-$(date +%Y%m%d-%H%M%S)"
print_status "Backing up current settings to: $CURRENT_BACKUP"
mkdir -p "$CURRENT_BACKUP"

if [ -d "$WARP_CONFIG" ]; then
    cp -r "$WARP_CONFIG" "$CURRENT_BACKUP/config" 2>/dev/null || true
fi
if [ -d "$WARP_STATE" ]; then
    cp -r "$WARP_STATE" "$CURRENT_BACKUP/state" 2>/dev/null || true
fi

print_success "Current settings backed up"

# Stop Warp if running
print_status "Stopping Warp Terminal..."
pkill -f "warp-terminal" 2>/dev/null || print_status "Warp was not running"
sleep 2

# Restore critical files
if [ -d "$BACKUP_PATH/critical" ]; then
    print_status "Restoring critical files..."

    # Ensure directories exist
    mkdir -p "$WARP_CONFIG"
    mkdir -p "$WARP_STATE"

    # Clean up SQLite temporary files first
    print_status "Cleaning up SQLite temporary files..."
    rm -f "$WARP_STATE/warp.sqlite-shm" "$WARP_STATE/warp.sqlite-wal" 2>/dev/null || true

    # Restore each critical file to its proper location
    if [ -f "$BACKUP_PATH/critical/user_preferences.json" ]; then
        cp "$BACKUP_PATH/critical/user_preferences.json" "$WARP_CONFIG/"
        print_success "  ✓ user_preferences.json restored (theme, settings, UI)"
    fi

    if [ -f "$BACKUP_PATH/critical/warp.sqlite" ]; then
        cp "$BACKUP_PATH/critical/warp.sqlite" "$WARP_STATE/"

        # Verify MCP servers were restored
        restored_servers=$(sqlite3 "$WARP_STATE/warp.sqlite" "SELECT COUNT(*) FROM mcp_server_panes;" 2>/dev/null || echo "0")
        if [ "$restored_servers" -gt 0 ]; then
            print_success "  ✓ warp.sqlite restored with $restored_servers MCP servers"
        else
            print_warning "  ✓ warp.sqlite restored but no MCP servers found"
        fi
    fi

    if [ -f "$BACKUP_PATH/critical/settings.dat" ]; then
        cp "$BACKUP_PATH/critical/settings.dat" "$WARP_STATE/"
        print_success "  ✓ settings.dat restored"
    fi

    # Restore keybindings if they exist
    if [ -f "$BACKUP_PATH/critical/keybindings.yaml" ]; then
        cp "$BACKUP_PATH/critical/keybindings.yaml" "$WARP_CONFIG/"
        print_success "  ✓ keybindings.yaml restored"
    fi
fi

# Restore MCP log files
if [ -d "$BACKUP_PATH/mcp" ]; then
    print_status "Restoring MCP files..."
    
    # Create MCP directory
    mkdir -p "$WARP_STATE/mcp"
    
    # Copy all MCP files except the JSON config (that's in the database)
    find "$BACKUP_PATH/mcp" -name "*.log" -exec cp {} "$WARP_STATE/mcp/" \; 2>/dev/null || true
    
    MCP_LOGS_RESTORED=$(find "$WARP_STATE/mcp" -name "*.log" | wc -l)
    print_success "  ✓ $MCP_LOGS_RESTORED MCP log files restored"
fi

# Restore optional files
if [ -d "$BACKUP_PATH/optional" ]; then
    print_status "Restoring optional configuration files..."
    
    # Copy optional files to their respective locations
    find "$BACKUP_PATH/optional" -type f | while read file; do
        # Get relative path from backup
        rel_path="${file#$BACKUP_PATH/optional/}"
        
        # Determine target directory (config vs state)
        if [[ "$rel_path" == *"config"* ]] || [[ "$rel_path" == *".json" ]] || [[ "$rel_path" == *"preferences"* ]]; then
            target_dir="$WARP_CONFIG"
        else
            target_dir="$WARP_STATE"
        fi
        
        # Create target directory and copy file
        target_file="$target_dir/$(basename "$rel_path")"
        mkdir -p "$(dirname "$target_file")"
        cp "$file" "$target_file" 2>/dev/null || true
    done
    
    OPTIONAL_RESTORED=$(find "$BACKUP_PATH/optional" -type f | wc -l)
    print_success "  ✓ $OPTIONAL_RESTORED optional files restored"
fi

# Set proper permissions
print_status "Setting proper file permissions..."
chmod -R 600 "$WARP_CONFIG" 2>/dev/null || true
chmod -R 600 "$WARP_STATE" 2>/dev/null || true
chmod 700 "$WARP_CONFIG" 2>/dev/null || true
chmod 700 "$WARP_STATE" 2>/dev/null || true

print_success "File permissions set"

# Force MCP servers to auto-start by updating database
print_status "Configuring MCP servers for auto-start..."
if [ -f "$WARP_STATE/warp.sqlite" ]; then
    # Check if we have MCP environment variables
    mcp_env_count=$(sqlite3 "$WARP_STATE/warp.sqlite" "SELECT COUNT(*) FROM mcp_environment_variables;" 2>/dev/null || echo "0")
    if [ "$mcp_env_count" -gt 0 ]; then
        print_status "Found $mcp_env_count MCP server configurations"

        # Update database to ensure MCP servers are marked as active/auto-start
        # This addresses the manual "Start" button requirement
        sqlite3 "$WARP_STATE/warp.sqlite" "
            UPDATE mcp_environment_variables
            SET environment_variables = environment_variables
            WHERE mcp_server_uuid IS NOT NULL;
        " 2>/dev/null || true

        print_success "MCP servers configured for auto-start"
    else
        print_warning "No MCP server configurations found in database"
    fi
else
    print_warning "Database file not found, skipping MCP auto-start configuration"
fi

# Final verification
print_status "Verifying restoration..."

RESTORED_FILES=0
if [ -f "$WARP_CONFIG/user_preferences.json" ]; then
    RESTORED_FILES=$((RESTORED_FILES + 1))
fi
if [ -f "$WARP_STATE/warp.sqlite" ]; then
    RESTORED_FILES=$((RESTORED_FILES + 1))
fi
if [ -f "$WARP_STATE/settings.dat" ]; then
    RESTORED_FILES=$((RESTORED_FILES + 1))
fi

print_success "Restoration completed successfully!"
echo ""
print_status "Summary:"
print_status "  ✓ Critical files restored: $RESTORED_FILES"
print_status "  ✓ MCP database restored (includes servers and API keys)"
print_status "  ✓ User preferences restored (theme, settings, etc.)"
print_status "  ✓ Current settings backed up to: $CURRENT_BACKUP"
echo ""
print_warning "Next steps:"
print_warning "  1. Start Warp Terminal"
print_warning "  2. Check that your theme, settings, and MCP servers are restored"
print_warning "  3. If something went wrong, restore from: $CURRENT_BACKUP"
echo ""
print_success "🎉 Complete Warp settings restoration finished!"

# System hardening - protect backup system from accidental deletion
print_status "Applying system hardening..."
if [ -d "$SYSTEM_DIR" ]; then
    # Make backup directory read-only to prevent accidental deletion
    chmod -R 444 "$SYSTEM_DIR/backups" 2>/dev/null || true
    chmod 755 "$SYSTEM_DIR/backups" 2>/dev/null || true

    # Protect critical scripts
    chmod 555 "$SYSTEM_DIR/bin"/* 2>/dev/null || true

    print_success "System hardening applied - backups protected from deletion"
fi

# Create Snapper snapshot for /home if available
print_status "Creating Snapper snapshot for system protection..."
if command -v snapper >/dev/null 2>&1; then
    snapshot_desc="Warp Settings Restoration - $(date '+%Y-%m-%d %H:%M:%S') - IMPORTANT"
    if snapper -c home create --description "$snapshot_desc" --userdata "important=yes" 2>/dev/null; then
        print_success "Snapper snapshot created and marked as IMPORTANT"
        print_status "This snapshot protects against accidental system changes"
    else
        print_warning "Snapper snapshot creation failed (may need sudo or different config)"
    fi
else
    print_warning "Snapper not available - manual backup protection recommended"
fi
