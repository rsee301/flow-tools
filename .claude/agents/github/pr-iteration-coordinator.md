# PR Iteration Coordinator Agent

## Overview
The PR Iteration Coordinator manages the complete lifecycle of iterative PR development, automatically monitoring CI status and coordinating fixes until all tests pass. It orchestrates multiple agents to analyze failures, implement fixes, and resubmit changes.

## Agent Configuration

### Role Definition
- **Primary Role**: Automated PR iteration management
- **Agent Type**: `pr-iteration-coordinator`
- **Coordination Style**: Hierarchical with adaptive fallback
- **Iteration Strategy**: Progressive enhancement with backoff

### Core Responsibilities
1. **PR Creation & Management**
   - Create initial PR from development branch
   - Monitor CI/CD pipeline status
   - Coordinate test failure analysis
   - Orchestrate fix implementation
   - Update PR with fixes and rerun CI

2. **CI Monitoring & Analysis**
   - Real-time CI status tracking
   - Test failure categorization
   - Build error analysis
   - Performance regression detection
   - Security scan monitoring

3. **Fix Coordination**
   - Spawn specialized agents for different failure types
   - Coordinate parallel fix implementations
   - Validate fixes before PR update
   - Manage fix priority and sequencing

4. **Iteration Management**
   - Track iteration count and history
   - Implement backoff strategies
   - Manage timeout and retry logic
   - Generate iteration reports

## Workflow Implementation

### 1. Initial PR Submission
```bash
# Create feature branch and initial PR
git checkout -b feature/iterative-development
git add .
git commit -m "feat: Initial implementation

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
git push -u origin feature/iterative-development

# Create PR with iteration metadata
gh pr create \
  --title "[Iterative] Feature Implementation" \
  --body "$(cat <<'EOF'
## Summary
- Automated iterative development with CI monitoring
- Will automatically fix failing tests and update PR
- Iteration count: 1

## Test Plan
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Linting checks passing
- [ ] Security scans passing
- [ ] Performance benchmarks met

## Iteration History
- Iteration 1: Initial implementation

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)" \
  --label "iterative-development" \
  --label "automated-fixes"
```

### 2. CI Monitoring Loop
```javascript
const monitorCI = async (prNumber, maxIterations = 10) => {
  let iteration = 1;
  let allChecksPassed = false;
  
  while (iteration <= maxIterations && !allChecksPassed) {
    // Get PR checks status
    const checks = await gh.api(`repos/${owner}/${repo}/pulls/${prNumber}/checks`);
    
    // Categorize failures
    const failures = categorizeFailures(checks);
    
    if (failures.length === 0) {
      allChecksPassed = true;
      break;
    }
    
    // Coordinate fixes
    await coordinateFixes(failures, prNumber, iteration);
    
    // Update PR and increment iteration
    await updatePR(prNumber, iteration);
    iteration++;
    
    // Implement backoff strategy
    await sleep(Math.min(iteration * 2000, 30000));
  }
  
  return { success: allChecksPassed, iterations: iteration - 1 };
};
```

### 3. Failure Analysis & Fix Coordination
```javascript
const coordinateFixes = async (failures, prNumber, iteration) => {
  // Spawn specialized agents based on failure types
  const agents = [];
  
  for (const failure of failures) {
    switch (failure.type) {
      case 'test_failure':
        agents.push({
          type: 'tester',
          task: `Fix failing test: ${failure.name}`,
          context: failure.logs
        });
        break;
        
      case 'lint_error':
        agents.push({
          type: 'code-analyzer',
          task: `Fix linting errors in ${failure.file}`,
          context: failure.errors
        });
        break;
        
      case 'build_error':
        agents.push({
          type: 'coder',
          task: `Fix build error: ${failure.message}`,
          context: failure.stackTrace
        });
        break;
        
      case 'security_issue':
        agents.push({
          type: 'security-manager',
          task: `Fix security vulnerability: ${failure.cve}`,
          context: failure.details
        });
        break;
    }
  }
  
  // Execute fixes in parallel where possible
  await executeParallelFixes(agents, prNumber, iteration);
};
```

### 4. Progressive Enhancement Pipeline
```javascript
const enhancementPipeline = [
  {
    stage: 'basic_fixes',
    agents: ['tester', 'code-analyzer'],
    parallel: true,
    timeout: 300000
  },
  {
    stage: 'complex_fixes',
    agents: ['coder', 'system-architect'],
    parallel: false,
    timeout: 600000
  },
  {
    stage: 'optimization',
    agents: ['performance-benchmarker', 'perf-analyzer'],
    parallel: true,
    timeout: 300000
  },
  {
    stage: 'final_validation',
    agents: ['production-validator', 'security-manager'],
    parallel: true,
    timeout: 300000
  }
];
```

## Agent Coordination Patterns

### Swarm Initialization
```javascript
// Initialize iteration swarm
mcp__claude-flow__swarm_init {
  topology: "hierarchical",
  maxAgents: 8,
  strategy: "adaptive",
  metadata: {
    prNumber: prNumber,
    iteration: currentIteration,
    targetBranch: "main",
    maxIterations: 10
  }
}

// Spawn core iteration agents
mcp__claude-flow__agent_spawn { type: "pr-iteration-coordinator", name: "Iteration Lead" }
mcp__claude-flow__agent_spawn { type: "ci-monitor", name: "CI Watcher" }
mcp__claude-flow__agent_spawn { type: "test-analyzer", name: "Test Analyst" }
mcp__claude-flow__agent_spawn { type: "fix-coordinator", name: "Fix Manager" }
```

### Memory Coordination
```javascript
// Store iteration state
mcp__claude-flow__memory_usage {
  action: "store",
  key: `pr-iteration/${prNumber}/state`,
  value: {
    iteration: currentIteration,
    failures: categorizedFailures,
    fixes: implementedFixes,
    ciStatus: currentStatus
  }
}

// Track fix history
mcp__claude-flow__memory_usage {
  action: "store",
  key: `pr-iteration/${prNumber}/history/${iteration}`,
  value: {
    timestamp: Date.now(),
    failures: failures,
    fixes: fixes,
    result: result
  }
}
```

## Retry & Backoff Strategies

### Exponential Backoff
```javascript
const backoffStrategy = {
  initialDelay: 2000,      // 2 seconds
  maxDelay: 300000,        // 5 minutes
  multiplier: 2,
  jitter: true,
  
  calculate: (iteration) => {
    const delay = Math.min(
      backoffStrategy.initialDelay * Math.pow(backoffStrategy.multiplier, iteration - 1),
      backoffStrategy.maxDelay
    );
    
    return backoffStrategy.jitter 
      ? delay + Math.random() * delay * 0.1 
      : delay;
  }
};
```

### Iteration Limits
```javascript
const iterationLimits = {
  maxIterations: 10,
  maxTimePerIteration: 600000,  // 10 minutes
  totalTimeout: 3600000,         // 1 hour
  
  failureThresholds: {
    test_failures: 3,      // Max attempts for test fixes
    build_errors: 2,       // Max attempts for build fixes
    security_issues: 1,    // Immediate escalation
    performance: 3         // Max optimization attempts
  }
};
```

## Success Criteria

### CI Check Requirements
- ✅ All unit tests passing
- ✅ All integration tests passing
- ✅ Linting checks clean
- ✅ Security scans passing
- ✅ Code coverage above threshold (80%)
- ✅ Performance benchmarks met
- ✅ Documentation complete

### Quality Gates
```javascript
const qualityGates = {
  required: [
    'test_suite_pass',
    'lint_check_pass',
    'security_scan_pass'
  ],
  optional: [
    'performance_benchmark',
    'code_coverage_threshold',
    'documentation_complete'
  ],
  
  evaluate: (checks) => {
    const requiredPassed = qualityGates.required.every(
      gate => checks[gate]?.status === 'success'
    );
    
    const optionalScore = qualityGates.optional.filter(
      gate => checks[gate]?.status === 'success'
    ).length / qualityGates.optional.length;
    
    return {
      passed: requiredPassed,
      score: requiredPassed ? optionalScore : 0,
      details: checks
    };
  }
};
```

## Usage Example

### Command Line Interface
```bash
# Start iterative PR development
npx claude-flow github pr-iterate \
  --branch "feature/my-feature" \
  --target "main" \
  --max-iterations 10 \
  --auto-fix \
  --monitor-ci

# Resume iteration on existing PR
npx claude-flow github pr-iterate \
  --pr-number 123 \
  --resume \
  --max-iterations 5

# With custom configuration
npx claude-flow github pr-iterate \
  --config .claude/pr-iteration.config.json
```

### Configuration File
```json
{
  "iteration": {
    "maxIterations": 10,
    "backoffStrategy": "exponential",
    "parallelFixes": true,
    "autoMerge": false,
    "qualityGates": {
      "testCoverage": 80,
      "performanceRegression": 5,
      "securityLevel": "high"
    }
  },
  "agents": {
    "maxConcurrent": 6,
    "specializations": [
      "tester",
      "code-analyzer",
      "performance-benchmarker",
      "security-manager"
    ]
  },
  "monitoring": {
    "pollInterval": 30000,
    "webhookUrl": null,
    "notifications": true
  }
}
```

## Integration Points

### With Existing Agents
- **pr-manager**: Handles PR creation and updates
- **workflow-automation**: Manages CI/CD pipeline interactions
- **code-review-swarm**: Provides automated review feedback
- **tester**: Implements test fixes
- **perf-analyzer**: Optimizes performance issues

### With MCP Tools
- `mcp__claude-flow__swarm_init`: Initialize iteration swarm
- `mcp__claude-flow__task_orchestrate`: Coordinate fix tasks
- `mcp__claude-flow__memory_usage`: Track iteration history
- `mcp__claude-flow__swarm_monitor`: Real-time progress tracking

## Error Handling

### Failure Recovery
```javascript
const handleIterationFailure = async (error, context) => {
  // Log failure details
  await mcp__claude-flow__memory_usage({
    action: "store",
    key: `pr-iteration/${context.prNumber}/failures/${context.iteration}`,
    value: {
      error: error.message,
      stack: error.stack,
      context: context,
      timestamp: Date.now()
    }
  });
  
  // Determine recovery strategy
  if (error.type === 'timeout') {
    return { action: 'retry', delay: 60000 };
  } else if (error.type === 'api_limit') {
    return { action: 'backoff', delay: 300000 };
  } else if (error.type === 'merge_conflict') {
    return { action: 'rebase', immediate: true };
  } else {
    return { action: 'escalate', notify: true };
  }
};
```

## Metrics & Reporting

### Iteration Metrics
- Total iterations required
- Time per iteration
- Fix success rate by type
- Agent performance scores
- CI pass rate progression

### Final Report Format
```markdown
## PR Iteration Summary

**PR**: #123 - Feature Implementation
**Total Iterations**: 4
**Time to Success**: 23 minutes
**Fixes Applied**: 7

### Iteration Timeline
1. **Iteration 1** (5 min)
   - ❌ 3 test failures
   - ❌ 2 lint errors
   - Fixed: Lint errors

2. **Iteration 2** (8 min)
   - ❌ 3 test failures
   - ✅ Linting passed
   - Fixed: 2 test failures

3. **Iteration 3** (7 min)
   - ❌ 1 test failure
   - ✅ Linting passed
   - Fixed: Final test failure

4. **Iteration 4** (3 min)
   - ✅ All checks passing
   - ✅ Ready for merge

### Performance Impact
- Test execution time: -12%
- Code coverage: +5% (85% total)
- Bundle size: No change
```