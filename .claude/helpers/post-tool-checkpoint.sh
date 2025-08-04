#!/bin/bash
# Post-Tool-Use Checkpoint Handler
# Creates checkpoints after significant tool operations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE=".claude/checkpoint-config.json"
CHECKPOINT_DIR=".claude/checkpoints"
METRICS_FILE=".claude/checkpoints/tool-metrics.json"

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        POST_TOOL_CHECKPOINTS=$(jq -r '.post_tool_checkpoints // "selective"' "$CONFIG_FILE")
        CHECKPOINT_INTERVAL=$(jq -r '.checkpoint_interval // "300"' "$CONFIG_FILE")
        CHECKPOINT_TOOLS=$(jq -r '.checkpoint_tools // ["Write", "MultiEdit", "Task"]' "$CONFIG_FILE")
        MIN_CHANGES=$(jq -r '.min_changes_for_checkpoint // "5"' "$CONFIG_FILE")
        AUTO_PUSH=$(jq -r '.auto_push // "true"' "$CONFIG_FILE")
    else
        POST_TOOL_CHECKPOINTS="selective"
        CHECKPOINT_INTERVAL="300"
        CHECKPOINT_TOOLS='["Write", "MultiEdit", "Task"]'
        MIN_CHANGES="5"
        AUTO_PUSH="true"
    fi
}

# Initialize metrics
init_metrics() {
    if [ ! -f "$METRICS_FILE" ]; then
        echo '{"tool_uses": 0, "checkpoints_created": 0, "last_checkpoint": null}' > "$METRICS_FILE"
    fi
}

# Update metrics
update_metrics() {
    local tool="$1"
    local action="$2"
    
    local tool_uses=$(jq -r '.tool_uses' "$METRICS_FILE")
    local checkpoints_created=$(jq -r '.checkpoints_created' "$METRICS_FILE")
    
    if [ "$action" = "tool_use" ]; then
        tool_uses=$((tool_uses + 1))
    elif [ "$action" = "checkpoint" ]; then
        checkpoints_created=$((checkpoints_created + 1))
    fi
    
    jq --arg tool_uses "$tool_uses" \
       --arg checkpoints_created "$checkpoints_created" \
       --arg last_tool "$tool" \
       --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '.tool_uses = ($tool_uses | tonumber) | 
        .checkpoints_created = ($checkpoints_created | tonumber) | 
        .last_tool = $last_tool |
        .last_update = $timestamp' "$METRICS_FILE" > "$METRICS_FILE.tmp" && \
    mv "$METRICS_FILE.tmp" "$METRICS_FILE"
}

# Check if checkpoint is needed
should_checkpoint() {
    local tool="$1"
    local input="$2"
    
    load_config
    
    # Check if post-tool checkpoints are enabled
    if [ "$POST_TOOL_CHECKPOINTS" = "disabled" ]; then
        return 1
    fi
    
    # Check if this tool should trigger checkpoints
    if [ "$POST_TOOL_CHECKPOINTS" = "selective" ]; then
        if ! echo "$CHECKPOINT_TOOLS" | jq -r '.[]' | grep -q "^$tool$"; then
            return 1
        fi
    fi
    
    # Check time since last checkpoint
    if [ -f "$METRICS_FILE" ]; then
        local last_checkpoint=$(jq -r '.last_checkpoint // "1970-01-01T00:00:00Z"' "$METRICS_FILE")
        local last_timestamp=$(date -d "$last_checkpoint" +%s 2>/dev/null || echo 0)
        local current_timestamp=$(date +%s)
        local time_diff=$((current_timestamp - last_timestamp))
        
        if [ "$time_diff" -lt "$CHECKPOINT_INTERVAL" ]; then
            # Too soon since last checkpoint
            return 1
        fi
    fi
    
    # Check number of changes
    local change_count=$(git status --porcelain | wc -l)
    if [ "$change_count" -lt "$MIN_CHANGES" ]; then
        # Not enough changes
        return 1
    fi
    
    return 0
}

# Create post-tool checkpoint
create_post_tool_checkpoint() {
    local tool="$1"
    local input="$2"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local checkpoint_name="tool-checkpoint-$timestamp"
    
    # Extract relevant information based on tool
    local description=""
    case "$tool" in
        "Write"|"Edit"|"MultiEdit")
            local file=$(echo "$input" | jq -r '.file_path // .path // "unknown"')
            description="Modified $file"
            ;;
        "Task")
            local task_desc=$(echo "$input" | jq -r '.description // "task"')
            description="Executed task: $task_desc"
            ;;
        "Bash")
            local command=$(echo "$input" | jq -r '.command // "command"' | head -c 50)
            description="Ran command: $command..."
            ;;
        *)
            description="Tool operation: $tool"
            ;;
    esac
    
    # Create commit
    git add -A 2>/dev/null || true
    
    if git diff --cached --quiet 2>/dev/null; then
        echo -e "${BLUE}ℹ️  No changes to checkpoint after $tool operation${NC}"
        return 0
    fi
    
    local commit_message="Tool Checkpoint: $description

Automatic checkpoint after tool use
- Tool: $tool
- Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Changes: $(git diff --cached --stat | tail -1)

[Post-tool-checkpoint]"
    
    if git commit -m "$commit_message" --quiet; then
        echo -e "${GREEN}✅ Created post-tool checkpoint: $checkpoint_name${NC}"
        
        # Update metrics
        update_metrics "$tool" "checkpoint"
        jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '.last_checkpoint = $timestamp' "$METRICS_FILE" > "$METRICS_FILE.tmp" && \
        mv "$METRICS_FILE.tmp" "$METRICS_FILE"
        
        # Push if enabled
        if [ "$AUTO_PUSH" = "true" ]; then
            local current_branch=$(git branch --show-current)
            if git push origin "$current_branch" --quiet 2>&1; then
                echo -e "${GREEN}✅ Pushed checkpoint to GitHub${NC}"
            fi
        fi
        
        return 0
    else
        return 1
    fi
}

# Main handler
handle_post_tool() {
    local tool="$1"
    local input="$2"
    
    init_metrics
    update_metrics "$tool" "tool_use"
    
    if should_checkpoint "$tool" "$input"; then
        create_post_tool_checkpoint "$tool" "$input"
    fi
}

# Process input
if [ $# -lt 1 ]; then
    echo "Usage: $0 <tool> [input_json]"
    exit 1
fi

TOOL="$1"
INPUT="${2:-{}}"

# Handle the post-tool event
handle_post_tool "$TOOL" "$INPUT"