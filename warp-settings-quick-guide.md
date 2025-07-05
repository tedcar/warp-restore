# Warp Settings Preservation - Enhanced Quick Guide

## When to Use This System

🔄 **Before creating a new Warp account**
🔄 **Before switching between existing accounts**
🔄 **Before major system changes or reinstalls**
🔄 **After configuring MCP servers with API keys**
🔄 **Weekly backup routine (recommended)**

## ⚡ NEW: Enhanced Commands (Recommended)

### 🚀 Enhanced Backup (Recommended)
```bash
# Enhanced backup with permanent protection
./warp-backup-enhanced.sh "important-backup-$(date +%Y-%m-%d)"

# Quick enhanced backup
./warp-backup-enhanced.sh
```

### 📥 Enhanced Restoration (Auto-Start MCP)
```bash
# Auto-select best backup with MCP auto-start
warp-restore auto

# Or use enhanced restoration script directly
./restore-complete-warp-settings.sh auto
```

## Legacy Commands (Still Work)

### 1. Create Backup (Before Account Change)
```bash
# Create backup with current date
~/.warp-settings-manager/bin/warp-settings-manager backup backup-$(date +%Y-%m-%d)

# Or with custom name
~/.warp-settings-manager/bin/warp-settings-manager backup my-backup-name
```

### 2. List Available Backups
```bash
~/.warp-settings-manager/bin/warp-settings-manager list-backups
```

### 3. Restore After Account Change
```bash
# See what will be restored (safe preview)
~/.warp-settings-manager/bin/warp-settings-manager plan-mcp-restore backup-2025-07-05

# Actually restore MCP servers
~/.warp-settings-manager/bin/warp-settings-manager restore-mcp backup-2025-07-05
```

### 4. Check Everything is Working
```bash
# Quick health check
~/.warp-settings-manager/bin/warp-settings-manager mcp-health

# Full validation
~/.warp-settings-manager/bin/warp-settings-manager validate-mcp
```

## Step-by-Step Workflow

### 📤 Before Account Change
1. **Create backup:**
   ```bash
   ~/.warp-settings-manager/bin/warp-settings-manager backup pre-switch-$(date +%Y-%m-%d)
   ```

2. **Verify backup worked:**
   ```bash
   ~/.warp-settings-manager/bin/warp-settings-manager list-backups
   ```

3. **Check MCP status:**
   ```bash
   ~/.warp-settings-manager/bin/warp-settings-manager extract-mcp
   ```

### 📥 After Account Change
1. **Check current MCP status:**
   ```bash
   ~/.warp-settings-manager/bin/warp-settings-manager mcp-health
   ```

2. **Plan restoration:**
   ```bash
   ~/.warp-settings-manager/bin/warp-settings-manager plan-mcp-restore pre-switch-2025-07-05
   ```

3. **Restore MCP servers:**
   ```bash
   ~/.warp-settings-manager/bin/warp-settings-manager restore-mcp pre-switch-2025-07-05
   ```

4. **Verify everything works:**
   ```bash
   ~/.warp-settings-manager/bin/warp-settings-manager validate-mcp
   ```

## What Gets Backed Up

✅ **MCP Server Configurations** (environment variables, API keys)  
✅ **User Preferences** (theme, font, settings)  
✅ **Database Files** (warp.sqlite with all data)  
✅ **MCP Log Files** (for troubleshooting)  
✅ **Configuration Files** (23+ files automatically discovered)

## What Gets Restored

🔄 **MCP Environment Variables** (API keys, endpoints)  
🔄 **Server UUIDs** (maintains server identity)  
⚠️ **Preserves Existing Servers** (won't overwrite unless you specify)

## Troubleshooting

### No MCP Servers Found
```bash
# Check if any servers are configured
~/.warp-settings-manager/bin/warp-settings-manager mcp-health
```

### Backup Failed
```bash
# Check system status
~/.warp-settings-manager/bin/warp-settings-manager status

# Check what files would be backed up
~/.warp-settings-manager/bin/warp-settings-manager backup-candidates
```

### Restoration Issues
```bash
# Validate the backup first
~/.warp-settings-manager/bin/warp-settings-manager validate-backup backup-name

# Check detailed validation
~/.warp-settings-manager/bin/warp-settings-manager validate-mcp
```

## Quick Status Check

```bash
# One command to check everything
~/.warp-settings-manager/bin/warp-settings-manager status
```

Shows:
- ✅ System health
- 📊 Number of backups
- 🔧 MCP server count
- 💾 Disk usage

## File Locations

- **Backups:** `~/.warp-settings-manager/backups/`
- **Logs:** `~/.warp-settings-manager/logs/`
- **Config:** `~/.warp-settings-manager/config.yaml`

## Emergency Recovery

If something goes wrong:

1. **List all backups:**
   ```bash
   ls -la ~/.warp-settings-manager/backups/
   ```

2. **Check backup contents:**
   ```bash
   ls -la ~/.warp-settings-manager/backups/backup-name/
   ```

3. **Manual MCP config location:**
   ```bash
   cat ~/.warp-settings-manager/backups/backup-name/mcp/mcp_configuration.json
   ```

## Pro Tips

💡 **Create backups before any major changes**  
💡 **Use descriptive backup names with dates**  
💡 **Run `mcp-health` regularly to monitor status**  
💡 **Keep at least 3 recent backups**  
💡 **Test restoration on a non-critical setup first**

---

**Need help?** Check the full documentation in `warp-settings-preservation-prd.md` or run any command with `--help`.
