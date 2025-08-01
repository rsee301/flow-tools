# Fix for Agent Registration Issue

## Problem
The following agent types exist as definition files but are not registered in claude-flow:
- `analyst` - CI/CD analysis specialist
- `architect` - Software architecture specialist  
- `coordinator` - PR strategy coordinator

These agents have definition files in `.claude/agents/` but throw errors when trying to spawn them.

## Root Cause
The agent definition files exist locally but are not registered in the claude-flow agent registry. This is a mismatch between local agent definitions and the claude-flow system's available agents.

## Solutions

### Solution 1: Use Alternative Registered Agents (Recommended)
Instead of the unregistered agents, use these registered alternatives:

| Unregistered Agent | Use This Instead | Purpose |
|-------------------|------------------|---------|
| `analyst` | `code-analyzer` | Code quality and CI/CD analysis |
| `architect` | `system-architect` | System architecture design |
| `coordinator` | `pr-manager` | PR strategy and coordination |

Example:
```bash
# Instead of:
Task("Analyze CI/CD", "...", "analyst")  # ❌ Will fail

# Use:
Task("Analyze CI/CD", "...", "code-analyzer")  # ✅ Works
```

### Solution 2: Register Custom Agents
If you need these specific agents, you can register them with claude-flow:

1. Ensure claude-flow is installed:
```bash
npm install -g claude-flow@alpha
```

2. Register the custom agents:
```bash
# Register each agent
npx claude-flow agent register ./claude/agents/analyst.md
npx claude-flow agent register ./claude/agents/architect.md
npx claude-flow agent register ./claude/agents/coordinator.md
```

### Solution 3: Update Agent Definitions
Rename the local agent definition files to match registered agents:

```bash
# Rename to match registered agents
mv .claude/agents/analyst.md .claude/agents/code-analyzer.md
mv .claude/agents/architect.md .claude/agents/system-architect.md
mv .claude/agents/coordinator.md .claude/agents/pr-manager.md
```

Then update the `name:` field in each file to match the new filename.

## Verification
To verify which agents are available:

```bash
# List all available agents
npx claude-flow@alpha list-agents

# Or check the error message when using an invalid agent
# It will show all available agents
```

## Best Practice
Always verify agent availability before using them in your workflows. The error message helpfully lists all available agents when you try to use an invalid one.