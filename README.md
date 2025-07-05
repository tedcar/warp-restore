# Warp Settings Manager - Complete Backup & Restore System

## 🎯 What This Solves

Warp Terminal loses all your settings when you create new accounts or switch between accounts. This system **completely preserves and restores**:

- ✅ **MCP Servers** with API keys (auto-start, no manual Start button)
- ✅ **Themes & UI Settings** (colors, fonts, layout)
- ✅ **User Preferences** (all Warp configuration)
- ✅ **Keybindings** (custom shortcuts)
- ✅ **Complete Database State** (everything Warp stores)

## 🚀 Quick Setup

### 1. Clone Repository
```bash
git clone https://github.com/tedcar/warp-restore.git
cd warp-restore
```

### 2. Make Scripts Executable
```bash
chmod +x *.sh
```

### 3. Install Shell Aliases (Auto-Detects Bash/Fish)
```bash
# Auto-installer detects your shell and installs appropriate aliases
./install-warp-aliases.sh

# Manual installation for bash
cat warp-aliases.bash >> ~/.bashrc
source ~/.bashrc

# Manual installation for fish
cat warp-aliases.fish >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

### 4. Create Your First Backup
```bash
# Enhanced backup (recommended)
./warp-backup-enhanced.sh "initial-setup-$(date +%Y-%m-%d)"

# Or using shell aliases (bash/fish)
warp-backup-enhanced "initial-setup-$(date +%Y-%m-%d)"
warp-backup "initial-setup-$(date +%Y-%m-%d)"
```

## 📖 Essential Commands

### Creating Backups
```bash
# Quick backup with auto-generated name
warp-backup

# Backup with custom name
warp-backup "my-config-changes"

# Enhanced backup (permanent protection)
./warp-backup-enhanced.sh "important-backup"
```

### Restoring Settings
```bash
# Auto-select best backup (most MCP servers)
warp-restore auto

# Restore specific backup
warp-restore "backup-name"

# Direct script execution
./restore-complete-warp-settings.sh auto
```

### Managing Backups
```bash
# List all backups with MCP server counts
warp-list-backups

# Check system health
warp-health
```

## 🔧 How It Works

### Backup Process
1. **Stops Warp** (if running) for clean backup
2. **Captures critical files**:
   - `~/.config/warp-terminal/user_preferences.json` (theme, settings)
   - `~/.local/state/warp-terminal/warp.sqlite` (database with MCP servers)
   - `~/.local/state/warp-terminal/mcp/*.log` (MCP log files)
3. **Preserves API keys** in database format
4. **Creates permanent backup** (protected from deletion)
5. **Generates metadata** for future reference

### Restoration Process
1. **Creates safety backup** of current settings
2. **Stops Warp completely** for clean restoration
3. **Cleans SQLite temp files** (prevents corruption)
4. **Restores all files atomically**
5. **Configures MCP auto-start** (no manual Start button needed)
6. **Sets proper permissions**
7. **Creates Snapper snapshot** (if available)

## 🛡️ System Protection Features

### Permanent Backups
- **Never auto-deleted** - All backups are permanent (~5MB each)
- **Protected from accidental deletion** - Read-only file permissions
- **Comprehensive metadata** - Full backup information preserved

### 10+ Year Stability
- **Self-contained system** - No external dependencies
- **Version-resistant** - Works even if Warp changes slightly
- **Protected directories** - System files are read-only
- **Snapper integration** - Creates "important" snapshots

## 📋 Typical Workflow

### Before Creating New Warp Account
```bash
# 1. Create backup of current setup
warp-backup "pre-new-account-$(date +%Y-%m-%d)"

# 2. Verify backup captured your MCP servers
warp-list-backups

# 3. Create new account in Warp
# 4. Restore your settings
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

## 🔍 Troubleshooting

### MCP Servers Not Auto-Starting
```bash
# Check if servers are in database
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;"

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
```

### Emergency Manual Restoration
```bash
# If scripts fail, manual restoration
pkill -f warp-terminal
cp ~/.warp-settings-manager/backups/GOOD_BACKUP/critical/warp.sqlite ~/.local/state/warp-terminal/
cp ~/.warp-settings-manager/backups/GOOD_BACKUP/critical/user_preferences.json ~/.config/warp-terminal/
# Restart Warp
```

## 📁 File Structure

```
warp-restore/
├── README.md                          # This file
├── warp_guide.md                      # Detailed user guide
├── install-warp-aliases.sh           # Auto-installer for shell aliases
├── restore-complete-warp-settings.sh  # Main restoration script
├── warp-backup-enhanced.sh            # Enhanced backup script
├── warp-aliases.bash                  # Bash shell integration
├── warp-aliases.fish                  # Fish shell integration
├── future-ai-info-maintenance/        # Documentation for future AI maintenance
│   ├── system-creation-guide.md       # How the system was built
│   ├── maintenance-instructions-for-future-ai.md
│   └── [all documentation files]      # Complete project documentation
└── [documentation files]              # Implementation guides and findings
```

## 🔧 Advanced Usage

### Custom Backup Locations
The system uses `~/.warp-settings-manager/backups/` by default. This can be changed by modifying the `BACKUP_ROOT` variable in the scripts.

### Integration with Other Backup Systems
Backups are stored in a simple directory structure and can be easily integrated with:
- Syncthing for cross-device sync
- Git for version control
- Cloud storage for off-site backup

### Automation
```bash
# Add to crontab for weekly backups
0 2 * * 0 /path/to/warp-backup-enhanced.sh "weekly-$(date +%Y-%m-%d)"
```

## 🆘 Support & Maintenance

### For Users
- Read `warp_guide.md` for detailed command reference
- Check `future-ai-info-maintenance/` for technical details
- All backups include metadata for troubleshooting

### For Future AI Maintenance
- See `future-ai-info-maintenance/maintenance-instructions-for-future-ai.md`
- System designed for 10+ year stability with minimal maintenance
- Complete documentation of system architecture and adaptation procedures

## 🎉 Success Indicators

After restoration, you should see:
- ✅ **MCP servers appear** in Warp sidebar without clicking Start
- ✅ **API keys work** immediately (no authentication errors)
- ✅ **Theme restored** exactly as it was
- ✅ **All settings preserved** (preferences, keybindings, etc.)

## 📄 License

This project is designed for personal use. Feel free to adapt and modify for your needs.

## 🐚 Shell Support

- ✅ **Bash** - Full support with auto-installer
- ✅ **Fish** - Full support with auto-installer
- 🚫 **ZSH** - Not supported (use bash or fish instead)

The auto-installer (`./install-warp-aliases.sh`) detects your shell and installs the appropriate aliases automatically.

## 🤝 Contributing

This system is designed to be stable and self-contained. If you encounter issues:
1. Check the troubleshooting section
2. Review the documentation in `future-ai-info-maintenance/`
3. Create an issue with detailed information about your setup

---

**Built for 10+ year stability and resilience. Your Warp settings will never be lost again.**
