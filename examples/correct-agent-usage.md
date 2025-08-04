# Correct Agent Usage Examples

This demonstrates how to properly spawn agents using the correct registered names.

## Example 1: CI/CD Analysis with Correct Agents

Instead of using the unregistered `analyst`, `architect`, and `coordinator` agents, use the correct registered alternatives:

```javascript
// ❌ WRONG - These will fail with "agent not found" errors
Task("Analyze CI/CD files", "Review GitHub Actions workflows", "analyst")
Task("Analyze core implementation", "Review system architecture", "architect") 
Task("Create PR strategy", "Coordinate pull request workflow", "coordinator")

// ✅ CORRECT - Use registered agent names
Task("Analyze CI/CD files", "Review GitHub Actions workflows and identify improvements", "code-analyzer")
Task("Analyze core implementation", "Review system architecture and design patterns", "system-architect")
Task("Create PR strategy", "Coordinate pull request workflow and review process", "pr-manager")
```

## Example 2: Full Development Swarm with Proper Agents

```javascript
// Deploy a complete development swarm using correct agent names
[BatchTool]:
  // Initialize swarm
  mcp__claude-flow__swarm_init { topology: "hierarchical", maxAgents: 6 }
  
  // Spawn agents with correct names
  mcp__claude-flow__agent_spawn { type: "code-analyzer", name: "CI/CD Analyst" }
  mcp__claude-flow__agent_spawn { type: "system-architect", name: "Architecture Lead" }
  mcp__claude-flow__agent_spawn { type: "pr-manager", name: "PR Coordinator" }
  mcp__claude-flow__agent_spawn { type: "coder", name: "Implementation Dev" }
  mcp__claude-flow__agent_spawn { type: "tester", name: "QA Engineer" }
  mcp__claude-flow__agent_spawn { type: "reviewer", name: "Code Reviewer" }

  // Execute tasks with correct agent coordination
  Task("Analyze CI/CD configuration", "Review all workflow files and suggest optimizations", "code-analyzer")
  Task("Design system architecture", "Create high-level architecture diagrams and patterns", "system-architect")
  Task("Manage PR workflow", "Create comprehensive PR strategy and review checklist", "pr-manager")
  Task("Implement features", "Write clean, maintainable code following best practices", "coder")
  Task("Create test suite", "Develop comprehensive unit and integration tests", "tester")
  Task("Review implementation", "Ensure code quality and adherence to standards", "reviewer")
```

## Example 3: GitHub Workflow Analysis

```javascript
// Analyzing a GitHub repository using the correct agents
[BatchTool]:
  // Use code-analyzer instead of analyst
  Task("Analyze GitHub Actions", `
    Review all .github/workflows/*.yml files
    Identify security issues, inefficiencies, and best practices
    Suggest optimizations for build times
  `, "code-analyzer")

  // Use system-architect instead of architect
  Task("Analyze Repository Structure", `
    Review overall codebase architecture
    Identify design patterns and anti-patterns
    Evaluate modularity and maintainability
  `, "system-architect")

  // Use pr-manager instead of coordinator
  Task("Create PR Strategy", `
    Develop comprehensive PR workflow
    Create review checklists and templates
    Define merge requirements and testing strategy
  `, "pr-manager")
```

## Available Alternatives Reference

| What You Want | Wrong Name | Correct Agent | Purpose |
|--------------|------------|---------------|----------|
| CI/CD Analysis | `analyst` | `code-analyzer` | Analyze code quality, CI/CD configs |
| Architecture Review | `architect` | `system-architect` | System design and architecture |
| PR Coordination | `coordinator` | `pr-manager` | Pull request management |
| General Coordination | `coordinator` | `task-orchestrator` | Task workflow coordination |
| SPARC Coordination | `coordinator` | `sparc-coord` | SPARC methodology orchestration |

## Verifying Agent Availability

Before using any agent, you can verify it's available:

```bash
# This will show an error but list all available agents
npx claude-flow@alpha spawn-agent invalid-name

# The error message will show:
# Available agents: general-purpose, code-analyzer, tdd-london-swarm, 
# production-validator, sparc-coder, pr-manager, task-orchestrator...
```

## Best Practices

1. Always use the registered agent names from the available list
2. Check the error message if unsure - it lists all available agents
3. Refer to `/docs/AGENT_NAME_MAPPING.md` for the complete mapping
4. Use `code-analyzer` for any code or CI/CD analysis tasks
5. Use `system-architect` for architecture and design tasks
6. Use `pr-manager` for pull request coordination tasks