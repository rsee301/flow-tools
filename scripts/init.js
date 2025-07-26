#!/usr/bin/env node

/**
 * Initialization script for flow-tools
 */

const { execSync } = require('child_process');
const chalk = require('chalk');

console.log(chalk.blue('🚀 Initializing flow-tools...\n'));

try {
  // Make main script executable
  console.log(chalk.gray('Setting up executable permissions...'));
  execSync('chmod +x src/index.js');
  
  // Create necessary directories
  console.log(chalk.gray('Creating directories...'));
  execSync('mkdir -p templates/minimal templates/fullstack templates/api-only');
  
  // Create minimal template
  console.log(chalk.gray('Creating default templates...'));
  execSync('echo "{\\"name\\": \\"project\\", \\"version\\": \\"1.0.0\\"}" > templates/minimal/package.json');
  
  console.log(chalk.green('\n✓ Initialization complete!'));
  console.log(chalk.gray('\nYou can now use flow-tools in your projects.'));
  
} catch (error) {
  console.error(chalk.red('Error during initialization:'), error.message);
  process.exit(1);
}