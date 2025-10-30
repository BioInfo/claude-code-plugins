# Full Sync

Perform a complete sync: pull latest changes, then push local changes.

## Task

Execute the claude-code-sync tool to perform a full bidirectional sync:

1. Run the sync-claude script with the `sync` command
2. The script will:
   - Create a backup of current configuration
   - Pull latest changes from GitHub
   - Merge any updates from other machines
   - Push local changes back to GitHub
3. This ensures all machines stay in sync

Command to run:
```bash
# Find the installed plugin location
PLUGIN_PATH=$(find ~/.claude/plugins/marketplaces -name "sync-claude.sh" -type f 2>/dev/null | head -1)

# Run the sync command
if [ -n "$PLUGIN_PATH" ]; then
    "$PLUGIN_PATH" sync
else
    echo "Error: sync-claude.sh not found. Please install the claude-code-sync plugin first."
    exit 1
fi
```

After completion, summarize:
- Whether any changes were pulled from other machines
- What local changes were pushed
- Backup location (if created)
- Current sync status
