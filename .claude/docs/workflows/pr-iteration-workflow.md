# PR Iteration Workflow

## Overview

The PR Iteration Workflow automates the process of developing code iteratively by:
1. Creating or updating a pull request
2. Monitoring CI/CD status
3. Automatically fixing failing tests, linting errors, and other issues
4. Re-running CI until all checks pass
5. Providing detailed reports and metrics

This workflow combines claude-flow's swarm coordination with GitHub's CI/CD to create a self-improving development process.

## Quick Start

### Basic Usage

```bash
# Start a new iterative PR development
cfpr feature/my-feature "Add user authentication"

# Resume iteration on existing PR
cfpr-resume 123
```

### Advanced Usage

```bash
# With custom options
cfpr feature/api "Build REST API" \
  --max-iterations 15 \
  --config .claude/pr-iteration.config.json \
  --webhook https://hooks.example.com/pr-status

# Dry run to see what would happen
npx flow-tools github pr-iterate \
  --branch feature/test \
  --dry-run \
  --verbose
```

## How It Works

### 1. Initialization Phase
- Creates a new PR or identifies existing one
- Sets up swarm coordination with specialized agents
- Loads configuration and quality gates
- Initializes tracking and metrics

### 2. CI Monitoring Loop
- Polls GitHub checks API for CI status
- Identifies failing checks (tests, linting, security, etc.)
- Categorizes failures by type and priority
- Determines fix strategies based on failure types

### 3. Fix Coordination
The workflow spawns specialized agents to handle different failure types:

- **Test Failures**: `tester` and `tdd-london-swarm` agents
- **Lint Errors**: `code-analyzer` agent with auto-formatting
- **Build Errors**: `coder` and `system-architect` agents
- **Type Errors**: `coder` with TypeScript expertise
- **Security Issues**: `security-manager` agent
- **Performance Regressions**: `perf-analyzer` and `performance-benchmarker`

### 4. PR Update & Iteration
- Commits all fixes with detailed messages
- Updates the PR with iteration history
- Applies backoff strategy between iterations
- Continues until all checks pass or max iterations reached

### 5. Reporting & Completion
- Generates comprehensive iteration report
- Tracks metrics and performance data
- Sends webhook notifications
- Optionally auto-merges on success

## Configuration

### Default Configuration Location
`.claude/pr-iteration.config.json`

### Key Configuration Options

```json
{
  "pr-iterate": {
    "defaults": {
      "maxIterations": 10,        // Maximum attempts
      "timeout": 3600000,         // 1 hour total timeout
      "parallel": true,           // Run fixes in parallel
      "autoFix": true            // Automatically implement fixes
    },
    "ci": {
      "requiredChecks": [         // Must pass
        "test-suite",
        "lint",
        "security-scan"
      ],
      "optionalChecks": [         // Nice to have
        "performance",
        "coverage"
      ]
    }
  }
}
```

## Swarm Coordination

### Agent Hierarchy
```
pr-iteration-coordinator (Queen)
├── ci-monitor
├── test-analyzer
├── fix-coordinator
└── code-reviewer

Specialists (spawned as needed):
├── tester
├── code-analyzer
├── security-manager
├── performance-benchmarker
└── system-architect
```

### Memory Coordination
- Agents share failure analysis through memory
- Fix strategies are coordinated across agents
- Iteration history is preserved for learning
- Successful patterns are cached for reuse

## Examples

### Example 1: Simple Feature Development

```bash
# Create feature branch
git checkout -b feature/user-profile

# Make initial changes
# ... edit files ...

# Start iterative PR development
cfpr feature/user-profile "Add user profile page"
```

Output:
```
🔄 Starting iterative PR development...
Branch: feature/user-profile
Description: Add user profile page

📊 Iteration 1/10
  ❌ test-suite: 3 failing tests
  ❌ lint: 2 errors
  ✅ security-scan: Passed

🤖 Coordinating fixes...
  - tester: Fixing ProfileComponent.test.js
  - code-analyzer: Resolving lint errors

✅ PR updated with 5 fixes

📊 Iteration 2/10
  ✅ test-suite: All tests passing
  ✅ lint: Clean
  ✅ security-scan: Passed

🎉 All checks passed after 2 iterations!
```

### Example 2: Complex API Development

```bash
# Use custom configuration for API project
cfpr feature/api-v2 "Implement v2 API endpoints" \
  --config .claude/api-iteration.config.json \
  --max-iterations 20 \
  --webhook $SLACK_WEBHOOK
```

### Example 3: Resuming Failed Iteration

```bash
# Previous iteration timed out or failed
cfpr-resume 456 --max-iterations 5
```

## Best Practices

### 1. Start Small
- Begin with well-defined, focused features
- Ensure good test coverage before starting
- Have clear CI/CD pipeline configured

### 2. Configuration Tips
- Set reasonable iteration limits (5-15)
- Use parallel fixes for faster iterations
- Configure quality gates appropriately
- Enable checkpointing for long runs

### 3. Monitoring
- Watch the iteration progress
- Review fix commits for quality
- Check performance metrics
- Validate security fixes manually

### 4. Error Recovery
- Use checkpoints for long-running iterations
- Resume from failures with `cfpr-resume`
- Review error logs for patterns
- Adjust configuration based on results

## Troubleshooting

### Common Issues

1. **"Max iterations reached"**
   - Increase `--max-iterations`
   - Review failing tests for fundamental issues
   - Check if fixes are actually addressing root causes

2. **"API rate limit exceeded"**
   - Use exponential backoff strategy
   - Reduce polling frequency
   - Use webhook notifications instead

3. **"Merge conflicts"**
   - Workflow automatically attempts rebase
   - May need manual intervention for complex conflicts
   - Keep feature branches up to date

4. **"Tests keep failing"**
   - Check if tests are flaky
   - Ensure test environment matches CI
   - Review test isolation and dependencies

### Debug Mode

```bash
# Verbose output with detailed logs
cfpr feature/debug "Debug feature" --verbose

# Dry run to preview actions
npx flow-tools github pr-iterate \
  --branch feature/test \
  --dry-run
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Iterative Development
on:
  workflow_dispatch:
    inputs:
      max_iterations:
        description: 'Maximum iterations'
        required: false
        default: '10'

jobs:
  iterate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: |
          npm install -g claude-flow@alpha
          npm install -g flow-tools
      
      - name: Run PR Iteration
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
        run: |
          cfpr-resume ${{ github.event.pull_request.number }} \
            --max-iterations ${{ github.event.inputs.max_iterations }}
```

## Metrics and Reporting

### Available Metrics
- Total iterations required
- Time per iteration
- Fix success rate by type
- API calls made
- Token usage (if tracked)
- Performance improvements

### Report Format
```markdown
# PR Iteration Report

**PR #123**: Add user authentication
**Status**: ✅ Success
**Iterations**: 3
**Duration**: 18 minutes

## Iteration Summary
1. Fixed 3 test failures, 2 lint errors
2. Fixed 1 test failure, added type annotations
3. Fixed security vulnerability, all checks passed

## Metrics
- Test Coverage: 85% (+8%)
- Performance Score: 96/100 (+4)
- Bundle Size: 234KB (-15KB)
```

## Advanced Features

### Custom Fix Strategies
Configure specific strategies for different failure types:

```json
{
  "fixes": {
    "testFailures": {
      "strategies": ["isolate", "mock", "refactor"],
      "preferredOrder": ["mock", "isolate", "refactor"]
    }
  }
}
```

### Webhook Integration
Receive real-time updates:

```json
{
  "notifications": {
    "webhook": "https://hooks.slack.com/services/...",
    "events": [
      "iteration-start",
      "fix-applied",
      "all-checks-passed"
    ]
  }
}
```

### Quality Gates
Define minimum quality requirements:

```json
{
  "qualityGates": {
    "testCoverage": 80,
    "performanceScore": 90,
    "securityGrade": "A",
    "bundleSizeLimit": 500000
  }
}
```

## See Also

- [PR Manager Agent](../../agents/github/pr-manager.md)
- [CI/CD Engineer Agent](../../agents/devops/ci-cd/ops-cicd-github.md)
- [SPARC Refinement](../../agents/sparc/refinement.md)
- [Claude Flow Documentation](https://github.com/ruvnet/claude-flow)