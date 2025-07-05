# Warp Terminal Research Findings

## Executive Summary

This document contains comprehensive research findings about Warp terminal's configuration system, account management, and settings preservation mechanisms on Arch Linux. The research reveals critical insights into how Warp stores configurations and the challenges with settings persistence across account changes.

## Key Findings

### 1. Configuration Storage Architecture

Warp uses a multi-layered configuration storage system:

#### Primary Configuration Locations:
- **User Preferences**: `/home/carnateo/.config/warp-terminal/user_preferences.json`
- **Local State**: `/home/carnateo/.local/state/warp-terminal/`
- **Cache**: `/home/carnateo/.cache/warp-terminal/`

#### Configuration File Structure:
```
~/.config/warp-terminal/
├── user_preferences.json          # Main settings file
├── user_preferences.json.backup   # Automatic backup
└── user_preferences.json.wayland_broken  # Platform-specific backup

~/.local/state/warp-terminal/
├── warp.sqlite                    # Main database
├── warp.log                       # Application logs
├── warp_network.log              # Network activity logs
├── mcp/                          # MCP server configurations
└── codebase_index_snapshots/     # AI codebase indexing

~/.cache/warp-terminal/
├── settings.dat                   # Cached settings
├── attachments/                   # File attachments
├── completed/                     # Completed operations
├── new/                          # New operations
└── pending/                      # Pending operations
```

### 2. Settings Synchronization System

#### Warp Drive vs Local Storage:
- **Local Storage**: All settings stored in `user_preferences.json` and SQLite database
- **Warp Drive**: Cloud-based synchronization for logged-in users
- **Settings Sync**: Beta feature that syncs most settings to cloud servers
- **Non-synced Settings**: Custom keybindings, custom themes, device-specific settings

#### Current User Status:
- User is currently "signed in without an account"
- Settings Sync is enabled (`"IsSettingsSyncEnabled": "true"`)
- Warp Drive Context is disabled (`"WarpDriveContextEnabled": "false"`)

### 3. MCP Server Configuration

#### Storage Location:
- MCP configurations stored in `/home/carnateo/.local/state/warp-terminal/mcp/`
- Log files with random IDs (e.g., `5io20kHJRmNk3Dv7XPjQJB.log`)
- Database tables: `mcp_server_panes`, `mcp_environment_variables`

#### Current MCP Setup:
- Multiple MCP server log files present
- MCP execution path configured: `/home/carnateo/bin:/home/carnateo/.local/bin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl`

### 4. Database Schema Analysis

#### Key Tables in warp.sqlite:
```sql
-- User and account management
current_user_information
users
user_profiles

-- MCP configuration
mcp_server_panes
mcp_environment_variables

-- Settings and preferences
settings_panes

-- AI and collaboration
agent_conversations
agent_tasks
ai_blocks
ai_queries

-- Workspace organization
workspaces
workspace_teams
teams
```

### 5. Theme and UI Configuration

#### Current Settings:
- Theme: "GruvboxDark"
- Font: "Hack" (AI font matching enabled)
- Font Size: 13.0
- Cursor: Block type
- Spacing: Compact
- Input Box Type: Universal

### 6. Account Management Challenges

#### The Core Problem:
1. **Account-Tied Settings**: When creating new Warp accounts, settings are tied to the account identity
2. **Warp Drive Override**: New accounts get fresh Warp Drive configurations
3. **Local vs Cloud Conflict**: Local settings may be overridden by cloud-synced (empty) settings
4. **MCP Server Loss**: MCP configurations are not preserved across account changes

#### Settings Sync Behavior:
- When Settings Sync is enabled, the current device's settings become the default for all devices
- Toggling Settings Sync off and on causes all devices to adopt settings from the current logged-in instance
- Non-synced settings (custom themes, keybindings, device-specific settings) are never preserved

### 7. Installation and System Integration

#### Binary Location:
- Main executable: `/usr/bin/warp-terminal`
- Desktop file: `/usr/share/applications/dev.warp.Warp.desktop`
- Icons: `/usr/share/icons/hicolor/*/apps/dev.warp.Warp.png`

#### Package Management:
- Installed via AUR package `warp-terminal-bin`
- Cache location: `/home/carnateo/.cache/paru/clone/warp-terminal-bin`

## Critical Insights for Solution Development

### 1. Settings Preservation Strategy
- **Local Backup Required**: Must backup `user_preferences.json` before account changes
- **Database Export Needed**: SQLite database contains MCP and other critical configurations
- **Selective Restore**: Need to restore specific settings while preserving account-specific data

### 2. MCP Server Persistence
- **Configuration Location**: MCP settings in database and log files
- **Environment Variables**: Stored in `mcp_environment_variables` table
- **Server Definitions**: Likely stored in `mcp_server_panes` table

### 3. Account Management Workaround
- **Stay Logged Out**: Current "signed in without an account" state preserves local settings
- **Backup Before Login**: Always backup configurations before creating/switching accounts
- **Selective Sync**: Disable Settings Sync to prevent cloud override of local settings

### 4. Automation Opportunities
- **Pre-Login Backup**: Script to backup all configurations before account operations
- **Post-Login Restore**: Script to restore specific settings after account creation
- **MCP Preservation**: Dedicated MCP server configuration backup/restore

## Next Steps for Implementation

1. **Create Backup Scripts**: Automate backup of all critical configuration files
2. **Develop Restore Mechanism**: Selective restoration of settings without breaking account functionality
3. **MCP Server Management**: Dedicated tools for MCP server configuration preservation
4. **Testing Strategy**: Safe testing environment for account switching scenarios

## References

- Warp Documentation: Settings Sync (Beta)
- Warp Drive Documentation
- GitHub Issues: #175 (Configuration Files), #4209 (Default Terminal Setup)
- Local file analysis and database schema examination
