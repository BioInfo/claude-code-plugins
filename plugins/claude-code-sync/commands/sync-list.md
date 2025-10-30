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
~/apps/claude-code-plugins/claude-code-sync/sync-claude.sh list
```

After completion, format and present:
- Machine names
- Platform and architecture for each
- Last sync timestamp
- Highlight the current machine if present
