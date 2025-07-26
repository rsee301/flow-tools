/**
 * Code Analyzer MCP Tool
 * Provides advanced code analysis capabilities
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import * as fs from 'fs/promises';
import * as path from 'path';

const server = new Server({
  name: 'code-analyzer',
  version: '1.0.0'
}, {
  capabilities: {
    tools: true
  }
});

// Register tools
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'analyze_complexity',
      description: 'Analyze code complexity in a file or directory',
      inputSchema: {
        type: 'object',
        properties: {
          path: {
            type: 'string',
            description: 'File or directory path to analyze'
          },
          metrics: {
            type: 'array',
            items: {
              type: 'string',
              enum: ['cyclomatic', 'cognitive', 'lines', 'dependencies']
            },
            description: 'Metrics to calculate'
          }
        },
        required: ['path']
      }
    },
    {
      name: 'find_patterns',
      description: 'Find code patterns and anti-patterns',
      inputSchema: {
        type: 'object',
        properties: {
          path: {
            type: 'string',
            description: 'Path to analyze'
          },
          patterns: {
            type: 'array',
            items: {
              type: 'string'
            },
            description: 'Patterns to search for'
          }
        },
        required: ['path']
      }
    },
    {
      name: 'dependency_graph',
      description: 'Generate dependency graph for a project',
      inputSchema: {
        type: 'object',
        properties: {
          root: {
            type: 'string',
            description: 'Project root directory'
          },
          format: {
            type: 'string',
            enum: ['json', 'dot', 'mermaid'],
            description: 'Output format'
          }
        },
        required: ['root']
      }
    }
  ]
}));

// Handle tool execution
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;
  
  switch (name) {
    case 'analyze_complexity':
      return await analyzeComplexity(args);
    
    case 'find_patterns':
      return await findPatterns(args);
    
    case 'dependency_graph':
      return await generateDependencyGraph(args);
    
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

async function analyzeComplexity({ path: targetPath, metrics = ['cyclomatic', 'lines'] }) {
  try {
    const stats = await fs.stat(targetPath);
    const results = {};
    
    if (stats.isFile()) {
      const content = await fs.readFile(targetPath, 'utf8');
      results[targetPath] = calculateMetrics(content, metrics);
    } else {
      // Analyze directory recursively
      results.summary = {
        totalFiles: 0,
        averageComplexity: 0,
        totalLines: 0
      };
    }
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(results, null, 2)
        }
      ]
    };
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error analyzing complexity: ${error.message}`
        }
      ]
    };
  }
}

async function findPatterns({ path: targetPath, patterns = [] }) {
  const defaultPatterns = [
    'console.log',
    'TODO',
    'FIXME',
    'any type',
    'eslint-disable'
  ];
  
  const searchPatterns = patterns.length > 0 ? patterns : defaultPatterns;
  const findings = [];
  
  try {
    const content = await fs.readFile(targetPath, 'utf8');
    const lines = content.split('\\n');
    
    lines.forEach((line, index) => {
      searchPatterns.forEach(pattern => {
        if (line.includes(pattern)) {
          findings.push({
            pattern,
            line: index + 1,
            content: line.trim()
          });
        }
      });
    });
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({ path: targetPath, findings }, null, 2)
        }
      ]
    };
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error finding patterns: ${error.message}`
        }
      ]
    };
  }
}

async function generateDependencyGraph({ root, format = 'json' }) {
  try {
    // Simple dependency analysis for JavaScript/TypeScript
    const packageJsonPath = path.join(root, 'package.json');
    const packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf8'));
    
    const dependencies = {
      production: Object.keys(packageJson.dependencies || {}),
      development: Object.keys(packageJson.devDependencies || {}),
      peer: Object.keys(packageJson.peerDependencies || {})
    };
    
    let output;
    if (format === 'mermaid') {
      output = generateMermaidGraph(dependencies);
    } else {
      output = JSON.stringify(dependencies, null, 2);
    }
    
    return {
      content: [
        {
          type: 'text',
          text: output
        }
      ]
    };
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error generating dependency graph: ${error.message}`
        }
      ]
    };
  }
}

function calculateMetrics(content, metrics) {
  const result = {};
  
  if (metrics.includes('lines')) {
    const lines = content.split('\\n');
    result.lines = {
      total: lines.length,
      code: lines.filter(l => l.trim() && !l.trim().startsWith('//')).length,
      comments: lines.filter(l => l.trim().startsWith('//')).length,
      blank: lines.filter(l => !l.trim()).length
    };
  }
  
  if (metrics.includes('cyclomatic')) {
    // Simple cyclomatic complexity estimation
    const complexity = 1 + 
      (content.match(/if\\s*\\(/g) || []).length +
      (content.match(/else\\s+if\\s*\\(/g) || []).length +
      (content.match(/for\\s*\\(/g) || []).length +
      (content.match(/while\\s*\\(/g) || []).length +
      (content.match(/case\\s+/g) || []).length;
    
    result.cyclomaticComplexity = complexity;
  }
  
  return result;
}

function generateMermaidGraph(dependencies) {
  let graph = 'graph TD\\n';
  graph += '    Project[Project]\\n';
  
  Object.entries(dependencies).forEach(([type, deps]) => {
    deps.forEach(dep => {
      graph += `    Project --> ${dep}[${dep}]\\n`;
    });
  });
  
  return graph;
}

// Start the server
const transport = new StdioServerTransport();
server.connect(transport);

console.error('Code Analyzer MCP server started');