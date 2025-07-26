/**
 * Project Initializer Module
 * Handles project initialization with flow-tools
 */

const fs = require('fs').promises;
const path = require('path');
const chalk = require('chalk');
const inquirer = require('inquirer');
const { loadPreferences } = require('./preferences');
const { loadTemplate } = require('./templates');

/**
 * Initialize a new project with flow-tools
 */
async function initializeProject(options) {
  console.log(chalk.blue('Initializing flow-tools in current project...\n'));
  
  // Check if already initialized
  const claudeDir = path.join(process.cwd(), '.claude');
  const helperFile = path.join(claudeDir, 'helper.json');
  
  if (await fileExists(helperFile)) {
    const { overwrite } = await inquirer.prompt([{
      type: 'confirm',
      name: 'overwrite',
      message: 'Project already initialized. Overwrite?',
      default: false
    }]);
    
    if (!overwrite) {
      console.log(chalk.yellow('Initialization cancelled.'));
      return;
    }
  }
  
  // Create .claude directory
  await fs.mkdir(claudeDir, { recursive: true });
  
  // Get project information
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'projectName',
      message: 'Project name:',
      default: path.basename(process.cwd())
    },
    {
      type: 'list',
      name: 'projectType',
      message: 'Project type:',
      choices: [
        'fullstack',
        'api-only',
        'frontend-only',
        'microservice',
        'library',
        'custom'
      ],
      default: 'fullstack'
    },
    {
      type: 'checkbox',
      name: 'features',
      message: 'Select features to include:',
      choices: [
        { name: 'TypeScript', value: 'typescript' },
        { name: 'Testing (Jest)', value: 'testing' },
        { name: 'Linting (ESLint)', value: 'linting' },
        { name: 'Formatting (Prettier)', value: 'formatting' },
        { name: 'Git hooks', value: 'githooks' },
        { name: 'Docker', value: 'docker' },
        { name: 'CI/CD', value: 'cicd' }
      ]
    }
  ]);
  
  // Create helper configuration
  const helperConfig = {
    version: '1.0.0',
    projectName: answers.projectName,
    projectType: answers.projectType,
    features: answers.features,
    initialized: new Date().toISOString(),
    claudeFlowVersion: 'latest'
  };
  
  await fs.writeFile(
    helperFile,
    JSON.stringify(helperConfig, null, 2)
  );
  
  // Load template if requested
  if (options.template && options.template !== 'minimal') {
    console.log(chalk.blue(`\nLoading template: ${options.template}`));
    await loadTemplate(options.template, process.cwd());
  }
  
  // Load preferences if requested
  if (options.preferences) {
    console.log(chalk.blue('\nLoading user preferences...'));
    await loadPreferences(process.cwd());
  }
  
  // Create initial structure based on project type
  await createProjectStructure(answers.projectType, answers.features);
  
  // Create claude-flow configuration
  await createClaudeFlowConfig(answers);
  
  console.log(chalk.green('\n✓ Project initialized successfully!'));
  console.log(chalk.gray('\nNext steps:'));
  console.log(chalk.gray('  1. Run: npx claude-flow init'));
  console.log(chalk.gray('  2. Start developing with your personalized setup'));
}

/**
 * Create project structure based on type
 */
async function createProjectStructure(projectType, features) {
  const baseStructure = {
    'fullstack': ['src/frontend', 'src/backend', 'src/shared', 'tests'],
    'api-only': ['src/routes', 'src/controllers', 'src/models', 'src/middleware', 'tests'],
    'frontend-only': ['src/components', 'src/pages', 'src/styles', 'src/utils', 'tests'],
    'microservice': ['src/services', 'src/handlers', 'src/utils', 'tests'],
    'library': ['src', 'tests', 'examples', 'docs']
  };
  
  const structure = baseStructure[projectType] || ['src', 'tests'];
  
  for (const dir of structure) {
    await fs.mkdir(path.join(process.cwd(), dir), { recursive: true });
  }
  
  // Create feature-specific directories
  if (features.includes('docker')) {
    await fs.mkdir(path.join(process.cwd(), 'docker'), { recursive: true });
  }
  
  if (features.includes('cicd')) {
    await fs.mkdir(path.join(process.cwd(), '.github/workflows'), { recursive: true });
  }
}

/**
 * Create claude-flow configuration
 */
async function createClaudeFlowConfig(answers) {
  const config = {
    project: {
      name: answers.projectName,
      type: answers.projectType,
      features: answers.features
    },
    swarm: {
      defaultTopology: 'hierarchical',
      defaultAgents: 5,
      preferredAgentTypes: getPreferredAgents(answers.projectType)
    },
    workflow: {
      autoTest: answers.features.includes('testing'),
      autoFormat: answers.features.includes('formatting'),
      autoLint: answers.features.includes('linting')
    }
  };
  
  await fs.writeFile(
    path.join(process.cwd(), '.claude', 'flow-config.json'),
    JSON.stringify(config, null, 2)
  );
}

/**
 * Get preferred agent types based on project type
 */
function getPreferredAgents(projectType) {
  const agentMap = {
    'fullstack': ['architect', 'backend-dev', 'frontend-dev', 'tester', 'coordinator'],
    'api-only': ['architect', 'backend-dev', 'api-designer', 'tester', 'documenter'],
    'frontend-only': ['ui-designer', 'frontend-dev', 'ux-analyst', 'tester', 'coordinator'],
    'microservice': ['architect', 'backend-dev', 'integration-specialist', 'tester', 'devops'],
    'library': ['architect', 'coder', 'documenter', 'tester', 'reviewer']
  };
  
  return agentMap[projectType] || ['coordinator', 'coder', 'tester'];
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
  initializeProject
};