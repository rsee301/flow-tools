#!/bin/bash
# Fixed Claude Flow Swarm Command

# Working swarm function that properly connects to Claude Code
cfswarm_fixed() {
    if [ -z "$1" ]; then
        echo "Usage: cfswarm_fixed 'Your objective here'"
        echo "Example: cfswarm_fixed 'Build a REST API with authentication'"
        return 1
    fi
    
    echo "🐝 Initializing Claude Flow Swarm..."
    echo "📋 Objective: $1"
    echo ""
    
    # Use the MCP connection directly instead of CLI spawn
    echo "Using MCP server connection for swarm coordination..."
    
    # The swarm should work through the MCP tools in Claude Code
    # rather than trying to spawn a new Claude instance
    npx claude-flow@alpha swarm "$1" --strategy auto --mode distributed --max-agents 5 --parallel
}

# Alternative: Direct MCP usage instructions
cfswarm_mcp() {
    echo "To use Claude Flow Swarm with MCP:"
    echo "1. In Claude Code, use the mcp__claude-flow__swarm_init tool"
    echo "2. Then use mcp__claude-flow__agent_spawn to create agents"
    echo "3. Finally use mcp__claude-flow__task_orchestrate with your objective"
    echo ""
    echo "Example workflow:"
    echo "  mcp__claude-flow__swarm_init { topology: 'mesh', maxAgents: 5 }"
    echo "  mcp__claude-flow__agent_spawn { type: 'researcher' }"
    echo "  mcp__claude-flow__agent_spawn { type: 'coder' }"
    echo "  mcp__claude-flow__task_orchestrate { task: '$1' }"
}

# Export the functions
export -f cfswarm_fixed
export -f cfswarm_mcp