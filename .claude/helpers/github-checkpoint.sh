#!/bin/bash
# GitHub Checkpoint System for Claude
# Automatically creates commits and pushes to GitHub on every Claude prompt

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHECKPOINT_DIR=".claude/checkpoints"
CONFIG_FILE=".claude/checkpoint-config.json"
LOG_FILE=".claude/checkpoints/checkpoint.log"

# Default configuration
DEFAULT_AUTO_PUSH="true"
DEFAULT_AUTO_COMMIT="true"
DEFAULT_COMMIT_PREFIX="Checkpoint"
DEFAULT_BRANCH_PROTECTION="true"
DEFAULT_MAX_CHECKPOINTS="100"

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        AUTO_PUSH=$(jq -r '.auto_push // "'$DEFAULT_AUTO_PUSH'"' "$CONFIG_FILE")
        AUTO_COMMIT=$(jq -r '.auto_commit // "'$DEFAULT_AUTO_COMMIT'"' "$CONFIG_FILE")
        COMMIT_PREFIX=$(jq -r '.commit_prefix // "'$DEFAULT_COMMIT_PREFIX'"' "$CONFIG_FILE")
        BRANCH_PROTECTION=$(jq -r '.branch_protection // "'$DEFAULT_BRANCH_PROTECTION'"' "$CONFIG_FILE")
        MAX_CHECKPOINTS=$(jq -r '.max_checkpoints // "'$DEFAULT_MAX_CHECKPOINTS'"' "$CONFIG_FILE")
    else
        AUTO_PUSH=$DEFAULT_AUTO_PUSH
        AUTO_COMMIT=$DEFAULT_AUTO_COMMIT
        COMMIT_PREFIX=$DEFAULT_COMMIT_PREFIX
        BRANCH_PROTECTION=$DEFAULT_BRANCH_PROTECTION
        MAX_CHECKPOINTS=$DEFAULT_MAX_CHECKPOINTS
    fi
}

# Initialize checkpoint system
init_checkpoint_system() {
    mkdir -p "$CHECKPOINT_DIR"
    
    # Create default config if not exists
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" <<EOF
{
  "auto_push": true,
  "auto_commit": true,
  "commit_prefix": "Checkpoint",
  "branch_protection": true,
  "max_checkpoints": 100,
  "push_to_branch": "current",
  "create_tags": true,
  "verbose": true
}
EOF
        echo -e "${GREEN}✅ Created default checkpoint configuration${NC}"
    fi
}

# Log function
log_message() {
    local message="$1"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        return 1
    fi
    return 0
}

# Create checkpoint
create_checkpoint() {
    local user_prompt="$1"
    local prompt_summary=$(echo "$user_prompt" | head -c 60 | tr '\n' ' ')
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local checkpoint_name="checkpoint-$timestamp"
    local current_branch=$(git branch --show-current)
    
    # Load config first
    load_config
    
    log_message "Creating checkpoint for prompt: $prompt_summary..."
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        if [ "$AUTO_COMMIT" == "true" ]; then
            # Stage all changes
            git add -A
            
            # Create commit message
            local commit_message="$COMMIT_PREFIX: $prompt_summary...

Automatic checkpoint created by Claude
- Branch: $current_branch
- Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Prompt: $user_prompt

[Auto-checkpoint]"
            
            # Commit changes
            if git commit -m "$commit_message" --quiet; then
                echo -e "${GREEN}✅ Created checkpoint commit: $checkpoint_name${NC}"
                log_message "Checkpoint commit created: $checkpoint_name"
                
                # Create tag
                if [ "$(jq -r '.create_tags // true' "$CONFIG_FILE")" = "true" ]; then
                    git tag -a "$checkpoint_name" -m "Checkpoint: $prompt_summary"
                    echo -e "${GREEN}✅ Created checkpoint tag: $checkpoint_name${NC}"
                fi
                
                # Store metadata
                local commit_hash=$(git rev-parse HEAD)
                cat > "$CHECKPOINT_DIR/$checkpoint_name.json" <<EOF
{
  "name": "$checkpoint_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "branch": "$current_branch",
  "commit": "$commit_hash",
  "prompt": "$user_prompt",
  "auto_pushed": false,
  "type": "user-prompt"
}
EOF
                
                # Push to remote if enabled
                if [ "$AUTO_PUSH" = "true" ]; then
                    push_checkpoint "$current_branch" "$checkpoint_name"
                fi
                
                # Clean old checkpoints
                clean_old_checkpoints
                
                return 0
            else
                echo -e "${YELLOW}⚠️  No changes to commit${NC}"
                log_message "No changes to commit"
                return 1
            fi
        else
            echo -e "${YELLOW}⚠️  Uncommitted changes exist (auto-commit disabled)${NC}"
            log_message "Uncommitted changes exist but auto-commit is disabled"
            return 1
        fi
    else
        echo -e "${BLUE}ℹ️  No changes to checkpoint${NC}"
        log_message "No changes to checkpoint"
        return 0
    fi
}

# Push checkpoint to remote
push_checkpoint() {
    local branch="$1"
    local checkpoint_name="$2"
    
    # Check if remote exists
    if ! git remote | grep -q origin; then
        echo -e "${YELLOW}⚠️  No remote 'origin' configured${NC}"
        log_message "No remote origin configured"
        return 1
    fi
    
    # Check branch protection
    if [ "$BRANCH_PROTECTION" = "true" ] && [ "$branch" = "main" -o "$branch" = "master" ]; then
        echo -e "${YELLOW}⚠️  Branch protection enabled for $branch${NC}"
        echo -e "${BLUE}ℹ️  Creating checkpoint branch instead${NC}"
        
        local checkpoint_branch="checkpoint/$checkpoint_name"
        git checkout -b "$checkpoint_branch" --quiet
        branch="$checkpoint_branch"
    fi
    
    echo -e "${BLUE}🔄 Pushing to remote branch: $branch${NC}"
    
    # Push with tags
    if git push origin "$branch" --tags 2>&1; then
        echo -e "${GREEN}✅ Successfully pushed checkpoint to GitHub${NC}"
        log_message "Pushed checkpoint to GitHub: $branch"
        
        # Update metadata
        if [ -f "$CHECKPOINT_DIR/$checkpoint_name.json" ]; then
            jq '.auto_pushed = true' "$CHECKPOINT_DIR/$checkpoint_name.json" > "$CHECKPOINT_DIR/$checkpoint_name.json.tmp" && \
            mv "$CHECKPOINT_DIR/$checkpoint_name.json.tmp" "$CHECKPOINT_DIR/$checkpoint_name.json"
        fi
        
        # Show GitHub URL if available
        local remote_url=$(git remote get-url origin 2>/dev/null)
        if [[ "$remote_url" =~ github.com ]]; then
            local github_url=$(echo "$remote_url" | sed -E 's|git@github.com:|https://github.com/|; s|\.git$||')
            echo -e "${BLUE}📍 View on GitHub: $github_url/tree/$branch${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}❌ Failed to push to GitHub${NC}"
        log_message "Failed to push to GitHub"
        return 1
    fi
}

# Clean old checkpoints
clean_old_checkpoints() {
    local checkpoint_count=$(find "$CHECKPOINT_DIR" -name "checkpoint-*.json" -type f | wc -l)
    
    if [ "$checkpoint_count" -gt "$MAX_CHECKPOINTS" ]; then
        local to_delete=$((checkpoint_count - MAX_CHECKPOINTS))
        echo -e "${YELLOW}🧹 Cleaning $to_delete old checkpoints...${NC}"
        
        # Delete oldest checkpoint files
        find "$CHECKPOINT_DIR" -name "checkpoint-*.json" -type f -printf "%T@ %p\n" | \
            sort -n | head -n "$to_delete" | cut -d' ' -f2- | xargs rm -f
        
        log_message "Cleaned $to_delete old checkpoints"
    fi
}

# Show checkpoint status
show_status() {
    echo -e "${BLUE}📊 GitHub Checkpoint System Status${NC}"
    echo ""
    
    load_config
    
    echo -e "${YELLOW}Configuration:${NC}"
    echo "  Auto-commit: $AUTO_COMMIT"
    echo "  Auto-push: $AUTO_PUSH"
    echo "  Branch protection: $BRANCH_PROTECTION"
    echo "  Max checkpoints: $MAX_CHECKPOINTS"
    echo ""
    
    if check_git_repo; then
        echo -e "${YELLOW}Repository:${NC}"
        echo "  Current branch: $(git branch --show-current)"
        echo "  Remote: $(git remote get-url origin 2>/dev/null || echo 'Not configured')"
        echo "  Uncommitted changes: $(git status --porcelain | wc -l) files"
        echo ""
        
        echo -e "${YELLOW}Recent checkpoints:${NC}"
        find "$CHECKPOINT_DIR" -name "checkpoint-*.json" -type f -printf "%T@ %p\n" | \
            sort -rn | head -5 | while read -r line; do
            local file=$(echo "$line" | cut -d' ' -f2-)
            local name=$(basename "$file" .json)
            local timestamp=$(jq -r '.timestamp' "$file")
            local pushed=$(jq -r '.auto_pushed' "$file")
            echo "  $name - $timestamp (pushed: $pushed)"
        done
    fi
}

# Main function
main() {
    local action="$1"
    shift
    
    init_checkpoint_system
    
    case "$action" in
        create)
            if check_git_repo; then
                create_checkpoint "$*"
            fi
            ;;
        status)
            show_status
            ;;
        push)
            if check_git_repo; then
                local branch=$(git branch --show-current)
                push_checkpoint "$branch" "manual-$(date +%Y%m%d-%H%M%S)"
            fi
            ;;
        config)
            echo "Edit configuration at: $CONFIG_FILE"
            ;;
        *)
            echo "Usage: $0 {create|status|push|config} [args]"
            echo ""
            echo "Commands:"
            echo "  create <prompt>  - Create checkpoint for user prompt"
            echo "  status          - Show checkpoint system status"
            echo "  push            - Manually push current state"
            echo "  config          - Show config file location"
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"