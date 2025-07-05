# Warp Terminal Technical Analysis

## Configuration File Deep Dive

### user_preferences.json Structure

The main configuration file contains all user settings in JSON format:

```json
{
  "prefs": {
    // Core Settings
    "Theme": "\"GruvboxDark\"",
    "FontSize": "13.0",
    "AIFontName": "\"Hack\"",
    "CursorDisplayType": "\"Block\"",
    "Spacing": "\"Compact\"",
    "InputBoxTypeSetting": "\"Universal\"",
    
    // Account & Sync
    "IsSettingsSyncEnabled": "true",
    "WarpDriveContextEnabled": "false",
    "DidNonAnonymousUserLogIn": "true",
    
    // MCP Configuration
    "MCPExecutionPath": "\"/home/carnateo/bin:/home/carnateo/.local/bin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl\"",
    
    // AI Settings
    "AvailableLLMs": "{...}", // Complex JSON string with model configurations
    "AIRequestLimitInfo": "{...}", // Usage limits and quotas
    
    // Feature Flags
    "AgentModeCodingPermissions": "\"AlwaysAllowReading\"",
    "AgentModeCodebaseContextAutoIndexing": "true",
    "VoiceInputEnabled": "false",
    "TelemetryEnabled": "false",
    "CrashReportingEnabled": "false"
  }
}
```

### SQLite Database Schema

#### Key Tables for Settings Preservation:

1. **mcp_server_panes**
   - Stores MCP server configurations
   - Schema: `id INTEGER PRIMARY KEY`, `kind TEXT DEFAULT 'mcp_server'`

2. **mcp_environment_variables**
   - Environment variables for MCP servers
   - Critical for MCP functionality

3. **settings_panes**
   - UI settings and preferences
   - Schema: `id INTEGER`, `kind TEXT DEFAULT 'settings'`, `current_page TEXT DEFAULT 'Account'`

4. **current_user_information**
   - Currently empty (user not logged into account)
   - Would contain account-specific data when logged in

5. **workspaces** & **workspace_teams**
   - Warp Drive workspace configurations
   - Team collaboration settings

## Account Management Flow Analysis

### Current State: "Signed in without an account"
```
User Status: Authenticated but no cloud account
Settings Sync: Enabled (but no cloud account to sync to)
Warp Drive: Disabled
Local Storage: All settings stored locally
```

### Problem Scenario: Creating New Account
```
1. User creates new Warp account
2. Warp enables cloud synchronization
3. Empty cloud settings override local settings
4. MCP servers, themes, and custom configurations lost
5. User must reconfigure everything manually
```

### Root Cause Analysis

#### Settings Sync Behavior:
- **First Enable**: Current device settings become cloud defaults
- **Subsequent Logins**: Cloud settings override local settings
- **Account Switch**: New account = empty cloud settings = lost local config

#### Non-Synced Settings (Always Lost):
- Custom keybindings
- Custom themes
- Device-specific settings (editor preferences, startup shell)
- Platform-specific settings

#### Synced Settings (Preserved if same account):
- Built-in themes
- Most feature preferences
- AI settings
- Privacy settings

## MCP Server Configuration Analysis

### Storage Mechanism:
```
Database Tables:
- mcp_server_panes: Server definitions
- mcp_environment_variables: Environment configurations

File System:
- ~/.local/state/warp-terminal/mcp/*.log: Server logs
- Log files with random IDs indicate active/configured servers
```

### Current MCP Setup:
```
Active Log Files:
- 5io20kHJRmNk3Dv7XPjQJB.log (20KB)
- fCBooqRG9MLS2la71Xzj8m.log (17KB)
- FUSu2qGIpGUoYwZwTMQ1pk.log (17KB)
- HM85ph8P4j7FJXt9Bx7F1X.log (3KB)
- nNrR9wthLfUp8OsyAffrMT.log (3KB)
- WBGWCewvvEanDT0JShB7LF.log (110KB)

Execution Path: Standard Linux PATH with user bins prioritized
```

## File System Permissions and Security

### Current Permissions:
```bash
~/.config/warp-terminal/: drwxr-xr-x (755)
~/.local/state/warp-terminal/: drwxr-xr-x (755)
~/.cache/warp-terminal/: drwx------ (700)

Critical Files:
- user_preferences.json: -rw-r--r-- (644)
- warp.sqlite: -rw-r--r-- (644)
- settings.dat: -rw------- (600)
```

### Security Considerations:
- Configuration files readable by user only
- Cache directory has restricted permissions
- SQLite database contains sensitive information (API keys, tokens)
- MCP logs may contain command history and sensitive data

## Backup and Restore Strategy

### Critical Files to Backup:
```
Essential:
- ~/.config/warp-terminal/user_preferences.json
- ~/.local/state/warp-terminal/warp.sqlite
- ~/.cache/warp-terminal/settings.dat

MCP Specific:
- ~/.local/state/warp-terminal/mcp/ (entire directory)
- MCP-related database tables (export required)

Optional:
- ~/.local/state/warp-terminal/warp.log (for debugging)
- ~/.config/warp-terminal/*.backup (existing backups)
```

### Restore Challenges:
1. **Account ID Conflicts**: Database may contain account-specific IDs
2. **Timestamp Issues**: Settings may have timestamps that conflict
3. **Partial Restore**: Need to restore settings without breaking account functionality
4. **Database Integrity**: SQLite foreign key constraints may prevent partial restores

## Implementation Approach

### Phase 1: Backup System
```bash
# Create timestamped backup
backup_dir="~/.warp-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

# Backup critical files
cp ~/.config/warp-terminal/user_preferences.json "$backup_dir/"
cp ~/.local/state/warp-terminal/warp.sqlite "$backup_dir/"
cp -r ~/.local/state/warp-terminal/mcp/ "$backup_dir/"
cp ~/.cache/warp-terminal/settings.dat "$backup_dir/"
```

### Phase 2: Selective Restore
```bash
# Restore user preferences (merge approach)
# Extract non-account-specific settings
# Merge with current account-specific settings

# Restore MCP configurations
# Import MCP server definitions to database
# Restore MCP environment variables
# Copy MCP log files
```

### Phase 3: Automation
```bash
# Pre-account-creation hook
warp-backup-settings

# Post-account-creation hook
warp-restore-settings --selective

# MCP-specific tools
warp-backup-mcp
warp-restore-mcp
```

## Risk Assessment

### High Risk:
- Database corruption during restore
- Account authentication conflicts
- Loss of chat history (complex to preserve)

### Medium Risk:
- Partial setting restoration
- MCP server configuration conflicts
- Theme/UI inconsistencies

### Low Risk:
- Log file corruption
- Cache invalidation
- Temporary performance issues

## Testing Strategy

### Safe Testing Environment:
1. **VM/Container**: Test account switching in isolated environment
2. **Backup Verification**: Ensure backups contain all necessary data
3. **Restore Testing**: Test selective restore without breaking functionality
4. **MCP Validation**: Verify MCP servers work after restore

### Test Scenarios:
1. Backup → Create Account → Restore → Verify Settings
2. Backup → Switch Account → Restore → Verify MCP Servers
3. Backup → Delete Account → Restore → Verify Functionality
