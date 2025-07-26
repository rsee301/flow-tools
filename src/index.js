#!/usr/bin/env node

/**
 * Flow Tools - Main Entry Point
 * A personal toolset layer for claude-flow
 */

const { program } = require('commander');
const path = require('path');
const { loadPreferences } = require('./preferences');
const { initializeProject } = require('./initializer');
const { addCustomMCP } = require('./mcp-manager');
const { syncPreferences } = require('./sync');

// Load package.json for version
const packageJson = require('../package.json');

program
  .name('flow-tools')
  .description('Personal toolset for claude-flow with custom MCPs and preferences')
  .version(packageJson.version);

// Initialize command
program
  .command('init')
  .description('Initialize flow-tools in current project')
  .option('-t, --template <template>', 'Use specific template', 'minimal')
  .option('-p, --preferences', 'Load user preferences', true)
  .action(async (options) => {
    console.log('🚀 Initializing flow-tools...');
    await initializeProject(options);
  });

// Load preferences command
program
  .command('load-preferences')
  .description('Load saved preferences into current project')
  .option('-f, --force', 'Overwrite existing configurations')
  .action(async (options) => {
    console.log('📋 Loading preferences...');
    await loadPreferences(process.cwd(), options);
  });

// Add MCP command
program
  .command('add-mcp <name>')
  .description('Add a custom MCP tool')
  .option('-d, --description <desc>', 'MCP description')
  .option('-t, --type <type>', 'MCP type', 'tool')
  .action(async (name, options) => {
    console.log(`🔧 Adding custom MCP: ${name}`);
    await addCustomMCP(name, options);
  });

// Sync command
program
  .command('sync')
  .description('Sync current project preferences back to helper')
  .action(async () => {
    console.log('🔄 Syncing preferences...');
    await syncPreferences(process.cwd());
  });

// Parse command line arguments
program.parse(process.argv);