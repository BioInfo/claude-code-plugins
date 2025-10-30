# Sync Pull Configuration

Pull Claude Code configuration from another machine in the sync repository.

## Task

Execute the claude-code-sync tool to pull configuration:

1. IMPORTANT: Before pulling, create a backup of the current configuration
2. Run the sync-claude script with the `pull` command
3. The script will:
   - Initialize the sync repository if needed
   - Create an automatic backup at `~/.claude-backup-[timestamp]`
   - Pull latest changes from GitHub
   - Look for machine-specific configuration for this hostname
   - Copy configuration files to `~/.claude`
4. Report what was restored and from which machine

Command to run:
```bash
# Find the installed plugin location
PLUGIN_PATH=$(find ~/.claude/plugins/marketplaces -name "sync-claude.sh" -type f 2>/dev/null | head -1)

# Run the pull command
if [ -n "$PLUGIN_PATH" ]; then
    "$PLUGIN_PATH" pull
else
    echo "Error: sync-claude.sh not found. Please install the claude-code-sync plugin first."
    exit 1
fi
```

After completion, summarize:
- What files were restored
- Whether a backup was created (and its location)
- Any warnings or issues
- Reminder to restart Claude Code if needed
