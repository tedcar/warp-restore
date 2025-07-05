# Warp Settings Manager - System Creation Guide for Future AI

## Overview

This document explains how the current Warp Settings Manager was built, so a future AI can understand the system architecture and adapt it if Warp's infrastructure changes.

## System Architecture (July 2025)

### Core Problem Solved
Warp Terminal loses all settings (theme, MCP servers, API keys) when users create new accounts or switch between accounts. The system preserves and restores complete configurations.

### Key Components Built

#### 1. Backup System (`~/.warp-settings-manager/`)
- **Purpose**: Creates complete snapshots of Warp configuration
- **Critical Files Backed Up**:
  - `~/.config/warp-terminal/user_preferences.json` (theme, UI settings)
  - `~/.local/state/warp-terminal/warp.sqlite` (database with MCP servers)
  - `~/.local/state/warp-terminal/settings.dat` (additional settings)
  - `~/.local/state/warp-terminal/mcp/*.log` (MCP log files)

#### 2. Enhanced Scripts (WarpManualSync/)
- **`restore-complete-warp-settings.sh`**: Main restoration script with MCP auto-start
- **`warp-backup-enhanced.sh`**: Hardened backup with permanent protection
- **`warp-aliases.fish`**: Fish shell integration for easy commands

#### 3. MCP Server Handling (Critical)
- **Database Tables**: `mcp_environment_variables`, `mcp_server_panes`, `pane_leaves`
- **API Key Storage**: JSON format in `environment_variables` column
- **Auto-Start Issue**: Solved by ensuring proper database restoration and permissions

## Critical Implementation Details

### MCP Database Structure (As of July 2025)
```sql
-- Main MCP environment variables (contains API keys)
CREATE TABLE mcp_environment_variables (
    mcp_server_uuid BLOB PRIMARY KEY NOT NULL,
    environment_variables TEXT NOT NULL  -- JSON format: {"API_KEY": "value"}
);

-- MCP server panes (UI representation)
CREATE TABLE mcp_server_panes (
    id INTEGER PRIMARY KEY NOT NULL,
    kind TEXT NOT NULL DEFAULT 'mcp_server',
    FOREIGN KEY (id, kind) REFERENCES pane_leaves (pane_node_id, kind)
);

-- Pane system (Warp's UI structure)
CREATE TABLE pane_leaves (
    pane_node_id INTEGER NOT NULL UNIQUE REFERENCES pane_nodes(id),
    kind TEXT NOT NULL,
    is_focused BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (pane_node_id, kind)
);
```

### API Key Preservation Method
```bash
# API keys are stored as JSON in environment_variables column
# Example: {"FIRECRAWL_API_KEY": "fc-82cfe5f491104f43ba5e5a73f2c329bf"}

# Verification command:
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT environment_variables FROM mcp_environment_variables LIMIT 1;"
```

### Auto-Start Solution
The key insight: MCP servers need proper database restoration AND file permissions to auto-start. The enhanced restoration script:

1. **Stops Warp completely**: `pkill -f "warp-terminal"`
2. **Cleans SQLite temp files**: Removes `.sqlite-shm` and `.sqlite-wal`
3. **Restores database atomically**: Uses SQLite backup or file copy
4. **Sets proper permissions**: Ensures Warp can read/write files
5. **Triggers database refresh**: Forces Warp to reload MCP configurations

## System Hardening Features

### Permanent Backup Protection
```bash
# Makes backup files read-only to prevent accidental deletion
find "$BACKUP_PATH" -type f -exec chmod 444 {} \;
find "$BACKUP_PATH" -type d -exec chmod 555 {} \;
chmod 755 "$BACKUP_PATH"  # Keep backup root writable for new backups
```

### Snapper Integration
```bash
# Creates "important" snapshots for system-level protection
snapper -c home create --description "$snapshot_desc" --userdata "important=yes"
```

### 10+ Year Stability Design
- **Self-contained**: All dependencies in one directory
- **Version-resistant**: Uses direct file operations, not Warp APIs
- **Protected structure**: Read-only files prevent user accidents
- **Comprehensive metadata**: Full backup information for future debugging

## How to Adapt for Future Warp Changes

### If Warp Changes Database Schema
1. **Identify new tables**: Use `.tables` in sqlite3 to find MCP-related tables
2. **Analyze structure**: Use `.schema table_name` to understand new format
3. **Update backup scripts**: Modify to include new critical tables
4. **Test thoroughly**: Ensure API keys and auto-start still work

### If Warp Changes File Locations
1. **Find new paths**: Use `find ~ -name "warp.sqlite" -o -name "user_preferences.json"`
2. **Update path variables**: Modify `WARP_CONFIG` and `WARP_STATE` in scripts
3. **Test backup/restore**: Verify all files are captured and restored correctly

### If Warp Changes MCP Implementation
1. **Analyze new MCP structure**: Check how servers and API keys are stored
2. **Update extraction logic**: Modify backup scripts to capture new format
3. **Update restoration logic**: Ensure auto-start still works with new system
4. **Preserve backward compatibility**: Keep old backup format support if possible

## Testing Methodology

### Verification Commands
```bash
# Check MCP servers in current system
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;"

# Check MCP servers in backup
sqlite3 ~/.warp-settings-manager/backups/BACKUP_NAME/critical/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;"

# Verify API keys preserved
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT environment_variables FROM mcp_environment_variables WHERE environment_variables LIKE '%API_KEY%';"

# Test auto-start (servers should appear without manual Start button)
# 1. Restore backup
# 2. Start Warp
# 3. Check MCP servers appear in sidebar automatically
```

### Success Criteria
- ✅ All MCP servers appear in Warp sidebar without manual intervention
- ✅ API keys work immediately (no authentication errors)
- ✅ Theme and settings match the backup exactly
- ✅ No manual configuration required after restoration

## Common Failure Points and Solutions

### MCP Servers Don't Auto-Start
- **Cause**: Database permissions or SQLite temp files
- **Solution**: Ensure proper file permissions and clean temp files before restoration

### API Keys Missing
- **Cause**: Incomplete database restoration
- **Solution**: Verify `mcp_environment_variables` table is fully restored

### Theme Not Restored
- **Cause**: `user_preferences.json` not copied or corrupted
- **Solution**: Verify file exists and is valid JSON

### Backup System Broken
- **Cause**: Directory permissions or missing dependencies
- **Solution**: Re-run system hardening, check file permissions

## Emergency Recovery Procedures

### If Backup System Fails
```bash
# Manual backup
mkdir -p ~/emergency-warp-backup
cp ~/.config/warp-terminal/user_preferences.json ~/emergency-warp-backup/
cp ~/.local/state/warp-terminal/warp.sqlite ~/emergency-warp-backup/
cp -r ~/.local/state/warp-terminal/mcp ~/emergency-warp-backup/
```

### If Restoration Fails
```bash
# Manual restoration
pkill -f warp-terminal
cp ~/emergency-warp-backup/user_preferences.json ~/.config/warp-terminal/
cp ~/emergency-warp-backup/warp.sqlite ~/.local/state/warp-terminal/
cp -r ~/emergency-warp-backup/mcp ~/.local/state/warp-terminal/
```

## Future AI Instructions

When adapting this system:

1. **Preserve the core principle**: Complete file-based backup and restoration
2. **Maintain API key security**: Ensure sensitive data is preserved but protected
3. **Keep auto-start functionality**: Users should never need manual intervention
4. **Maintain backward compatibility**: Old backups should still work
5. **Test extensively**: Verify all components work before deploying changes
6. **Document changes**: Update this guide with new implementation details

The system was designed to be resilient and adaptable. The key is understanding Warp's file structure and ensuring complete preservation of all configuration data.
