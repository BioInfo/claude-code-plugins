# Sync Push Configuration

Push your current Claude Code configuration to the sync repository.

## Task

Execute the claude-code-sync tool to push the current machine's configuration:

1. Run the sync-claude script with the `push` command
2. The script will:
   - Initialize the sync repository if needed (clone from GitHub)
   - Copy configuration files from `~/.claude` to the sync directory
   - Sync: `.mcp.json`, `settings.json`, `commands/`, and `skills/`
   - Create a machine-specific directory under `machines/[hostname]/`
   - Commit and push changes to GitHub
3. Report success and show what was synced

Command to run:
```bash
# Find the installed plugin location
PLUGIN_PATH=$(find ~/.claude/plugins/marketplaces -name "sync-claude.sh" -type f 2>/dev/null | head -1)

# Run the push command
if [ -n "$PLUGIN_PATH" ]; then
    "$PLUGIN_PATH" push
else
    echo "Error: sync-claude.sh not found. Please install the claude-code-sync plugin first."
    exit 1
fi
```

After completion, summarize:
- What files were synced
- The machine name
- Confirmation that changes were pushed to GitHub
