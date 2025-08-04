# PR Iterate Command

## Overview
The `pr-iterate` command enables automated iterative PR development with CI monitoring. It creates or updates pull requests and automatically fixes failing tests, linting errors, and other CI issues until all checks pass.

## Command Structure

```bash
npx claude-flow github pr-iterate [options]
```

## Options

### Core Options
- `--branch, -b <branch>`: Source branch for PR (required for new PR)
- `--target, -t <branch>`: Target branch (default: main)
- `--pr-number, -p <number>`: Existing PR number to iterate on
- `--max-iterations, -m <number>`: Maximum iteration attempts (default: 10)
- `--timeout <ms>`: Total timeout in milliseconds (default: 3600000)

### Behavior Options
- `--auto-fix`: Automatically implement fixes for failures
- `--monitor-ci`: Continuously monitor CI status
- `--parallel`: Run fixes in parallel where possible
- `--resume`: Resume iteration from last checkpoint
- `--dry-run`: Preview actions without making changes

### Configuration Options
- `--config, -c <file>`: Load configuration from JSON file
- `--quality-gates <json>`: Quality gate requirements
- `--backoff <strategy>`: Backoff strategy (exponential|linear|fixed)
- `--webhook <url>`: Webhook for status notifications

### Output Options
- `--verbose, -v`: Verbose output with detailed logs
- `--json`: Output results in JSON format
- `--report`: Generate detailed iteration report
- `--metrics`: Include performance metrics

## Usage Examples

### Basic Iterative PR
```bash
# Create new PR and iterate until tests pass
npx claude-flow github pr-iterate \
  --branch feature/new-feature \
  --target main \
  --auto-fix \
  --monitor-ci
```

### Resume Existing PR Iteration
```bash
# Continue iterating on PR #123
npx claude-flow github pr-iterate \
  --pr-number 123 \
  --resume \
  --max-iterations 5
```

### Advanced Configuration
```bash
# Custom quality gates and parallel fixes
npx claude-flow github pr-iterate \
  --branch feature/complex \
  --quality-gates '{"coverage": 85, "performance": 5}' \
  --parallel \
  --backoff exponential \
  --webhook https://example.com/pr-status
```

### With Configuration File
```bash
# Use predefined configuration
npx claude-flow github pr-iterate \
  --config .claude/pr-iteration.json \
  --verbose
```

## Configuration File Format

```json
{
  "pr-iterate": {
    "defaults": {
      "maxIterations": 10,
      "timeout": 3600000,
      "parallel": true,
      "autoFix": true
    },
    "ci": {
      "pollInterval": 30000,
      "requiredChecks": [
        "test-suite",
        "lint",
        "security-scan"
      ],
      "optionalChecks": [
        "performance",
        "coverage"
      ]
    },
    "fixes": {
      "testFailures": {
        "enabled": true,
        "maxAttempts": 3,
        "agents": ["tester", "tdd-london-swarm"]
      },
      "lintErrors": {
        "enabled": true,
        "maxAttempts": 2,
        "agents": ["code-analyzer"]
      },
      "buildErrors": {
        "enabled": true,
        "maxAttempts": 2,
        "agents": ["coder", "system-architect"]
      },
      "securityIssues": {
        "enabled": true,
        "maxAttempts": 1,
        "agents": ["security-manager"]
      }
    },
    "qualityGates": {
      "testCoverage": 80,
      "performanceRegression": 5,
      "bundleSize": 1048576,
      "securityScore": "A"
    },
    "backoff": {
      "strategy": "exponential",
      "initialDelay": 2000,
      "maxDelay": 300000,
      "multiplier": 2
    },
    "notifications": {
      "webhook": null,
      "events": [
        "iteration-start",
        "fix-applied",
        "iteration-complete",
        "all-checks-passed"
      ]
    }
  }
}
```

## Workflow Stages

### 1. Initialization
- Create or identify PR
- Set up iteration tracking
- Initialize swarm coordination
- Load configuration

### 2. CI Monitoring
- Poll CI status
- Identify failing checks
- Categorize failures
- Priority sorting

### 3. Fix Coordination
- Spawn specialized agents
- Implement fixes in parallel
- Validate changes
- Update PR

### 4. Iteration Loop
- Monitor CI after updates
- Apply backoff strategy
- Track progress
- Repeat until success

### 5. Completion
- Generate final report
- Clean up resources
- Notify stakeholders
- Optional auto-merge

## Agent Coordination

### Swarm Topology
```javascript
// Hierarchical swarm for complex iterations
{
  topology: "hierarchical",
  queen: "pr-iteration-coordinator",
  workers: [
    "ci-monitor",
    "test-analyzer",
    "fix-coordinator",
    "code-reviewer"
  ],
  specialists: [
    "tester",
    "code-analyzer",
    "security-manager",
    "performance-benchmarker"
  ]
}
```

### Fix Priority Matrix
```javascript
const fixPriority = {
  "security_critical": 1,
  "build_error": 2,
  "test_failure": 3,
  "lint_error": 4,
  "performance_regression": 5,
  "documentation": 6
};
```

## Error Handling

### Common Errors
1. **API Rate Limits**: Automatic backoff and retry
2. **Merge Conflicts**: Automatic rebase attempt
3. **Timeout**: Checkpoint save and resume capability
4. **Fix Failures**: Fallback to alternative strategies

### Recovery Strategies
```bash
# Resume from checkpoint after failure
npx claude-flow github pr-iterate \
  --pr-number 123 \
  --resume \
  --checkpoint .claude/checkpoints/pr-123.json

# Force specific fix strategy
npx claude-flow github pr-iterate \
  --pr-number 123 \
  --fix-strategy conservative \
  --no-parallel
```

## Output Examples

### Progress Output
```
🔄 PR Iteration Progress [PR #123]
├── Iteration: 3/10
├── Status: Fixing test failures
├── Elapsed: 12m 34s
└── Checks: 2/5 passing

📊 Current Failures:
├── ❌ test-suite: 3 failing tests
├── ❌ lint: 2 errors in src/index.js
└── ✅ security-scan: Passed

🤖 Active Agents:
├── tester: Fixing UserAuth.test.js
├── code-analyzer: Resolving lint errors
└── ci-monitor: Watching pipeline
```

### Final Report
```markdown
# PR Iteration Report

**Pull Request**: #123 - Add user authentication
**Final Status**: ✅ All checks passed
**Total Iterations**: 4
**Total Time**: 28 minutes

## Iteration Summary

| Iteration | Duration | Fixes Applied | Status |
|-----------|----------|---------------|--------|
| 1 | 5m 12s | Lint (2) | ⚠️ Partial |
| 2 | 8m 45s | Tests (3) | ⚠️ Partial |
| 3 | 9m 23s | Tests (1), Perf (1) | ⚠️ Partial |
| 4 | 4m 30s | Security (1) | ✅ Success |

## Fixes Applied

### Test Fixes (4)
- Fixed authentication flow in UserAuth.test.js
- Updated mock data for integration tests
- Resolved async timing issue in API tests
- Added missing test coverage for edge cases

### Code Quality (3)
- Fixed ESLint errors in src/index.js
- Resolved TypeScript type mismatches
- Applied Prettier formatting

### Performance (1)
- Optimized database queries reducing load by 35%

### Security (1)
- Updated dependencies to patch CVE-2024-XXXX

## Quality Metrics

- Test Coverage: 82% (+7%)
- Performance Score: 94/100 (+3)
- Bundle Size: 245KB (-12KB)
- Security Score: A (High)

## Recommendations

1. Consider adding more edge case tests
2. Implement caching for frequently accessed data
3. Review error handling in authentication flow
```

## Integration with CI/CD

### GitHub Actions Integration
```yaml
name: Iterative PR Development

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  iterate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Claude Flow
        run: npm install -g claude-flow@alpha
      
      - name: Run PR Iteration
        run: |
          npx claude-flow github pr-iterate \
            --pr-number ${{ github.event.pull_request.number }} \
            --max-iterations 5 \
            --auto-fix \
            --monitor-ci
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
```

### Webhook Integration
```javascript
// Webhook payload example
{
  "event": "iteration-complete",
  "pr": {
    "number": 123,
    "title": "Add user authentication",
    "branch": "feature/auth"
  },
  "iteration": {
    "number": 3,
    "duration": 523000,
    "fixes": ["test", "lint"],
    "status": "in_progress"
  },
  "ci": {
    "passing": ["security-scan", "coverage"],
    "failing": ["test-suite"],
    "pending": []
  },
  "metrics": {
    "coverage": 82,
    "performance": 94,
    "bundleSize": 251904
  }
}
```

## Best Practices

### Do's
- ✅ Set reasonable iteration limits
- ✅ Use configuration files for consistency
- ✅ Monitor webhook notifications
- ✅ Review iteration reports
- ✅ Use checkpoints for long-running iterations

### Don'ts
- ❌ Don't set max iterations too high (>15)
- ❌ Don't disable all quality gates
- ❌ Don't ignore security failures
- ❌ Don't skip final validation
- ❌ Don't auto-merge without review

## Performance Considerations

### Resource Usage
- **Memory**: ~500MB per iteration
- **CPU**: Varies by fix complexity
- **API Calls**: ~20-50 per iteration
- **Time**: 5-15 minutes per iteration

### Optimization Tips
1. Use parallel fixes for independent failures
2. Cache dependencies between iterations
3. Implement smart test selection
4. Use incremental builds
5. Leverage previous fix patterns

## Troubleshooting

### Common Issues

1. **Iteration Stuck**
   ```bash
   # Force next iteration
   npx claude-flow github pr-iterate --pr-number 123 --force-next
   ```

2. **Memory Issues**
   ```bash
   # Clear iteration cache
   npx claude-flow github pr-iterate --pr-number 123 --clear-cache
   ```

3. **API Rate Limits**
   ```bash
   # Use conservative mode
   npx claude-flow github pr-iterate --pr-number 123 --rate-limit-safe
   ```

## Related Commands

- `github pr-enhance`: One-time PR improvements
- `github pr-review`: Automated code review
- `swarm monitor`: Real-time swarm monitoring
- `task status`: Check task progress

## See Also

- [PR Manager Agent](../../agents/github/pr-manager.md)
- [CI/CD Engineer Agent](../../agents/devops/ci-cd/ops-cicd-github.md)
- [Workflow Automation](../../agents/github/workflow-automation.md)
- [SPARC Refinement](../../agents/sparc/refinement.md)