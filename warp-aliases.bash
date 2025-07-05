#!/bin/bash

# Warp Settings Manager - Bash Aliases
# Enhanced backup/restore system for Warp Terminal

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Warp backup function - creates a complete backup of all Warp settings
warp-backup() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        backup_name="manual-backup-$(date +%Y-%m-%d-%H%M%S)"
        echo -e "${BLUE}🔄 Creating backup: $backup_name${NC}"
    else
        echo -e "${BLUE}🔄 Creating backup: $backup_name${NC}"
    fi
    
    # Run the backup
    ~/.warp-settings-manager/bin/warp-settings-manager backup "$backup_name"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Backup completed successfully!${NC}"
        echo -e "${BLUE}📁 Backup saved as: $backup_name${NC}"
        
        # Show MCP server count in backup
        local mcp_count=$(sqlite3 ~/.warp-settings-manager/backups/"$backup_name"/critical/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;" 2>/dev/null || echo "0")
        echo -e "${BLUE}🔧 MCP servers backed up: $mcp_count${NC}"
    else
        echo -e "${RED}❌ Backup failed!${NC}"
        return 1
    fi
}

# Warp restore function - restores complete Warp settings from backup
warp-restore() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        echo -e "${BLUE}🔍 Available backups:${NC}"
        for backup_dir in ~/.warp-settings-manager/backups/*; do
            if [ -d "$backup_dir" ]; then
                local name=$(basename "$backup_dir")
                local mcp_count=$(sqlite3 "$backup_dir/critical/warp.sqlite" "SELECT COUNT(*) FROM mcp_environment_variables;" 2>/dev/null || echo "0")
                printf "  %-25s %s MCP servers\n" "$name" "$mcp_count"
            fi
        done
        echo ""
        echo "Usage: warp-restore <backup-name>"
        echo "   or: warp-restore auto    (selects backup with most MCP servers)"
        return 1
    fi
    
    # Run the restoration script
    ~/WarpManualSync/restore-complete-warp-settings.sh "$backup_name"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 Restoration completed!${NC}"
        echo -e "${BLUE}🔄 Please restart Warp Terminal to see your restored settings${NC}"
        echo -e "${BLUE}🔧 Your MCP servers, theme, and all settings should be restored${NC}"
    else
        echo -e "${RED}❌ Restoration failed!${NC}"
        return 1
    fi
}

# Quick backup function
warp-backup-quick() {
    warp-backup "quick-backup-$(date +%Y-%m-%d-%H%M%S)"
}

# Enhanced backup function (uses the new enhanced script)
warp-backup-enhanced() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        backup_name="enhanced-backup-$(date +%Y-%m-%d-%H%M%S)"
    fi
    
    echo -e "${BLUE}🚀 Creating enhanced backup: $backup_name${NC}"
    ~/WarpManualSync/warp-backup-enhanced.sh "$backup_name"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🎉 Enhanced backup completed!${NC}"
    else
        echo -e "${RED}❌ Enhanced backup failed!${NC}"
        return 1
    fi
}

# List backups with MCP server counts
warp-list-backups() {
    echo -e "${BLUE}📋 Available Warp backups:${NC}"
    echo ""
    for backup_dir in ~/.warp-settings-manager/backups/*; do
        if [ -d "$backup_dir" ]; then
            local name=$(basename "$backup_dir")
            local mcp_count=$(sqlite3 "$backup_dir/critical/warp.sqlite" "SELECT COUNT(*) FROM mcp_environment_variables;" 2>/dev/null || echo "0")
            local size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
            printf "  %-25s %s MCP servers  %s\n" "$name" "$mcp_count" "$size"
        fi
    done
    echo ""
    echo "Usage: warp-restore <backup-name>"
}

# Health check for current Warp MCP setup
warp-health() {
    echo -e "${BLUE}🔍 Warp MCP Health Check:${NC}"
    python3 ~/.warp-settings-manager/lib/warp_manager.py --mcp-health
}

# Quick status check
warp-status() {
    echo -e "${BLUE}🔍 Warp Settings Manager Status:${NC}"
    echo ""
    
    # Check if backup system exists
    if [ -d ~/.warp-settings-manager ]; then
        echo -e "${GREEN}✅ Backup system: INSTALLED${NC}"
        
        # Count backups
        local backup_count=$(find ~/.warp-settings-manager/backups -maxdepth 1 -type d | wc -l)
        backup_count=$((backup_count - 1)) # Subtract the backups directory itself
        echo -e "${BLUE}📁 Total backups: $backup_count${NC}"
        
        # Check current MCP servers
        if [ -f ~/.local/state/warp-terminal/warp.sqlite ]; then
            local current_mcp=$(sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;" 2>/dev/null || echo "0")
            echo -e "${BLUE}🔧 Current MCP servers: $current_mcp${NC}"
        else
            echo -e "${YELLOW}⚠ Warp database not found${NC}"
        fi
        
        # Check disk usage
        local disk_usage=$(du -sh ~/.warp-settings-manager/backups 2>/dev/null | cut -f1)
        echo -e "${BLUE}💾 Backup storage used: $disk_usage${NC}"
    else
        echo -e "${RED}❌ Backup system: NOT INSTALLED${NC}"
    fi
}

# Emergency backup function
warp-emergency-backup() {
    local backup_dir="$HOME/emergency-warp-backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}🚨 Creating emergency backup to: $backup_dir${NC}"
    
    mkdir -p "$backup_dir"
    
    # Copy critical files manually
    if [ -f ~/.config/warp-terminal/user_preferences.json ]; then
        cp ~/.config/warp-terminal/user_preferences.json "$backup_dir/"
        echo -e "${GREEN}✅ user_preferences.json backed up${NC}"
    fi
    
    if [ -f ~/.local/state/warp-terminal/warp.sqlite ]; then
        cp ~/.local/state/warp-terminal/warp.sqlite "$backup_dir/"
        echo -e "${GREEN}✅ warp.sqlite backed up${NC}"
    fi
    
    if [ -d ~/.local/state/warp-terminal/mcp ]; then
        cp -r ~/.local/state/warp-terminal/mcp "$backup_dir/"
        echo -e "${GREEN}✅ MCP files backed up${NC}"
    fi
    
    echo -e "${GREEN}🎉 Emergency backup completed: $backup_dir${NC}"
}

echo -e "${GREEN}🚀 Warp Settings Manager bash aliases loaded!${NC}"
echo -e "${BLUE}Available commands:${NC}"
echo "  warp-backup [name]         - Create complete backup"
echo "  warp-backup-enhanced [name] - Create enhanced backup (recommended)"
echo "  warp-restore <name>        - Restore from backup"
echo "  warp-backup-quick          - Quick timestamped backup"
echo "  warp-list-backups          - List all backups with details"
echo "  warp-health                - Check current MCP status"
echo "  warp-status                - Check system status"
echo "  warp-emergency-backup      - Emergency manual backup"
echo ""
echo -e "${YELLOW}💡 Tip: Use 'warp-backup-enhanced' for best protection${NC}"
echo -e "${YELLOW}💡 Tip: Use 'warp-restore auto' to auto-select best backup${NC}"
