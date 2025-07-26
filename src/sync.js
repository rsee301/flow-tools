/**
 * Sync Module
 * Handles synchronization of preferences between projects and helper
 */

const fs = require('fs').promises;
const path = require('path');
const chalk = require('chalk');
const yaml = require('js-yaml');

/**
 * Sync preferences from current project back to helper
 */
async function syncPreferences(projectPath) {
  console.log(chalk.blue('Syncing project preferences...'));
  
  const claudeSettingsPath = path.join(projectPath, '.claude', 'settings.json');
  const helperConfigPath = path.join(__dirname, '..', 'preferences', 'config.yaml');
  
  try {
    // Read current project settings
    const settingsContent = await fs.readFile(claudeSettingsPath, 'utf8');
    const projectSettings = JSON.parse(settingsContent);
    
    // Read helper config
    const configContent = await fs.readFile(helperConfigPath, 'utf8');
    const helperConfig = yaml.load(configContent);
    
    // Merge preferences
    if (projectSettings.preferences) {
      Object.assign(helperConfig.defaults, projectSettings.preferences);
    }
    
    if (projectSettings.development) {
      Object.assign(helperConfig.development, projectSettings.development);
    }
    
    if (projectSettings.mcps) {
      // Add any new MCPs to the enabled list
      projectSettings.mcps.forEach(mcp => {
        if (!helperConfig.mcps.enabled.includes(mcp)) {
          helperConfig.mcps.enabled.push(mcp);
        }
      });
    }
    
    // Save updated config
    await fs.writeFile(
      helperConfigPath,
      yaml.dump(helperConfig, { indent: 2 })
    );
    
    console.log(chalk.green('✓ Preferences synced successfully'));
    
    // Show what was synced
    console.log(chalk.gray('\nSynced configurations:'));
    console.log(chalk.gray(`  - Language: ${helperConfig.defaults.language}`));
    console.log(chalk.gray(`  - Testing: ${helperConfig.defaults.testing.framework}`));
    console.log(chalk.gray(`  - Linting: ${helperConfig.defaults.linting.tool}`));
    console.log(chalk.gray(`  - MCPs: ${helperConfig.mcps.enabled.length} enabled`));
    
  } catch (error) {
    console.error(chalk.red('Error syncing preferences:'), error.message);
    console.log(chalk.yellow('Make sure you have a .claude/settings.json file in your project.'));
  }
}

/**
 * Export current preferences to a file
 */
async function exportPreferences(outputPath) {
  const configPath = path.join(__dirname, '..', 'preferences', 'config.yaml');
  
  try {
    const configContent = await fs.readFile(configPath, 'utf8');
    const config = yaml.load(configContent);
    
    await fs.writeFile(
      outputPath,
      JSON.stringify(config, null, 2)
    );
    
    console.log(chalk.green(`✓ Preferences exported to: ${outputPath}`));
  } catch (error) {
    console.error(chalk.red('Error exporting preferences:'), error.message);
  }
}

/**
 * Import preferences from a file
 */
async function importPreferences(inputPath) {
  const configPath = path.join(__dirname, '..', 'preferences', 'config.yaml');
  
  try {
    const importContent = await fs.readFile(inputPath, 'utf8');
    const importedConfig = JSON.parse(importContent);
    
    // Validate imported config
    if (!importedConfig.defaults || !importedConfig.development) {
      throw new Error('Invalid preference file format');
    }
    
    // Save as YAML
    await fs.writeFile(
      configPath,
      yaml.dump(importedConfig, { indent: 2 })
    );
    
    console.log(chalk.green('✓ Preferences imported successfully'));
  } catch (error) {
    console.error(chalk.red('Error importing preferences:'), error.message);
  }
}

module.exports = {
  syncPreferences,
  exportPreferences,
  importPreferences
};