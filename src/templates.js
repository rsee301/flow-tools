/**
 * Templates Module
 * Handles project template management
 */

const fs = require('fs').promises;
const path = require('path');
const chalk = require('chalk');

/**
 * Load a project template
 */
async function loadTemplate(templateName, targetPath) {
  const templatePath = path.join(__dirname, '..', 'templates', templateName);
  
  try {
    // Check if template exists
    await fs.access(templatePath);
    
    console.log(chalk.blue(`Loading template: ${templateName}`));
    
    // Copy template files to target
    await copyDirectory(templatePath, targetPath);
    
    console.log(chalk.green('✓ Template loaded successfully'));
  } catch (error) {
    console.error(chalk.red(`Template '${templateName}' not found.`));
    console.log(chalk.yellow('Available templates:'));
    await listTemplates();
  }
}

/**
 * List available templates
 */
async function listTemplates() {
  const templatesDir = path.join(__dirname, '..', 'templates');
  
  try {
    const templates = await fs.readdir(templatesDir);
    templates.forEach(template => {
      console.log(chalk.gray(`  - ${template}`));
    });
  } catch (error) {
    console.log(chalk.yellow('No templates found.'));
  }
}

/**
 * Create a new template from current project
 */
async function createTemplate(templateName, sourcePath) {
  const templatePath = path.join(__dirname, '..', 'templates', templateName);
  
  // Check if template already exists
  try {
    await fs.access(templatePath);
    console.log(chalk.yellow(`Template '${templateName}' already exists.`));
    return;
  } catch {
    // Template doesn't exist, continue
  }
  
  console.log(chalk.blue(`Creating template: ${templateName}`));
  
  // Create template directory
  await fs.mkdir(templatePath, { recursive: true });
  
  // Define files to include in template
  const includePatterns = [
    'package.json',
    'tsconfig.json',
    '.eslintrc.json',
    '.prettierrc',
    'jest.config.js',
    'README.md',
    '.gitignore',
    'src/**/*',
    '.claude/**/*'
  ];
  
  // Copy relevant files
  for (const pattern of includePatterns) {
    await copyPattern(sourcePath, templatePath, pattern);
  }
  
  // Create template metadata
  const metadata = {
    name: templateName,
    created: new Date().toISOString(),
    description: `Template created from ${path.basename(sourcePath)}`,
    files: await getTemplateFiles(templatePath)
  };
  
  await fs.writeFile(
    path.join(templatePath, 'template.json'),
    JSON.stringify(metadata, null, 2)
  );
  
  console.log(chalk.green(`✓ Template '${templateName}' created successfully`));
}

/**
 * Copy directory recursively
 */
async function copyDirectory(source, target) {
  const entries = await fs.readdir(source, { withFileTypes: true });
  
  for (const entry of entries) {
    const sourcePath = path.join(source, entry.name);
    const targetPath = path.join(target, entry.name);
    
    if (entry.isDirectory()) {
      await fs.mkdir(targetPath, { recursive: true });
      await copyDirectory(sourcePath, targetPath);
    } else {
      // Skip template metadata when copying
      if (entry.name !== 'template.json') {
        await fs.copyFile(sourcePath, targetPath);
      }
    }
  }
}

/**
 * Copy files matching a pattern
 */
async function copyPattern(source, target, pattern) {
  // Simple pattern matching (this is a basic implementation)
  if (pattern.includes('**')) {
    // Handle recursive patterns
    const basePath = pattern.split('**')[0];
    try {
      await copyDirectory(
        path.join(source, basePath),
        path.join(target, basePath)
      );
    } catch {
      // Directory might not exist
    }
  } else {
    // Handle single file patterns
    try {
      const sourcePath = path.join(source, pattern);
      const targetPath = path.join(target, pattern);
      const targetDir = path.dirname(targetPath);
      
      await fs.mkdir(targetDir, { recursive: true });
      await fs.copyFile(sourcePath, targetPath);
    } catch {
      // File might not exist
    }
  }
}

/**
 * Get list of files in template
 */
async function getTemplateFiles(templatePath, basePath = '') {
  const files = [];
  const entries = await fs.readdir(path.join(templatePath, basePath), { withFileTypes: true });
  
  for (const entry of entries) {
    const relativePath = path.join(basePath, entry.name);
    
    if (entry.isDirectory()) {
      files.push(...await getTemplateFiles(templatePath, relativePath));
    } else if (entry.name !== 'template.json') {
      files.push(relativePath);
    }
  }
  
  return files;
}

module.exports = {
  loadTemplate,
  listTemplates,
  createTemplate
};