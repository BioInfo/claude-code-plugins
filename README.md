# Claude Code Plugins

A plugin marketplace for [Claude Code](https://claude.com/claude-code) to enhance your development workflow.

## Installation

Add this marketplace to Claude Code:

```bash
# Add the marketplace (you'll be prompted to confirm)
/plugin add-marketplace https://github.com/BioInfo/claude-code-plugins.git
```

Or add it manually by editing `~/.claude/plugins/known_marketplaces.json`:

```json
{
  "bioinfo-plugins": {
    "source": {
      "source": "github",
      "repo": "BioInfo/claude-code-plugins"
    },
    "installLocation": "/Users/YOUR_USER/.claude/plugins/marketplaces/bioinfo-plugins"
  }
}
```

Then install individual plugins:

```bash
/plugin install claude-code-sync
```

## Available Plugins

### 🔄 claude-code-sync

Synchronize your Claude Code configurations across multiple machines seamlessly.

**Features:**
- Sync MCP configurations (.mcp.json)
- Sync settings and preferences (settings.json)
- Sync custom commands (slash commands)
- Sync custom skills
- Multi-platform support (macOS, Linux, ARM32, ARM64)
- Git-based synchronization for version control
- Intelligent conflict resolution
- Machine-specific overrides

**Slash Commands:**
- `/sync-push` - Push local configuration to GitHub
- `/sync-pull` - Pull configuration from GitHub
- `/sync-full` - Full bidirectional sync
- `/sync-status` - Show sync status
- `/sync-list` - List all machine configurations

**[Documentation →](./plugins/claude-code-sync/README.md)**

## Plugin Development

Each plugin should be in its own directory under `plugins/` with the following structure:

```
plugins/
└── your-plugin/
    ├── .claude-plugin/
    │   └── plugin.json      # Required manifest
    ├── commands/            # Optional slash commands
    ├── agents/              # Optional custom agents
    ├── skills/              # Optional skills
    └── hooks/               # Optional hooks
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see individual plugin directories for specific licensing information.

## Created With

These plugins were created collaboratively with [Claude Code](https://claude.com/claude-code).
