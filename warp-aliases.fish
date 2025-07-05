# Warp Settings Manager Aliases for Fish Shell
# Add these to your ~/.config/fish/config.fish file

# Warp backup alias - creates a complete backup of all Warp settings
function warp-backup
    set backup_name $argv[1]
    
    if test -z "$backup_name"
        set backup_name "manual-backup-"(date +%Y-%m-%d-%H%M%S)
        echo "🔄 Creating backup: $backup_name"
    else
        echo "🔄 Creating backup: $backup_name"
    end
    
    # Run the backup
    ~/.warp-settings-manager/bin/warp-settings-manager backup $backup_name
    
    if test $status -eq 0
        echo "✅ Backup completed successfully!"
        echo "📁 Backup saved as: $backup_name"
        
        # Show MCP server count in backup
        set mcp_count (sqlite3 ~/.warp-settings-manager/backups/$backup_name/critical/warp.sqlite "SELECT COUNT(*) FROM mcp_server_panes;" 2>/dev/null; or echo "0")
        echo "🔧 MCP servers backed up: $mcp_count"
    else
        echo "❌ Backup failed!"
        return 1
    end
end

# Warp restore alias - restores complete Warp settings from backup
function warp-restore
    set backup_name $argv[1]
    
    if test -z "$backup_name"
        echo "🔍 Available backups:"
        for backup_dir in ~/.warp-settings-manager/backups/*
            if test -d "$backup_dir"
                set name (basename "$backup_dir")
                set mcp_count (sqlite3 "$backup_dir/critical/warp.sqlite" "SELECT COUNT(*) FROM mcp_server_panes;" 2>/dev/null; or echo "0")
                printf "  %-25s %s MCP servers\n" "$name" "$mcp_count"
            end
        end
        echo ""
        echo "Usage: warp-restore <backup-name>"
        echo "   or: warp-restore auto    (selects backup with most MCP servers)"
        return 1
    end
    
    # Run the restoration script
    ~/WarpManualSync/restore-complete-warp-settings.sh $backup_name
    
    if test $status -eq 0
        echo ""
        echo "🎉 Restoration completed!"
        echo "🔄 Please restart Warp Terminal to see your restored settings"
        echo "🔧 Your MCP servers, theme, and all settings should be restored"
    else
        echo "❌ Restoration failed!"
        return 1
    end
end

# Quick backup alias
function warp-backup-quick
    warp-backup "quick-backup-"(date +%Y-%m-%d-%H%M%S)
end

# List backups with MCP server counts
function warp-list-backups
    echo "📋 Available Warp backups:"
    echo ""
    for backup_dir in ~/.warp-settings-manager/backups/*
        if test -d "$backup_dir"
            set name (basename "$backup_dir")
            set mcp_count (sqlite3 "$backup_dir/critical/warp.sqlite" "SELECT COUNT(*) FROM mcp_server_panes;" 2>/dev/null; or echo "0")
            set size (du -sh "$backup_dir" | cut -f1)
            printf "  %-25s %s MCP servers  %s\n" "$name" "$mcp_count" "$size"
        end
    end
    echo ""
    echo "Usage: warp-restore <backup-name>"
end

# Health check for current Warp MCP setup
function warp-health
    echo "🔍 Warp MCP Health Check:"
    python3 ~/.warp-settings-manager/lib/warp_manager.py --mcp-health
end

echo "🚀 Warp Settings Manager aliases loaded!"
echo "Available commands:"
echo "  warp-backup [name]     - Create complete backup"
echo "  warp-restore <name>    - Restore from backup"
echo "  warp-backup-quick      - Quick timestamped backup"
echo "  warp-list-backups      - List all backups with details"
echo "  warp-health            - Check current MCP status"
