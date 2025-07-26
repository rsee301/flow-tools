# Flow Tools

A personal toolset layer for claude-flow that maintains your custom MCPs, project preferences, and development configurations across projects.

## Overview

This repository acts as a companion to claude-flow, providing:
- Custom MCP tool management
- Project preference persistence
- Reusable templates and configurations
- Personalized development workflows

## Features

- **Custom MCP Integration**: Easily add and manage custom MCP tools
- **Preference System**: Maintain your development preferences across projects
- **Template Management**: Store and reuse project templates
- **Automated Setup**: Quick initialization for new projects
- **Sync Capabilities**: Keep preferences synchronized across environments

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/flow-tools.git
cd flow-tools

# Install dependencies
npm install

# Initialize the helper
npm run setup
```

## Usage

### Initialize Helper in a New Project

```bash
# In your project directory
npx flow-tools init
```

### Add Custom MCP Tool

```bash
# Add a new MCP tool to your collection
npx flow-tools add-mcp my-custom-tool
```

### Load Preferences

```bash
# Load your saved preferences into the current project
npx flow-tools load-preferences
```

### Sync Preferences

```bash
# Sync preferences from current project back to helper
npx flow-tools sync
```

### Bash Aliases

Quick shortcuts for common claude-flow commands:

```bash
# Install the aliases
cd bash-aliases
./install.sh

# Available aliases:
cf                              # npx claude-flow@alpha
cfs                             # npx claude-flow@alpha swarm
cfh                             # npx claude-flow@alpha hive-mind spawn
cfa                             # npx claude-flow@alpha agent
cft                             # npx claude-flow@alpha task
cfm                             # npx claude-flow@alpha memory
cfc                             # npx claude-flow@alpha config
cfi                             # npx claude-flow@alpha init
cfst                            # npx claude-flow@alpha status
cfp                             # npx claude-flow@alpha plan

# Convenience functions (auto-add --claude flag):
cfswarm "Build a REST API"      # npx claude-flow@alpha swarm "..." --claude
cfhive "Optimize database"      # npx claude-flow@alpha hive-mind spawn "..." --claude
cfhelp                          # Show all available aliases
```

See [bash-aliases/README.md](bash-aliases/README.md) for detailed documentation.

## Directory Structure

```
flow-tools/
├── src/                 # Core helper functionality
├── mcps/               # Custom MCP tools collection
├── preferences/        # User preferences and configurations
├── templates/          # Project templates
├── scripts/            # CLI scripts
├── bash-aliases/       # Convenient shell aliases for claude-flow
└── docs/              # Documentation
```

## Configuration

Preferences are stored in `preferences/config.yaml`:

```yaml
defaults:
  language: typescript
  testing: jest
  linting: eslint
  formatting: prettier

development:
  autoFormat: true
  autoTest: true
  gitHooks: true

mcps:
  enabled:
    - custom-analyzer
    - project-scaffolder
    - code-reviewer
```

## Custom MCP Tools

Add your custom MCP tools to the `mcps/` directory. Each tool should follow the MCP protocol specification.

Example structure:
```
mcps/
├── custom-analyzer/
│   ├── index.js
│   ├── package.json
│   └── README.md
└── project-scaffolder/
    ├── index.js
    ├── package.json
    └── README.md
```

## Integration with Claude Flow

This helper integrates seamlessly with claude-flow:

1. **Automatic Loading**: Preferences are automatically loaded when claude-flow starts
2. **MCP Registration**: Custom MCPs are registered with claude-flow
3. **Template Access**: Templates are available through claude-flow commands

## Contributing

Feel free to customize this helper to match your development workflow. Add your own:
- Custom MCP tools
- Project templates
- Preference configurations
- Utility scripts

## License

MIT