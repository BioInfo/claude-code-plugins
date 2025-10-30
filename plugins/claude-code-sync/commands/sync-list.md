# Sync List Machines

List all machine configurations available in the sync repository.

## Task

Execute the claude-code-sync tool to list all machines:

1. Run the sync-claude script with the `list` command
2. The script will:
   - Initialize and pull latest from the sync repository
   - Scan the `machines/` directory
   - Display each machine with its metadata
   - Show platform, architecture, and last sync time
3. Present the information in a clear table or list format

Command to run:
```bash
# Find the installed plugin location
PLUGIN_PATH=$(find ~/.claude/plugins/marketplaces -name "sync-claude.sh" -type f 2>/dev/null | head -1)

# Run the list command
if [ -n "$PLUGIN_PATH" ]; then
    "$PLUGIN_PATH" list
else
    echo "Error: sync-claude.sh not found. Please install the claude-code-sync plugin first."
    exit 1
fi
```

After completion, format and present:
- Machine names
- Platform and architecture for each
- Last sync timestamp
- Highlight the current machine if present
