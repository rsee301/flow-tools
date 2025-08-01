# Claude-Flow Subagents Configuration

This document explains how to configure custom subagents for claude-flow to properly spawn specialized agents.

## Overview

Claude-flow uses custom subagents to perform specialized tasks. These agents must be defined as markdown files with YAML frontmatter in the `.claude/agents/` directory.

## Required Agents

The following agents are required for claude-flow operations:

### 1. Analyst Agent
- **Purpose**: Analyzes CI/CD files and build configurations
- **File**: `.claude/agents/analyst.md`
- **Tools**: Read, Grep, Glob, Bash, WebFetch

### 2. Architect Agent  
- **Purpose**: Analyzes core implementation and system architecture
- **File**: `.claude/agents/architect.md`
- **Tools**: Read, Grep, Glob, Task, WebSearch

### 3. Coordinator Agent
- **Purpose**: Creates PR strategies and manages code review workflows
- **File**: `.claude/agents/coordinator.md`
- **Tools**: Read, Grep, Glob, Bash, Task, WebFetch

## Installation

The required agent files have been created in the `.claude/agents/` directory. These files define:
- Agent name (matching what claude-flow expects)
- Description of when to use the agent
- Available tools for the agent
- System prompt defining the agent's behavior

## Custom Agents

You can create additional custom agents by:

1. Creating a new markdown file in `.claude/agents/`
2. Adding YAML frontmatter with:
   ```yaml
   ---
   name: your-agent-name
   description: "When this agent should be used"
   tools: Tool1, Tool2, Tool3
   ---
   ```
3. Writing a detailed system prompt below the frontmatter

## Troubleshooting

If you encounter "Agent type 'X' not found" errors:
1. Ensure the `.claude/agents/` directory exists
2. Verify the agent file exists with the exact name
3. Check that the YAML frontmatter is properly formatted
4. Confirm the agent name in the file matches what claude-flow expects

## Available Default Agents

The system includes many built-in agents like:
- general-purpose
- code-analyzer
- pr-manager
- task-orchestrator
- And many more...

These can be used without additional configuration.