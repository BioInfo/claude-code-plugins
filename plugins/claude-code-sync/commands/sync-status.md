# Sync Status

Show the current status of Claude Code configuration sync.

## Task

Execute the claude-code-sync tool to show sync status:

1. Run the sync-claude script with the `status` command
2. The script will display:
   - Current machine name
   - Claude Code directory location
   - Sync directory location
   - Git repository status
   - Last commit information
3. Present the information in a clear, formatted way

Command to run:
```bash
# Find the installed plugin location
PLUGIN_PATH=$(find ~/.claude/plugins/marketplaces -name "sync-claude.sh" -type f 2>/dev/null | head -1)

# Run the status command
if [ -n "$PLUGIN_PATH" ]; then
    "$PLUGIN_PATH" status
else
    echo "Error: sync-claude.sh not found. Please install the claude-code-sync plugin first."
    exit 1
fi
```

After completion, summarize the key information in a user-friendly format.
