/**
 * Preferences Management Module
 * Handles loading and applying user preferences
 */

const fs = require('fs').promises;
const path = require('path');
const yaml = require('js-yaml');
const chalk = require('chalk');

/**
 * Load preferences from config file
 */
async function loadPreferencesConfig() {
  const configPath = path.join(__dirname, '..', 'preferences', 'config.yaml');
  
  try {
    const configContent = await fs.readFile(configPath, 'utf8');
    return yaml.load(configContent);
  } catch (error) {
    console.error(chalk.red('Error loading preferences:'), error.message);
    return getDefaultPreferences();
  }
}

/**
 * Apply preferences to a project
 */
async function loadPreferences(projectPath, options = {}) {
  const config = await loadPreferencesConfig();
  
  console.log(chalk.blue('Loading preferences into project...'));
  
  // Create .claude directory if it doesn't exist
  const claudeDir = path.join(projectPath, '.claude');
  await fs.mkdir(claudeDir, { recursive: true });
  
  // Create settings.json for Claude Code
  const settings = {
    preferences: config.defaults,
    development: config.development,
    mcps: config.mcps.enabled,
    claudeFlow: config.development.claudeFlow
  };
  
  const settingsPath = path.join(claudeDir, 'settings.json');
  
  if (await fileExists(settingsPath) && !options.force) {
    console.log(chalk.yellow('Settings file already exists. Use --force to overwrite.'));
    return;
  }
  
  await fs.writeFile(
    settingsPath,
    JSON.stringify(settings, null, 2)
  );
  
  console.log(chalk.green('✓ Preferences loaded successfully'));
  
  // Create preference-specific configurations
  await createProjectConfigs(projectPath, config);
}

/**
 * Create project-specific configuration files
 */
async function createProjectConfigs(projectPath, config) {
  // ESLint configuration
  if (config.defaults.linting.tool === 'eslint') {
    const eslintConfig = {
      extends: ['eslint:recommended'],
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module'
      },
      env: {
        node: true,
        es2022: true
      },
      rules: {
        'indent': ['error', config.defaults.formatting.tabWidth],
        'quotes': ['error', config.defaults.formatting.singleQuote ? 'single' : 'double'],
        'semi': ['error', config.defaults.formatting.semi ? 'always' : 'never']
      }
    };
    
    await fs.writeFile(
      path.join(projectPath, '.eslintrc.json'),
      JSON.stringify(eslintConfig, null, 2)
    );
  }
  
  // Prettier configuration
  if (config.defaults.formatting.tool === 'prettier') {
    const prettierConfig = {
      tabWidth: config.defaults.formatting.tabWidth,
      singleQuote: config.defaults.formatting.singleQuote,
      semi: config.defaults.formatting.semi,
      trailingComma: 'es5',
      printWidth: 100
    };
    
    await fs.writeFile(
      path.join(projectPath, '.prettierrc'),
      JSON.stringify(prettierConfig, null, 2)
    );
  }
  
  // Jest configuration if using Jest
  if (config.defaults.testing.framework === 'jest') {
    const jestConfig = {
      testEnvironment: 'node',
      collectCoverage: config.defaults.testing.coverage,
      coverageDirectory: 'coverage',
      testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js']
    };
    
    await fs.writeFile(
      path.join(projectPath, 'jest.config.js'),
      `module.exports = ${JSON.stringify(jestConfig, null, 2)};`
    );
  }
}

/**
 * Get default preferences
 */
function getDefaultPreferences() {
  return {
    defaults: {
      language: 'javascript',
      packageManager: 'npm',
      testing: {
        framework: 'jest',
        coverage: true
      },
      linting: {
        tool: 'eslint',
        autoFix: true
      },
      formatting: {
        tool: 'prettier',
        tabWidth: 2,
        singleQuote: true,
        semi: true
      }
    },
    development: {
      autoFormat: true,
      autoTest: false,
      claudeFlow: {
        defaultAgents: 5,
        topology: 'hierarchical'
      }
    }
  };
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
  loadPreferences,
  loadPreferencesConfig,
  createProjectConfigs
};