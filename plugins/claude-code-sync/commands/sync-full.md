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
~/apps/claude-code-plugins/claude-code-sync/sync-claude.sh sync
```

After completion, summarize:
- Whether any changes were pulled from other machines
- What local changes were pushed
- Backup location (if created)
- Current sync status
