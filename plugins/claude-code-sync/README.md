# claude-code-sync

Synchronize your Claude Code configurations across multiple machines seamlessly using Git.

## Features

- **Multi-Platform Support**: Works on macOS, Linux, ARM32, and ARM64 architectures
- **Comprehensive Sync**: Syncs MCP configurations, settings, custom commands, and skills
- **Machine-Specific Configs**: Maintains separate configurations for each machine while allowing sharing
- **Git-Based**: Uses Git for version control and conflict resolution
- **Automatic Backups**: Creates backups before pulling configurations
- **Safe Operations**: Never overwrites without backing up first

## What Gets Synced

- `.mcp.json` - MCP server configurations
- `settings.json` - Claude Code settings and preferences
- `commands/` - Custom slash commands
- `skills/` - Custom skills

## Installation

### Prerequisites

- Git installed and configured
- **GitHub CLI (gh)** installed and authenticated
- Claude Code installed

### Installing GitHub CLI

The sync tool uses GitHub CLI for authentication, which works seamlessly across all platforms without SSH key setup.

**macOS:**
```bash
brew install gh
```

**Linux/Raspberry Pi:**
```bash
# Debian/Ubuntu/Raspberry Pi OS
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

**Authenticate GitHub CLI:**
```bash
gh auth login
# Choose: GitHub.com → HTTPS → Login with a web browser
```

### Quick Install

```bash
# Clone the plugins repository (or install via /plugin in Claude Code)
git clone https://github.com/BioInfo/claude-code-plugins.git ~/claude-code-plugins

# Add to PATH (add to your ~/.bashrc or ~/.zshrc)
export PATH="$HOME/claude-code-plugins/claude-code-sync:$PATH"

# Or create a symlink
sudo ln -s ~/claude-code-plugins/claude-code-sync/sync-claude.sh /usr/local/bin/sync-claude

# Initialize the sync repository (will create if it doesn't exist)
sync-claude init
```

## Usage

### First Time Setup

On your primary machine (the one with your current Claude Code setup):

```bash
# Initialize and push your configuration
sync-claude push
```

This will:
1. Create a backup of your current configuration
2. Initialize the sync repository
3. Push your configuration to GitHub

### Setting Up Other Machines

On each additional machine:

```bash
# Pull configuration from GitHub
sync-claude pull
```

This will:
1. Create a backup of any existing configuration
2. Pull the configuration from GitHub
3. Restore it to your local Claude Code directory

### Regular Sync

To keep machines in sync:

```bash
# Full sync (pull + push)
sync-claude sync

# Or individually:
sync-claude pull   # Get latest from GitHub
sync-claude push   # Send changes to GitHub
```

### Other Commands

```bash
# Show sync status
sync-claude status

# List all machine configurations
sync-claude list

# Create a backup only
sync-claude backup

# Show help
sync-claude help
```

## Configuration

The sync script uses these default settings:

- **Claude Directory**: `~/.claude`
- **Sync Repository**: `git@github.com:BioInfo/claude-code-sync.git`
- **Sync Directory**: `~/.claude-sync`
- **Machine Name**: Derived from hostname

You can modify these by editing the script or setting environment variables.

## How It Works

### Directory Structure

```
~/.claude-sync/
├── machines/
│   ├── macbook-pro/
│   │   ├── .mcp.json
│   │   ├── settings.json
│   │   ├── commands/
│   │   ├── skills/
│   │   └── machine-info.json
│   ├── raspberrypi/
│   └── dgx-spark/
└── shared/
    └── (optional shared configurations)
```

Each machine gets its own directory, allowing machine-specific configurations while still syncing through Git.

### Sync Process

1. **Push**: Copies files from `~/.claude` to `~/.claude-sync/machines/[hostname]`, commits, and pushes to GitHub
2. **Pull**: Fetches from GitHub and copies files from `~/.claude-sync/machines/[hostname]` to `~/.claude`
3. **Sync**: Performs pull followed by push

### Conflict Resolution

Since each machine has its own directory, conflicts are rare. If they occur:

1. The script will notify you of Git conflicts
2. Resolve conflicts manually in `~/.claude-sync`
3. Commit the resolution
4. Run `sync-claude push` again

## Examples

### Example 1: New Machine Setup

```bash
# On your Mac (existing setup)
sync-claude push

# On your Raspberry Pi (new setup)
sync-claude pull
```

### Example 2: Regular Workflow

```bash
# Morning routine - get latest from all machines
sync-claude pull

# Make changes to Claude Code configs
# Edit ~/.claude/settings.json, add commands, etc.

# End of day - push your changes
sync-claude push
```

### Example 3: Full Sync

```bash
# Pull latest, make your changes, and push in one command
sync-claude sync
```

## Automation

### Automated Sync with Cron

Add to crontab for automatic syncing:

```bash
# Sync every hour
0 * * * * ~/claude-code-plugins/claude-code-sync/sync-claude.sh sync >> ~/logs/claude-sync.log 2>&1

# Push at end of work day (5 PM)
0 17 * * 1-5 ~/claude-code-plugins/claude-code-sync/sync-claude.sh push >> ~/logs/claude-sync.log 2>&1
```

### Automated Sync with launchd (macOS)

Create `~/Library/LaunchAgents/com.bioinfo.claude-sync.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.bioinfo.claude-sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/bioinfo/claude-code-plugins/claude-code-sync/sync-claude.sh</string>
        <string>sync</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>17</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/bioinfo/logs/claude-sync.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/bioinfo/logs/claude-sync.error.log</string>
</dict>
</plist>
```

Load with:
```bash
launchctl load ~/Library/LaunchAgents/com.bioinfo.claude-sync.plist
```

## Security Considerations

- **GitHub CLI Authentication**: Uses GitHub CLI for secure, token-based authentication (no SSH keys needed)
- **Private Repository**: The sync repository is created as private by default
- **Secrets**: Never sync API keys or secrets (use environment variables instead)
- **Backups**: Always created before pulling - stored in `~/.claude-backup-*`

## Troubleshooting

### GitHub CLI Not Authenticated

```bash
# Check authentication status
gh auth status

# If not authenticated, login
gh auth login
# Choose: GitHub.com → HTTPS → Login with a web browser

# Verify authentication
gh auth status
```

### GitHub CLI Not Installed

The script will provide installation instructions if gh is not found. Follow the instructions for your platform above.

### Merge Conflicts

```bash
# Go to sync directory
cd ~/.claude-sync

# Check status
git status

# Resolve conflicts manually
# Edit conflicting files

# Complete the merge
git add .
git commit -m "Resolved conflicts"
sync-claude push
```

### Machine Not Found

```bash
# List available machines
sync-claude list

# Initialize this machine
sync-claude push
```

## Advanced Usage

### Custom Sync Items

Edit `sync-claude.sh` and modify the `SYNC_ITEMS` array:

```bash
SYNC_ITEMS=(
    ".mcp.json"
    "settings.json"
    "commands"
    "skills"
    "your-custom-file.json"  # Add your items
)
```

### Shared Configurations

Place shared configs in `~/.claude-sync/shared/` and create symbolic links:

```bash
# On each machine
cd ~/.claude
ln -s ~/.claude-sync/shared/common-commands commands/common
```

## Integration with Claude Code

The sync script works seamlessly with Claude Code. After syncing:

1. Restart Claude Code to pick up configuration changes
2. MCP servers will use updated `.mcp.json`
3. New commands and skills are immediately available

## Related Tools

This plugin is part of the Claude Code Plugins collection:
- [claude-code-plugins](https://github.com/BioInfo/claude-code-plugins) - Main repository

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a Pull Request

## License

MIT License

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- See the main [claude-code-plugins](https://github.com/BioInfo/claude-code-plugins) repository

## Created With

This plugin was created collaboratively with [Claude Code](https://claude.com/claude-code).
