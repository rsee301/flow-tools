# GitHub Checkpoint System

The GitHub Checkpoint System automatically creates commits and pushes to GitHub whenever you prompt Claude, providing automatic version control and backup for your work.

## Features

- **Automatic Commits**: Creates a commit with all changes whenever you send a prompt to Claude
- **Post-Tool Checkpoints**: Creates checkpoints after significant tool operations (Write, Edit, Task, Bash)
- **Automatic Push**: Pushes changes to GitHub immediately after committing
- **Branch Protection**: Prevents direct pushes to main/master by creating checkpoint branches
- **Tagging**: Creates tags for each checkpoint for easy reference
- **Metadata Tracking**: Stores checkpoint metadata with timestamps and prompts
- **Rollback Support**: Easy rollback to any previous checkpoint
- **Configurable**: Fully customizable behavior through configuration file
- **Smart Intervals**: Prevents checkpoint spam with configurable time intervals
- **Change Thresholds**: Only creates checkpoints when minimum changes are met

## Installation

The checkpoint system is already integrated into your Claude Code setup. The hook is automatically triggered when you submit a prompt.

## Configuration

Edit the configuration file at `.claude/checkpoint-config.json`:

```json
{
  "auto_push": true,                   // Automatically push to GitHub
  "auto_commit": true,                 // Automatically commit changes
  "commit_prefix": "Checkpoint",       // Prefix for commit messages
  "branch_protection": true,           // Create branches instead of pushing to main
  "max_checkpoints": 100,              // Maximum checkpoints to keep
  "push_to_branch": "current",         // Branch strategy
  "create_tags": true,                 // Create tags for checkpoints
  "verbose": true,                     // Show detailed output
  
  // Post-Tool Checkpoint Settings
  "post_tool_checkpoints": "selective", // "all", "selective", or "disabled"
  "checkpoint_interval": 300,           // Minimum seconds between checkpoints
  "checkpoint_tools": [                 // Tools that trigger checkpoints
    "Write", 
    "MultiEdit", 
    "Task", 
    "Bash"
  ],
  "min_changes_for_checkpoint": 3       // Minimum file changes needed
}
```

## Usage

### Automatic Checkpoints

Simply use Claude as normal. The system creates checkpoints in two ways:

#### 1. Prompt-Based Checkpoints
Every time you send a prompt, the system will:
- Check for uncommitted changes
- Create a commit with your prompt as part of the message
- Tag the commit with a timestamp
- Push to GitHub (creating a checkpoint branch if needed)

#### 2. Post-Tool Checkpoints
After significant tool operations (Write, Edit, Task, Bash), the system will:
- Check if enough time has passed since last checkpoint (default: 5 minutes)
- Verify minimum changes threshold is met (default: 3 files)
- Create a commit describing the tool operation
- Push to GitHub automatically if enabled

This ensures your work is continuously backed up without creating excessive commits.

### Manual Commands

```bash
# Check checkpoint system status
.claude/helpers/github-checkpoint.sh status

# Manually create a checkpoint
.claude/helpers/github-checkpoint.sh create "Your checkpoint message"

# Push current state to GitHub
.claude/helpers/github-checkpoint.sh push

# Show configuration file location
.claude/helpers/github-checkpoint.sh config
```

### Managing Checkpoints

```bash
# List all checkpoints
.claude/helpers/checkpoint-manager.sh list

# Show details of a specific checkpoint
.claude/helpers/checkpoint-manager.sh show checkpoint-20240130-143022

# Rollback to a checkpoint
.claude/helpers/checkpoint-manager.sh rollback checkpoint-20240130-143022

# Show diff since checkpoint
.claude/helpers/checkpoint-manager.sh diff checkpoint-20240130-143022

# Clean old checkpoints
.claude/helpers/checkpoint-manager.sh clean
```

## Checkpoint Structure

Each checkpoint creates:

1. **Git Commit**: Contains all changes with descriptive message
2. **Git Tag**: `checkpoint-YYYYMMDD-HHMMSS` format for easy reference
3. **Metadata File**: JSON file in `.claude/checkpoints/` with details
4. **Branch** (if protection enabled): `checkpoint/checkpoint-YYYYMMDD-HHMMSS`

## Rollback Options

### Soft Rollback (Default)
```bash
.claude/helpers/checkpoint-manager.sh rollback checkpoint-20240130-143022
```
- Preserves working directory changes
- Creates a stash of current changes
- Safe for experimentation

### Hard Rollback
```bash
.claude/helpers/checkpoint-manager.sh rollback checkpoint-20240130-143022 --hard
```
- Completely resets to checkpoint state
- **Warning**: Discards all uncommitted changes

### Branch Rollback
```bash
.claude/helpers/checkpoint-manager.sh rollback checkpoint-20240130-143022 --branch
```
- Creates a new branch from checkpoint
- Preserves current branch state
- Useful for exploring alternatives

## GitHub Integration

When pushing to GitHub:

1. **Protected Branches**: If pushing to main/master, creates a checkpoint branch instead
2. **Tags**: All checkpoint tags are pushed for remote reference
3. **GitHub URL**: Displays the GitHub URL for easy access

## Best Practices

1. **Regular Cleanup**: The system automatically cleans checkpoints older than the configured maximum
2. **Meaningful Prompts**: Your prompts become part of the commit message, so be descriptive
3. **Branch Strategy**: Enable branch protection to avoid accidental main branch pushes
4. **Review Changes**: Use `git status` or the checkpoint manager to review changes

## Troubleshooting

### Checkpoint Not Creating

1. Check if Git is initialized: `git status`
2. Verify remote is configured: `git remote -v`
3. Check configuration: `.claude/checkpoint-config.json`
4. Review logs: `.claude/checkpoints/checkpoint.log`

### Push Failing

1. Ensure you have push access to the repository
2. Check if branch protection rules are blocking pushes
3. Verify your Git credentials are configured
4. Try manual push: `git push origin <branch>`

### Configuration Not Loading

1. Ensure the config file has valid JSON syntax
2. Check file permissions
3. Run status command to verify configuration

## Security Considerations

- The system respects your Git configuration and credentials
- No sensitive data is stored in checkpoint metadata
- Branch protection prevents accidental main branch modifications
- All operations use standard Git commands

## Integration with Claude Flow

The checkpoint system integrates with Claude Flow hooks:
- Triggered via `user-prompt-submit-hook` in settings.json
- Coordinates with other Claude Flow features
- Supports parallel operations and swarm coordination

For more information, see the main Claude Flow documentation.