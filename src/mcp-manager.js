/**
 * MCP Manager Module
 * Handles custom MCP tool management
 */

const fs = require('fs').promises;
const path = require('path');
const chalk = require('chalk');
const inquirer = require('inquirer');

/**
 * Add a custom MCP tool
 */
async function addCustomMCP(name, options) {
  const mcpDir = path.join(__dirname, '..', 'mcps', name);
  
  // Check if MCP already exists
  if (await fileExists(mcpDir)) {
    console.log(chalk.yellow(`MCP '${name}' already exists.`));
    return;
  }
  
  // Get MCP details
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'description',
      message: 'MCP description:',
      default: options.description || `Custom MCP tool: ${name}`
    },
    {
      type: 'list',
      name: 'type',
      message: 'MCP type:',
      choices: ['tool', 'resource', 'prompt', 'hybrid'],
      default: options.type || 'tool'
    },
    {
      type: 'input',
      name: 'version',
      message: 'Version:',
      default: '1.0.0'
    },
    {
      type: 'checkbox',
      name: 'capabilities',
      message: 'Select capabilities:',
      choices: [
        'file-operations',
        'code-analysis',
        'project-management',
        'testing',
        'deployment',
        'monitoring',
        'documentation'
      ]
    }
  ]);
  
  // Create MCP directory
  await fs.mkdir(mcpDir, { recursive: true });
  
  // Create package.json for MCP
  const packageJson = {
    name: `@flow-tools/mcp-${name}`,
    version: answers.version,
    description: answers.description,
    main: 'index.js',
    type: 'module',
    mcp: {
      type: answers.type,
      capabilities: answers.capabilities
    }
  };
  
  await fs.writeFile(
    path.join(mcpDir, 'package.json'),
    JSON.stringify(packageJson, null, 2)
  );
  
  // Create basic MCP implementation
  const mcpImplementation = generateMCPImplementation(name, answers);
  await fs.writeFile(
    path.join(mcpDir, 'index.js'),
    mcpImplementation
  );
  
  // Create README
  const readme = generateMCPReadme(name, answers);
  await fs.writeFile(
    path.join(mcpDir, 'README.md'),
    readme
  );
  
  // Update preferences to include new MCP
  await updatePreferencesWithMCP(name);
  
  console.log(chalk.green(`\n✓ Custom MCP '${name}' created successfully!`));
  console.log(chalk.gray(`Location: ${mcpDir}`));
}

/**
 * Generate MCP implementation template
 */
function generateMCPImplementation(name, config) {
  return `/**
 * ${config.description}
 * MCP Type: ${config.type}
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

// Create MCP server
const server = new Server({
  name: '${name}',
  version: '${config.version}'
}, {
  capabilities: {
    tools: ${config.type === 'tool' || config.type === 'hybrid' ? 'true' : 'false'},
    resources: ${config.type === 'resource' || config.type === 'hybrid' ? 'true' : 'false'},
    prompts: ${config.type === 'prompt' || config.type === 'hybrid' ? 'true' : 'false'}
  }
});

${config.type === 'tool' || config.type === 'hybrid' ? generateToolHandlers(name) : ''}
${config.type === 'resource' || config.type === 'hybrid' ? generateResourceHandlers(name) : ''}
${config.type === 'prompt' || config.type === 'hybrid' ? generatePromptHandlers(name) : ''}

// Start the server
const transport = new StdioServerTransport();
server.connect(transport);

console.error('${name} MCP server started');
`;
}

/**
 * Generate tool handlers
 */
function generateToolHandlers(name) {
  return `
// Register tools
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: '${name}_example',
      description: 'Example tool for ${name}',
      inputSchema: {
        type: 'object',
        properties: {
          input: {
            type: 'string',
            description: 'Input parameter'
          }
        },
        required: ['input']
      }
    }
  ]
}));

// Handle tool execution
server.setRequestHandler('tools/call', async (request) => {
  const { name: toolName, arguments: args } = request.params;
  
  if (toolName === '${name}_example') {
    // Implement your tool logic here
    return {
      content: [
        {
          type: 'text',
          text: \`Processed: \${args.input}\`
        }
      ]
    };
  }
  
  throw new Error(\`Unknown tool: \${toolName}\`);
});`;
}

/**
 * Generate resource handlers
 */
function generateResourceHandlers(name) {
  return `
// Register resources
server.setRequestHandler('resources/list', async () => ({
  resources: [
    {
      uri: '${name}://example',
      name: 'Example Resource',
      description: 'Example resource for ${name}',
      mimeType: 'text/plain'
    }
  ]
}));

// Handle resource reading
server.setRequestHandler('resources/read', async (request) => {
  const { uri } = request.params;
  
  if (uri === '${name}://example') {
    return {
      contents: [
        {
          uri,
          mimeType: 'text/plain',
          text: 'Example resource content'
        }
      ]
    };
  }
  
  throw new Error(\`Unknown resource: \${uri}\`);
});`;
}

/**
 * Generate prompt handlers
 */
function generatePromptHandlers(name) {
  return `
// Register prompts
server.setRequestHandler('prompts/list', async () => ({
  prompts: [
    {
      name: '${name}_prompt',
      description: 'Example prompt for ${name}',
      arguments: [
        {
          name: 'topic',
          description: 'Topic for the prompt',
          required: true
        }
      ]
    }
  ]
}));

// Handle prompt generation
server.setRequestHandler('prompts/get', async (request) => {
  const { name: promptName, arguments: args } = request.params;
  
  if (promptName === '${name}_prompt') {
    return {
      description: \`Generate content about \${args.topic}\`,
      messages: [
        {
          role: 'user',
          content: {
            type: 'text',
            text: \`Please provide information about \${args.topic}\`
          }
        }
      ]
    };
  }
  
  throw new Error(\`Unknown prompt: \${promptName}\`);
});`;
}

/**
 * Generate MCP README
 */
function generateMCPReadme(name, config) {
  return `# ${name} MCP

${config.description}

## Type
${config.type}

## Version
${config.version}

## Capabilities
${config.capabilities.map(cap => `- ${cap}`).join('\n')}

## Usage

### Installation
\`\`\`bash
# In your flow-tools project
npx flow-tools add-mcp ${name}
\`\`\`

### Configuration
Add to your Claude desktop configuration:

\`\`\`json
{
  "mcpServers": {
    "${name}": {
      "command": "node",
      "args": ["path/to/flow-tools/mcps/${name}/index.js"]
    }
  }
}
\`\`\`

## Development

To modify this MCP, edit the files in this directory and restart your MCP server.
`;
}

/**
 * Update preferences to include new MCP
 */
async function updatePreferencesWithMCP(mcpName) {
  const configPath = path.join(__dirname, '..', 'preferences', 'config.yaml');
  const yaml = require('js-yaml');
  
  try {
    const content = await fs.readFile(configPath, 'utf8');
    const config = yaml.load(content);
    
    // Add to enabled MCPs if not already there
    if (!config.mcps.enabled.includes(mcpName)) {
      config.mcps.enabled.push(mcpName);
      
      // Write back
      await fs.writeFile(
        configPath,
        yaml.dump(config, { indent: 2 })
      );
    }
  } catch (error) {
    console.error(chalk.red('Error updating preferences:'), error.message);
  }
}

/**
 * Check if file exists
 */
async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

module.exports = {
  addCustomMCP
};