#!/bin/bash
# Claude Flow Bash Aliases
# Quick shortcuts for common claude-flow commands

# Basic claude-flow command
alias cf='npx claude-flow@alpha'

# Swarm command with claude integration
alias cfs='npx claude-flow@alpha swarm'

# Hive-mind spawn command with claude integration
alias cfh='npx claude-flow@alpha hive-mind spawn'

# Additional useful aliases
alias cfa='npx claude-flow@alpha agent'          # Agent management
alias cft='npx claude-flow@alpha task'           # Task management
alias cfm='npx claude-flow@alpha memory'         # Memory operations
alias cfc='npx claude-flow@alpha config'         # Configuration
alias cfi='npx claude-flow@alpha init'           # Initialize project
alias cfst='npx claude-flow@alpha status'        # Check status
alias cfp='npx claude-flow@alpha plan'           # Planning mode

# Function for swarm with objective (includes --claude flag automatically)
cfswarm() {
    if [ -z "$1" ]; then
        echo "Usage: cfswarm 'Your objective here'"
        echo "Example: cfswarm 'Build a REST API with authentication'"
        return 1
    fi
    npx claude-flow@alpha swarm "$1" --claude
}

# Function for hive-mind spawn with objective (includes --claude flag automatically)
cfhive() {
    if [ -z "$1" ]; then
        echo "Usage: cfhive 'Your objective here'"
        echo "Example: cfhive 'Analyze and optimize database queries'"
        return 1
    fi
    npx claude-flow@alpha hive-mind spawn "$1" --claude
}

# Quick help function
cfhelp() {
    echo "Claude Flow Aliases:"
    echo "  cf       - Basic claude-flow command"
    echo "  cfs      - Swarm command"
    echo "  cfh      - Hive-mind spawn command"
    echo "  cfa      - Agent management"
    echo "  cft      - Task management"
    echo "  cfm      - Memory operations"
    echo "  cfc      - Configuration"
    echo "  cfi      - Initialize project"
    echo "  cfst     - Check status"
    echo "  cfp      - Planning mode"
    echo ""
    echo "Functions:"
    echo "  cfswarm 'objective' - Run swarm with objective (auto-adds --claude)"
    echo "  cfhive 'objective'  - Run hive-mind with objective (auto-adds --claude)"
    echo "  cfhelp             - Show this help message"
}
