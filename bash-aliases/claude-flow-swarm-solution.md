# Claude Flow Swarm - Working Solution

## The Issue
The `cfswarm` command tries to spawn a new Claude Code instance, which fails with "require is not defined". This is because the swarm should work through Claude Code's MCP tools, not by spawning new instances.

## Solution: Use MCP Tools Directly

Instead of using `cfswarm` from the terminal, use Claude Flow swarm through the MCP tools inside Claude Code:

### Method 1: Direct MCP Tool Usage

1. **Initialize the swarm:**
   ```
   mcp__claude-flow__swarm_init { topology: "mesh", maxAgents: 5, strategy: "balanced" }
   ```

2. **Spawn agents:**
   ```
   mcp__claude-flow__agent_spawn { type: "researcher", name: "Research Agent" }
   mcp__claude-flow__agent_spawn { type: "coder", name: "Implementation Agent" }
   mcp__claude-flow__agent_spawn { type: "analyst", name: "Analysis Agent" }
   ```

3. **Orchestrate your task:**
   ```
   mcp__claude-flow__task_orchestrate { task: "Your objective here", strategy: "parallel" }
   ```

### Method 2: Use Task Tool with Swarm Agents

After initializing the swarm with MCP tools, use Claude Code's Task tool to spawn specialized agents:

```
Task("Research best practices for REST API design", "research-agent", "researcher")
Task("Implement authentication endpoints", "implementation-agent", "coder")
Task("Analyze performance bottlenecks", "analysis-agent", "analyst")
```

### Method 3: Create a Helper Script

Save this to `run-swarm.sh`:

```bash
#!/bin/bash
echo "Claude Flow Swarm Instructions:"
echo "================================"
echo ""
echo "Since cfswarm can't spawn new Claude instances, use these MCP commands in Claude Code:"
echo ""
echo "1. Initialize swarm:"
echo "   mcp__claude-flow__swarm_init { topology: 'mesh', maxAgents: 5 }"
echo ""
echo "2. Spawn agents based on your needs:"
echo "   mcp__claude-flow__agent_spawn { type: 'researcher' }"
echo "   mcp__claude-flow__agent_spawn { type: 'coder' }"
echo "   mcp__claude-flow__agent_spawn { type: 'analyst' }"
echo ""
echo "3. Orchestrate your objective:"
echo "   mcp__claude-flow__task_orchestrate { task: '$1' }"
echo ""
echo "Your objective: $1"
```

## Working Example

Here's what I just did to verify the swarm works:

1. Used `mcp__claude-flow__swarm_init` - Successfully initialized swarm with ID: swarm_1753902939204_pt9knvjo1
2. The swarm is now ready to spawn agents and orchestrate tasks

## Key Points

- The MCP servers (claude-flow and ruv-swarm) are properly connected ✓
- Claude Flow v2.0.0-alpha.78 is installed and working ✓
- The swarm must be controlled through MCP tools inside Claude Code
- The `--claude` flag in cfswarm tries to spawn new instances (doesn't work)
- Use the MCP coordination approach for full swarm functionality

## Quick Start Command

To quickly get started with a swarm in Claude Code, just tell me:
"Initialize a swarm and help me [your objective]"

And I'll set up the swarm using the MCP tools and coordinate the agents for you!