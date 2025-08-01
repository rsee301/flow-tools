# Agent Name Mapping Guide

## Problem
When using claude-flow, you may encounter errors like:
```
Error: Agent type 'analyst' not found
Error: Agent type 'architect' not found
Error: Agent type 'coordinator' not found
```

This happens because the agent names have been updated in the latest version of claude-flow.

## Solution: Use the Correct Agent Names

### Old Name → New Name Mapping

| Old/Incorrect Name | Correct Agent Name | Description |
|-------------------|-------------------|-------------|
| `analyst` | `code-analyzer` | Code quality analysis agent |
| `architect` | `system-architect` | High-level system design |
| `architect` | `architecture` | SPARC Architecture phase specialist |
| `coordinator` | `task-orchestrator` | Central task coordination |
| `coordinator` | `hierarchical-coordinator` | Queen-led hierarchical swarm |
| `coordinator` | `sparc-coord` | SPARC methodology orchestrator |

## Complete List of Available Agents (54 Total)

### Core Development Agents
- `coder` - Implementation specialist
- `reviewer` - Code quality assurance
- `tester` - Test creation and validation
- `planner` - Strategic planning
- `researcher` - Information gathering

### Swarm Coordination Agents
- `hierarchical-coordinator` - Queen-led coordination
- `mesh-coordinator` - Peer-to-peer networks
- `adaptive-coordinator` - Dynamic topology
- `collective-intelligence-coordinator` - Hive-mind intelligence
- `swarm-memory-manager` - Distributed memory

### Consensus & Distributed Systems
- `byzantine-coordinator` - Byzantine fault tolerance
- `raft-manager` - Leader election protocols
- `gossip-coordinator` - Epidemic dissemination
- `consensus-builder` - Decision-making algorithms
- `crdt-synchronizer` - Conflict-free replication
- `quorum-manager` - Dynamic quorum management
- `security-manager` - Cryptographic security

### Performance & Optimization
- `perf-analyzer` - Bottleneck identification
- `performance-benchmarker` - Performance testing
- `task-orchestrator` - Workflow optimization
- `memory-coordinator` - Memory management
- `smart-agent` - Intelligent coordination

### GitHub & Repository Management
- `github-modes` - Comprehensive GitHub integration
- `pr-manager` - Pull request management
- `code-review-swarm` - Multi-agent code review
- `issue-tracker` - Issue management
- `release-manager` - Release coordination
- `workflow-automation` - CI/CD automation
- `project-board-sync` - Project tracking
- `repo-architect` - Repository optimization
- `multi-repo-swarm` - Cross-repository coordination
- `swarm-pr` - PR swarm management
- `swarm-issue` - Issue-based swarm coordination
- `release-swarm` - Release orchestration
- `sync-coordinator` - Multi-repo synchronization

### SPARC Methodology Agents
- `sparc-coord` - SPARC orchestration
- `sparc-coder` - TDD implementation
- `specification` - Requirements analysis
- `pseudocode` - Algorithm design
- `architecture` - System design
- `refinement` - Iterative improvement

### Specialized Development
- `backend-dev` - API development
- `mobile-dev` - React Native development
- `ml-developer` - Machine learning
- `cicd-engineer` - CI/CD pipelines
- `api-docs` - OpenAPI documentation
- `system-architect` - High-level design
- `code-analyzer` - Code quality analysis
- `base-template-generator` - Boilerplate creation

### Testing & Validation
- `tdd-london-swarm` - Mock-driven TDD
- `production-validator` - Real implementation validation

### Migration & Planning
- `migration-planner` - System migrations
- `swarm-init` - Topology initialization

### General Purpose
- `general-purpose` - General-purpose agent for complex tasks

## Usage Examples

### Incorrect Usage (Will Fail)
```bash
# These will produce errors
Task("Analyze code", "...", "analyst")  # ❌ Wrong
Task("Design system", "...", "architect")  # ❌ Wrong
Task("Coordinate tasks", "...", "coordinator")  # ❌ Wrong
```

### Correct Usage
```bash
# Use the correct agent names
Task("Analyze code quality", "...", "code-analyzer")  # ✅ Correct
Task("Design system architecture", "...", "system-architect")  # ✅ Correct
Task("Coordinate task execution", "...", "task-orchestrator")  # ✅ Correct
```

### Example: CI/CD Analysis with Correct Agents
```bash
# Instead of using 'analyst', 'architect', and 'coordinator'
# Use the correct specialized agents:

Task("Analyze CI/CD configuration", "Review GitHub Actions workflows", "code-analyzer")
Task("Design CI/CD architecture", "Plan optimal pipeline structure", "system-architect")
Task("Coordinate PR strategy", "Create comprehensive PR plan", "pr-manager")
```

## Tips for Choosing the Right Agent

1. **For Analysis Tasks**: Use `code-analyzer` instead of `analyst`
2. **For Architecture Tasks**: Use `system-architect` or `architecture` (for SPARC)
3. **For Coordination Tasks**: Choose the specific coordinator:
   - `task-orchestrator` for general task coordination
   - `hierarchical-coordinator` for hierarchical swarm structure
   - `sparc-coord` for SPARC methodology coordination
   - `pr-manager` for PR-specific coordination

## Verifying Available Agents

To see all available agents in your claude-flow installation:
```bash
npx claude-flow@alpha list-agents
```

Or check the error message which lists all available agents when an invalid agent is specified.