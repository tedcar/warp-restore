# Maintenance Instructions for Future AI

## Quick Start for Future AI

You are maintaining a Warp Settings Manager that preserves complete Warp Terminal configurations across account changes. The system is designed for 10+ year stability but may need adaptation if Warp changes its infrastructure.

**IMPORTANT: Primary Shell Environment is BASH** - All scripts, aliases, and documentation assume bash as the main terminal environment. Fish is supported as secondary, but ZSH is explicitly not supported.

## Current System Status (July 2025)

### ✅ What Works Perfectly
- **Complete backup/restore** of all Warp settings
- **Bash shell integration** with full alias support (primary environment)
- **Fish shell integration** with auto-installer (secondary support)
- **Auto-installer** detects shell and installs appropriate aliases
- **MCP server preservation** with API keys intact
- **Auto-start functionality** (no manual Start button needed)
- **Permanent backup protection** (never auto-deleted)
- **System hardening** (protected from user accidents)
- **Snapper integration** (creates "important" snapshots)
- **ZSH rejection** (explicitly not supported - bash/fish only)

### 🔧 Key Files to Understand
```
WarpManualSync/
├── restore-complete-warp-settings.sh  # Main restoration script
├── warp-backup-enhanced.sh            # Enhanced backup script
├── warp_guide.md                      # User command reference
├── warp-aliases.fish                  # Fish shell integration
└── future-ai-info-maintenance/        # This documentation
```

## Maintenance Scenarios

### Scenario 1: Warp Database Schema Changed

**Symptoms:**
- Backup/restore fails with database errors
- MCP servers not appearing after restoration
- API keys missing after restoration

**Diagnosis Steps:**
```bash
# Check current database structure
sqlite3 ~/.local/state/warp-terminal/warp.sqlite ".tables" | grep -i mcp

# Compare with expected tables
# Expected: mcp_environment_variables, mcp_server_panes

# Check schema changes
sqlite3 ~/.local/state/warp-terminal/warp.sqlite ".schema mcp_environment_variables"
```

**Adaptation Process:**
1. **Identify new MCP tables**: Look for tables containing "mcp" or "server"
2. **Analyze new schema**: Understand how API keys and server configs are stored
3. **Update backup scripts**: Modify to capture new table structure
4. **Update restoration scripts**: Ensure new format is properly restored
5. **Test thoroughly**: Verify MCP auto-start still works

### Scenario 2: Warp File Locations Changed

**Symptoms:**
- Backup scripts can't find configuration files
- Restoration fails with "file not found" errors

**Diagnosis Steps:**
```bash
# Find new Warp configuration locations
find ~ -name "warp.sqlite" 2>/dev/null
find ~ -name "user_preferences.json" 2>/dev/null
find ~ -type d -name "*warp*" 2>/dev/null
```

**Adaptation Process:**
1. **Update path variables** in all scripts:
   - `WARP_CONFIG` (usually ~/.config/warp-terminal)
   - `WARP_STATE` (usually ~/.local/state/warp-terminal)
2. **Test backup creation** with new paths
3. **Test restoration** to ensure files go to correct locations
4. **Update documentation** with new path information

### Scenario 3: MCP Implementation Changed

**Symptoms:**
- MCP servers backed up but don't auto-start after restoration
- API keys present but not working
- MCP servers require manual Start button

**Diagnosis Steps:**
```bash
# Check if MCP servers are in database
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT COUNT(*) FROM mcp_environment_variables;"

# Check API key format
sqlite3 ~/.local/state/warp-terminal/warp.sqlite "SELECT environment_variables FROM mcp_environment_variables LIMIT 1;"

# Check for new MCP-related tables
sqlite3 ~/.local/state/warp-terminal/warp.sqlite ".tables" | grep -E "(mcp|server|pane)"
```

**Adaptation Process:**
1. **Analyze new MCP storage format**: How are servers and API keys stored?
2. **Update auto-start logic**: What triggers MCP servers to start automatically?
3. **Modify restoration script**: Ensure new auto-start mechanism is triggered
4. **Test extensively**: MCP servers must appear without manual intervention

## Code Modification Guidelines

### Safe Modification Principles
1. **Always backup current working system** before making changes
2. **Test on non-critical backups** first
3. **Preserve backward compatibility** when possible
4. **Document all changes** in this file

### Critical Code Sections

#### Backup Script Key Areas
```bash
# In warp-backup-enhanced.sh
# Critical: Database backup with integrity
sqlite3 "$WARP_STATE/warp.sqlite" ".backup '$BACKUP_PATH/critical/warp.sqlite'"

# Critical: MCP configuration export
# This section must capture all MCP data including API keys
```

#### Restoration Script Key Areas
```bash
# In restore-complete-warp-settings.sh
# Critical: SQLite temp file cleanup
rm -f "$WARP_STATE/warp.sqlite-shm" "$WARP_STATE/warp.sqlite-wal"

# Critical: MCP auto-start configuration
# This section ensures MCP servers start automatically
```

### Testing Checklist After Modifications

#### Backup Testing
- [ ] Creates backup without errors
- [ ] Backup contains all expected files
- [ ] MCP servers counted correctly in backup
- [ ] API keys preserved in backup database
- [ ] Backup size reasonable (~5MB typical)

#### Restoration Testing
- [ ] Restores without errors
- [ ] Theme/settings match original
- [ ] MCP servers appear in Warp sidebar automatically
- [ ] API keys work (no authentication errors)
- [ ] No manual configuration required

#### System Integration Testing
- [ ] Fish aliases work correctly
- [ ] warp-health command shows correct status
- [ ] Backup protection (read-only files) works
- [ ] Snapper snapshot creation works

## Emergency Procedures

### If System Completely Broken
```bash
# 1. Identify last known good backup
ls -la ~/.warp-settings-manager/backups/

# 2. Manual restoration (bypass scripts)
pkill -f warp-terminal
cp ~/.warp-settings-manager/backups/GOOD_BACKUP/critical/warp.sqlite ~/.local/state/warp-terminal/
cp ~/.warp-settings-manager/backups/GOOD_BACKUP/critical/user_preferences.json ~/.config/warp-terminal/

# 3. Restart Warp and verify functionality
```

### If Backup System Corrupted
```bash
# 1. Recreate basic backup manually
mkdir -p ~/emergency-warp-backup-$(date +%Y%m%d)
cp ~/.config/warp-terminal/user_preferences.json ~/emergency-warp-backup-$(date +%Y%m%d)/
cp ~/.local/state/warp-terminal/warp.sqlite ~/emergency-warp-backup-$(date +%Y%m%d)/

# 2. Rebuild system from GitHub repository
# (Repository should contain all necessary files)
```

## Communication with User

### When Changes Are Needed
1. **Explain the problem clearly**: What changed in Warp that broke the system?
2. **Describe the solution**: What modifications are needed?
3. **Provide testing plan**: How will you verify the fix works?
4. **Offer rollback plan**: How to restore if changes fail?

### Success Criteria to Report
- ✅ All existing backups still work
- ✅ New backups capture all necessary data
- ✅ MCP servers auto-start after restoration
- ✅ API keys preserved and functional
- ✅ System hardening features intact
- ✅ User commands unchanged (backward compatibility)

## Long-term Maintenance Notes

### System Longevity Features
- **Self-contained design**: Minimal external dependencies
- **File-based approach**: Doesn't rely on Warp APIs that might change
- **Protected backups**: Read-only files prevent accidental deletion
- **Comprehensive metadata**: Full information for future debugging

### Monitoring Health
```bash
# Regular health checks
warp-health                    # Check current MCP status
warp-list-backups             # Verify backup system working
du -sh ~/.warp-settings-manager/backups/  # Monitor storage usage
```

### When to Consider Major Overhaul
- Warp completely changes configuration storage (unlikely)
- Multiple components failing simultaneously
- User reports consistent failures across different scenarios
- New Warp features require fundamental system changes

## Final Notes for Future AI

This system was designed to be resilient and maintainable. The core principle is simple: completely preserve all Warp configuration files and restore them atomically. The complexity comes from ensuring MCP servers auto-start and API keys are preserved.

When in doubt, focus on these priorities:
1. **Data preservation**: Never lose user configurations or API keys
2. **Auto-start functionality**: Users should never need manual intervention
3. **System stability**: Changes should not break existing functionality
4. **Backward compatibility**: Old backups should continue to work

The user values reliability and long-term stability over new features. When making changes, err on the side of caution and always provide rollback options.
