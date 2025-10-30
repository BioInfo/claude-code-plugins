#!/bin/bash
#
# Claude Code Configuration Sync
# Synchronizes Claude Code configurations across multiple machines
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR="$HOME/.claude"
SYNC_REPO_OWNER="BioInfo"
SYNC_REPO_NAME="claude-code-sync"
SYNC_DIR="$HOME/.claude-sync"
MACHINE_NAME=$(hostname -s)

# Items to sync
SYNC_ITEMS=(
    ".mcp.json"
    "settings.json"
    "commands"
    "skills"
)

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install git first."
        exit 1
    fi
}

# Function to check if gh CLI is installed and authenticated
check_gh() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed."
        print_info "Install it with:"
        print_info "  macOS:        brew install gh"
        print_info "  Linux:        See https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        print_info "  Raspberry Pi: curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
        print_info "                echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
        print_info "                sudo apt update && sudo apt install gh"
        exit 1
    fi

    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI is not authenticated."
        print_info "Please authenticate with: gh auth login"
        print_info "Choose 'HTTPS' as the protocol when prompted."
        exit 1
    fi

    print_success "GitHub CLI authenticated"
}

# Function to get repository URL using gh CLI
get_repo_url() {
    # Use HTTPS URL with gh CLI credential helper
    echo "https://github.com/${SYNC_REPO_OWNER}/${SYNC_REPO_NAME}.git"
}

# Function to initialize sync repository
init_sync_repo() {
    print_info "Initializing sync repository..."

    local repo_url=$(get_repo_url)

    if [ -d "$SYNC_DIR" ]; then
        print_warning "Sync directory already exists: $SYNC_DIR"
        cd "$SYNC_DIR"

        # Configure git to use gh CLI credentials
        git config credential.helper ""
        git config --local credential.helper '!gh auth git-credential'

        git pull origin main 2>/dev/null || print_warning "Could not pull from remote"
    else
        print_info "Cloning sync repository..."

        # Clone using HTTPS with gh CLI credentials
        GIT_TERMINAL_PROMPT=0 gh repo clone "${SYNC_REPO_OWNER}/${SYNC_REPO_NAME}" "$SYNC_DIR" 2>/dev/null || {
            print_warning "Repository doesn't exist yet. Creating new repository..."
            mkdir -p "$SYNC_DIR"
            cd "$SYNC_DIR"
            git init
            git branch -M main

            # Configure git to use gh CLI credentials
            git config --local credential.helper '!gh auth git-credential'
            git remote add origin "$repo_url" 2>/dev/null || true

            # Create initial commit
            echo "# Claude Code Sync" > README.md
            echo "" >> README.md
            echo "Machine-specific Claude Code configurations" >> README.md
            mkdir -p machines shared
            git add .
            git commit -m "Initial commit" || true

            # Create repository on GitHub if it doesn't exist
            print_info "Creating repository on GitHub..."
            gh repo create "${SYNC_REPO_OWNER}/${SYNC_REPO_NAME}" --private --source=. --remote=origin --push 2>/dev/null || {
                print_warning "Could not create repository. It may already exist."
                git push -u origin main 2>/dev/null || print_warning "Could not push to remote"
            }
        }
    fi

    # Create machine-specific directory
    mkdir -p "$SYNC_DIR/machines/$MACHINE_NAME"
    mkdir -p "$SYNC_DIR/shared"

    print_success "Sync repository ready"
}

# Function to backup current configuration
backup_config() {
    local backup_dir="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"
    print_info "Creating backup at: $backup_dir"

    if [ -d "$CLAUDE_DIR" ]; then
        cp -r "$CLAUDE_DIR" "$backup_dir"
        print_success "Backup created"
    else
        print_warning "No existing Claude Code configuration to backup"
    fi
}

# Function to push configuration to sync repository
push_config() {
    print_info "Pushing configuration to sync repository..."

    cd "$SYNC_DIR"

    # Copy items to machine-specific directory
    for item in "${SYNC_ITEMS[@]}"; do
        if [ -e "$CLAUDE_DIR/$item" ]; then
            print_info "Syncing: $item"

            if [ -d "$CLAUDE_DIR/$item" ]; then
                # It's a directory
                rm -rf "$SYNC_DIR/machines/$MACHINE_NAME/$item"
                cp -r "$CLAUDE_DIR/$item" "$SYNC_DIR/machines/$MACHINE_NAME/"
            else
                # It's a file
                cp "$CLAUDE_DIR/$item" "$SYNC_DIR/machines/$MACHINE_NAME/"
            fi

            print_success "Synced: $item"
        else
            print_warning "Not found: $item"
        fi
    done

    # Create machine info file
    cat > "$SYNC_DIR/machines/$MACHINE_NAME/machine-info.json" <<EOF
{
    "hostname": "$MACHINE_NAME",
    "platform": "$(uname -s)",
    "architecture": "$(uname -m)",
    "last_sync": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "user": "$USER"
}
EOF

    # Git operations
    git add .

    if git diff --cached --quiet; then
        print_info "No changes to push"
    else
        git commit -m "Sync from $MACHINE_NAME at $(date '+%Y-%m-%d %H:%M:%S')"

        if git push origin main 2>/dev/null; then
            print_success "Configuration pushed successfully"
        else
            print_warning "Could not push to remote. You may need to push manually later."
            print_info "Run: cd $SYNC_DIR && git push origin main"
        fi
    fi
}

# Function to pull configuration from sync repository
pull_config() {
    print_info "Pulling configuration from sync repository..."

    cd "$SYNC_DIR"

    # Pull latest changes
    git pull origin main 2>/dev/null || {
        print_warning "Could not pull from remote. Using local copy."
    }

    # Create Claude directory if it doesn't exist
    mkdir -p "$CLAUDE_DIR"

    # Check if machine-specific config exists
    if [ -d "$SYNC_DIR/machines/$MACHINE_NAME" ]; then
        print_info "Found machine-specific configuration"

        # Copy machine-specific items
        for item in "${SYNC_ITEMS[@]}"; do
            if [ -e "$SYNC_DIR/machines/$MACHINE_NAME/$item" ]; then
                print_info "Restoring: $item"

                if [ -d "$SYNC_DIR/machines/$MACHINE_NAME/$item" ]; then
                    # It's a directory
                    rm -rf "$CLAUDE_DIR/$item"
                    cp -r "$SYNC_DIR/machines/$MACHINE_NAME/$item" "$CLAUDE_DIR/"
                else
                    # It's a file
                    cp "$SYNC_DIR/machines/$MACHINE_NAME/$item" "$CLAUDE_DIR/"
                fi

                print_success "Restored: $item"
            fi
        done

        print_success "Configuration pulled successfully"
    else
        print_warning "No machine-specific configuration found for: $MACHINE_NAME"
        print_info "Available machines:"
        ls -1 "$SYNC_DIR/machines/" 2>/dev/null || echo "  (none)"
    fi
}

# Function to list available machine configurations
list_machines() {
    print_info "Available machine configurations:"

    if [ -d "$SYNC_DIR/machines" ]; then
        for machine in "$SYNC_DIR/machines"/*; do
            if [ -d "$machine" ]; then
                machine_name=$(basename "$machine")

                if [ -f "$machine/machine-info.json" ]; then
                    echo ""
                    echo -e "${GREEN}$machine_name${NC}"
                    cat "$machine/machine-info.json" | grep -E "(platform|architecture|last_sync)" | sed 's/^/  /'
                else
                    echo -e "${GREEN}$machine_name${NC}"
                fi
            fi
        done
    else
        print_warning "No machines found in sync repository"
    fi
}

# Function to show status
show_status() {
    print_info "Claude Code Sync Status"
    echo ""
    echo "Machine: $MACHINE_NAME"
    echo "Claude Directory: $CLAUDE_DIR"
    echo "Sync Directory: $SYNC_DIR"
    echo ""

    if [ -d "$SYNC_DIR" ]; then
        cd "$SYNC_DIR"
        echo "Git Status:"
        git status --short
        echo ""
        echo "Last Commit:"
        git log -1 --oneline 2>/dev/null || echo "  (no commits yet)"
    else
        print_warning "Sync directory not initialized"
    fi
}

# Function to show help
show_help() {
    cat <<EOF
Claude Code Configuration Sync

Usage: $(basename "$0") [command]

Commands:
    push        Push current configuration to sync repository
    pull        Pull configuration from sync repository
    sync        Pull then push (full sync)
    init        Initialize sync repository
    status      Show sync status
    list        List available machine configurations
    backup      Create backup of current configuration
    help        Show this help message

Examples:
    $(basename "$0") push      # Push your current config
    $(basename "$0") pull      # Pull config from another machine
    $(basename "$0") sync      # Full sync (pull + push)

Configuration:
    Repository: ${SYNC_REPO_OWNER}/${SYNC_REPO_NAME}
    Sync Directory: $SYNC_DIR
    Machine Name: $MACHINE_NAME
    Authentication: GitHub CLI (gh)

EOF
}

# Main command handling
main() {
    check_git
    check_gh

    case "${1:-help}" in
        init)
            init_sync_repo
            ;;
        push)
            init_sync_repo
            push_config
            ;;
        pull)
            init_sync_repo
            backup_config
            pull_config
            ;;
        sync)
            init_sync_repo
            backup_config
            pull_config
            push_config
            ;;
        status)
            show_status
            ;;
        list)
            init_sync_repo
            list_machines
            ;;
        backup)
            backup_config
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
