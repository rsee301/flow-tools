# Claude Flow Bash Aliases

Quick and convenient bash/zsh aliases for common `claude-flow` commands.

## Installation

```bash
# Make the install script executable
chmod +x install.sh

# Run the installer
./install.sh
```

The installer will:
1. Detect your shell configuration file (`.bashrc`, `.zshrc`, etc.)
2. Add the aliases to your shell configuration
3. Create a backup of your configuration file

## Usage

After installation, you can use these shortcuts:

### Basic Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cf` | `npx claude-flow@alpha` | Basic claude-flow command |
| `cfs` | `npx claude-flow@alpha swarm` | Swarm command |
| `cfh` | `npx claude-flow@alpha hive-mind spawn` | Hive-mind spawn command |
| `cfa` | `npx claude-flow@alpha agent` | Agent management |
| `cft` | `npx claude-flow@alpha task` | Task management |
| `cfm` | `npx claude-flow@alpha memory` | Memory operations |
| `cfc` | `npx claude-flow@alpha config` | Configuration |
| `cfi` | `npx claude-flow@alpha init` | Initialize project |
| `cfst` | `npx claude-flow@alpha status` | Check status |
| `cfp` | `npx claude-flow@alpha plan` | Planning mode |

### Functions

#### `cfswarm`
Run a swarm with an objective (automatically adds `--claude` flag):
```bash
cfswarm "Build a REST API with authentication"
```

#### `cfhive`
Run hive-mind spawn with an objective (automatically adds `--claude` flag):
```bash
cfhive "Analyze and optimize database queries"
```

#### `cfhelp`
Display help for all available aliases:
```bash
cfhelp
```

## Examples

```bash
# Basic usage
cf --help                              # Show claude-flow help
cfs --list                             # List available swarms

# Using the convenience functions
cfswarm "Create a user authentication system with JWT tokens"
cfhive "Refactor the codebase to improve performance"

# Quick commands
cfa list                               # List agents
cft status                             # Check task status
cfm store key value                    # Store in memory
```

## Uninstallation

To remove the aliases:

```bash
# Make the uninstall script executable
chmod +x uninstall.sh

# Run the uninstaller
./uninstall.sh
```

## Customization

You can edit `claude-flow-aliases.sh` to add your own custom aliases or modify existing ones. After making changes, reload your shell configuration:

```bash
source ~/.bashrc  # or ~/.zshrc for zsh users
```

## Troubleshooting

### Aliases not working
1. Make sure you've restarted your terminal or run `source ~/.bashrc` (or `~/.zshrc`)
2. Check that the aliases file path in your shell config is correct
3. Verify that `claude-flow-aliases.sh` exists and is readable

### Permission denied
Make sure the scripts are executable:
```bash
chmod +x install.sh uninstall.sh
```

### Wrong shell detected
You can manually add the following to your shell configuration file:
```bash
# Claude Flow Aliases
if [ -f "/path/to/flow-tools/bash-aliases/claude-flow-aliases.sh" ]; then
    source "/path/to/flow-tools/bash-aliases/claude-flow-aliases.sh"
fi
```
