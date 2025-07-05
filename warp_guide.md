# Warp Settings Manager - User Guide

## Essential Commands You Need to Know

### 🔄 Creating Backups

**After making any configuration changes:**
```bash
# Quick backup with auto-generated name
warp-backup

# Backup with custom name
warp-backup "my-config-changes-2025-07-05"

# Enhanced backup (recommended for important changes)
./warp-backup-enhanced.sh "important-backup-$(date +%Y-%m-%d)"
```

**When to backup:**
- ✅ After adding new MCP servers
- ✅ After changing API keys
- ✅ After customizing themes/settings
- ✅ Before creating new Warp accounts
- ✅ Before system updates

### 📥 Restoring Settings

**Restore from specific backup:**
```bash
# Restore from named backup
warp-restore "backup-2025-07-05-01"

# Auto-select best backup (most MCP servers)
warp-restore auto
```

**Alternative restoration (if aliases don't work):**
```bash
# Direct script execution
./restore-complete-warp-settings.sh auto
./restore-complete-warp-settings.sh "backup-name"
```

### 📋 Managing Backups

**List all available backups:**
```bash
warp-list-backups
```

**Check system health:**
```bash
warp-health
```

**Check MCP servers in current setup:**
```bash
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;"
```

## Backup Naming Convention

### Auto-Generated Names
- `backup-YYYY-MM-DD-HHMMSS` - Standard timestamp format
- `manual-backup-YYYY-MM-DD-HHMMSS` - Manual backups via warp-backup
- `quick-backup-YYYY-MM-DD-HHMMSS` - Quick backups

### Recommended Custom Names
- `pre-account-switch-YYYY-MM-DD` - Before switching accounts
- `mcp-setup-complete-YYYY-MM-DD` - After configuring MCP servers
- `theme-customization-YYYY-MM-DD` - After theme changes
- `important-config-YYYY-MM-DD` - For critical configurations

## Auto-Restore Behavior

### When using `warp-restore auto`:
1. **Scans all backups** for MCP server count
2. **Selects backup** with the most MCP servers
3. **Shows preview** of what will be restored
4. **Creates safety backup** of current settings
5. **Restores everything** including API keys
6. **Configures MCP auto-start** (no manual Start button needed)

### What Gets Restored:
- ✅ **All MCP servers** with API keys preserved
- ✅ **Theme and UI settings** (colors, fonts, layout)
- ✅ **User preferences** (all Warp settings)
- ✅ **Keybindings** (if customized)
- ✅ **Database state** (complete Warp configuration)

## System Protection Features

### Permanent Backups
- **Never auto-deleted** - All backups are permanent (~5MB each)
- **Protected from accidental deletion** - Read-only file permissions
- **Snapper integration** - Creates "important" snapshots when available

### 10+ Year Stability
- **Self-contained system** - No external dependencies
- **Version-resistant** - Works even if Warp changes slightly
- **Protected directories** - System files are read-only
- **Comprehensive metadata** - Full backup information preserved

## Troubleshooting

### MCP Servers Not Starting
```bash
# Check if servers are in database
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;"

# Check API keys are preserved
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT environment_variables FROM mcp_environment_variables LIMIT 1;"

# Force restart Warp after restoration
pkill -f warp-terminal
# Then start Warp normally
```

### Backup Failed
```bash
# Check system status
warp-health

# Check available space
df -h ~/.warp-settings-manager/backups

# Manual backup verification
ls -la ~/.warp-settings-manager/backups/
```

### Restoration Issues
```bash
# List available backups with MCP counts
warp-list-backups

# Check backup integrity
sqlite3 ~/.warp-settings-manager/backups/BACKUP_NAME/critical/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;"

# Manual restoration (emergency)
pkill -f warp-terminal
cp ~/.warp-settings-manager/backups/BACKUP_NAME/critical/warp.sqlite ~/.local/state/warp-terminal/warp.sqlite
cp ~/.warp-settings-manager/backups/BACKUP_NAME/critical/user_preferences.json ~/.config/warp-terminal/user_preferences.json
```

## File Locations

### Backup Storage
- **Main backups:** `~/.warp-settings-manager/backups/`
- **Safety backups:** `~/.warp-settings-backup-YYYYMMDD-HHMMSS/`
- **System logs:** `~/.warp-settings-manager/logs/`

### Warp Configuration
- **User settings:** `~/.config/warp-terminal/user_preferences.json`
- **Database:** `~/.local/state/warp-terminal/warp.sqlite`
- **MCP files:** `~/.local/state/warp-terminal/mcp/`

## Quick Workflow Examples

### Before Creating New Account
```bash
# 1. Create backup
warp-backup "pre-new-account-$(date +%Y-%m-%d)"

# 2. Verify backup has your MCP servers
warp-list-backups

# 3. Create new account in Warp
# 4. After account creation, restore settings
warp-restore auto
```

### After Configuring MCP Servers
```bash
# 1. Test your MCP setup works
warp-health

# 2. Create backup to preserve configuration
warp-backup "mcp-configured-$(date +%Y-%m-%d)"

# 3. Verify API keys are preserved
sqlite3 ~/.warp-settings-manager/backups/mcp-configured-*/critical/warp.sqlite "SELECT environment_variables FROM mcp_environment_variables;"
```

### Weekly Maintenance
```bash
# 1. Quick health check
warp-health

# 2. Create weekly backup
warp-backup "weekly-$(date +%Y-%m-%d)"

# 3. Check backup storage
du -sh ~/.warp-settings-manager/backups/
```

## Emergency Recovery

If everything breaks:
1. **Stop Warp:** `pkill -f warp-terminal`
2. **Find good backup:** `warp-list-backups`
3. **Manual restore:** Copy files from `~/.warp-settings-manager/backups/GOOD_BACKUP/critical/` to Warp directories
4. **Restart Warp**

## Success Indicators

### After Restoration:
- ✅ **MCP servers appear** in Warp sidebar without clicking Start
- ✅ **API keys work** - no authentication errors
- ✅ **Theme restored** - colors, fonts match your backup
- ✅ **All settings preserved** - preferences, keybindings, etc.

### System Health:
- ✅ **warp-health shows** your MCP servers
- ✅ **Backup count increases** after each backup
- ✅ **No permission errors** when running commands
