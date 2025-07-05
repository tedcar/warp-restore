# Warp Settings Manager - Complete Restoration Troubleshooting Summary

## Current Status: PARTIALLY WORKING ✅❌
- **Theme/Settings Restoration**: ✅ WORKING
- **MCP Server Restoration**: ❌ INCONSISTENT 
- **Fish Aliases**: ✅ WORKING
- **Restoration Script**: ✅ WORKING (with caveats)

## System Configuration
- **User**: carnateo on CachyOS Linux
- **Shell**: Fish shell (`/bin/fish`)
- **Terminal**: Alacritty (configured for Fish)
- **Warp Settings Manager**: Installed at `~/.warp-settings-manager/`
- **Working Directory**: `/home/carnateo/WarpManualSync`

## Key Problem Discovered
**MCP servers disappear between Warp sessions/account switches**, causing:
1. Backups to capture empty MCP configurations (0 servers)
2. Restoration attempts to restore from empty backups
3. User loses all MCP server configurations when switching accounts

## Critical Files & Locations
```
~/.config/warp-terminal/user_preferences.json    # Theme, UI settings
~/.local/state/warp-terminal/warp.sqlite         # MCP servers, database
~/.local/state/warp-terminal/settings.dat       # Core settings
~/.config/warp-terminal/keybindings.yaml        # Key bindings
```

## MCP Database Structure
- **Table**: `mcp_server_panes` (NOT `mcp_servers`)
- **Table**: `mcp_environment_variables` 
- **Check MCP count**: `sqlite3 warp.sqlite "SELECT COUNT(*) FROM mcp_server_panes;"`

## Working Backup Analysis
```bash
# Check which backups have MCP servers:
for backup in ~/.warp-settings-manager/backups/*/critical/warp.sqlite; do 
    echo "=== $(basename $(dirname $(dirname $backup))) ==="; 
    sqlite3 "$backup" "SELECT COUNT(*) FROM mcp_server_panes;" 2>/dev/null || echo "Error"; 
done
```

**Results Found**:
- `backup-2025-07-05-01`: **1 MCP server** ✅ (GOOD BACKUP)
- All other backups: **0 MCP servers** ❌ (EMPTY BACKUPS)

## Manual Restoration Process (WORKING)
```bash
# 1. Stop Warp completely
pkill -f warp

# 2. Clean SQLite temp files
rm ~/.local/state/warp-terminal/warp.sqlite-shm ~/.local/state/warp-terminal/warp.sqlite-wal

# 3. Restore from GOOD backup
cp ~/.warp-settings-manager/backups/backup-2025-07-05-01/critical/warp.sqlite ~/.local/state/warp-terminal/warp.sqlite
cp ~/.warp-settings-manager/backups/backup-2025-07-05-01/critical/user_preferences.json ~/.config/warp-terminal/user_preferences.json

# 4. Restart Warp
```

## Restoration Script Status
- **File**: `restore-complete-warp-settings.sh` ✅ WORKING
- **Features**: 
  - Auto-detects backups with MCP servers
  - `./restore-complete-warp-settings.sh auto` - selects best backup
  - `./restore-complete-warp-settings.sh backup-name` - specific backup
  - Creates safety backup before restoration
  - Handles SQLite cleanup properly

## Fish Shell Aliases (WORKING)
**Added to `~/.config/fish/config.fish`**:
```fish
warp-backup [name]      # Create complete backup
warp-restore <name>     # Restore from backup  
warp-backup-quick       # Quick timestamped backup
warp-list-backups       # List all backups with MCP counts
warp-health             # Check current MCP status
```

**Test Results**:
- ✅ `warp-health` - Shows current MCP status
- ✅ `warp-list-backups` - Lists backups with MCP server counts
- ✅ `warp-backup` - Creates backups (but may capture 0 MCP servers)
- ✅ `warp-restore` - Uses the restoration script

## Current Issues Still to Resolve

### 1. MCP Server Backup Inconsistency
- **Problem**: New backups capture 0 MCP servers even when `warp-health` shows 2 servers
- **Cause**: Possible timing issue or different database read methods
- **Impact**: Future backups may be useless for MCP restoration

### 2. MCP Server Visibility in Warp UI
- **Problem**: After restoration, MCP servers may not appear in Warp sidebar
- **Status**: User reported "mcp servers did not restore, only the settings and theme"
- **Database shows**: Servers are present in database
- **UI shows**: Servers not visible in sidebar

### 3. Rules Not Restoring
- **Problem**: User mentioned "Neither did the rules"
- **Status**: Unknown what "rules" refers to - needs investigation

## Next Steps for Future Agent

### Immediate Priority
1. **Investigate MCP UI visibility issue**:
   - Check why servers in database don't appear in UI
   - Look for additional configuration files
   - Check Warp logs for MCP loading errors

2. **Fix backup consistency**:
   - Investigate why new backups capture 0 MCP servers
   - Compare backup timing with Warp state
   - Ensure backup captures active MCP configuration

3. **Identify "rules" system**:
   - Find where Warp stores "rules" 
   - Add rules to backup/restore process

### Testing Workflow
```bash
# 1. Check current status
warp-health

# 2. Create test backup
warp-backup test-investigation

# 3. Check if backup captured MCP servers
sqlite3 ~/.warp-settings-manager/backups/test-investigation/critical/warp.sqlite "SELECT COUNT(*) FROM mcp_server_panes;"

# 4. If 0 servers, investigate why backup missed them
# 5. Test restoration from known good backup
warp-restore backup-2025-07-05-01
```

## Files Created/Modified
- ✅ `restore-complete-warp-settings.sh` - Complete restoration script
- ✅ `warp-aliases.fish` - Fish shell aliases
- ✅ `~/.config/fish/config.fish` - Updated with Warp aliases
- ✅ `warp-restoration-troubleshooting-summary.md` - This file

## Key Commands for Debugging
```bash
# Check MCP servers in current database
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT COUNT(*) FROM mcp_server_panes;"

# Check MCP servers in backup
sqlite3 ~/.warp-settings-manager/backups/BACKUP_NAME/critical/warp.sqlite "SELECT COUNT(*) FROM mcp_server_panes;"

# Health check
python3 ~/.warp-settings-manager/lib/warp_manager.py --mcp-health

# List all database tables
sqlite3 ~/.local/state/warp-terminal/warp.sqlite ".tables"
```

## Success Criteria
- ✅ Theme and settings restore completely
- ❌ MCP servers appear in Warp sidebar after restoration
- ❌ Rules (whatever they are) restore properly  
- ❌ New backups consistently capture MCP servers
- ✅ Fish aliases work for easy backup/restore
- ✅ Documentation updated with complete process

**Status**: 60% complete - Core restoration works but MCP visibility and backup consistency need fixing.
