#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function mergeConfigs() {
  console.log('🔄 Merging configurations...');
  
  // Check if files exist
  const basePath = path.join('.claude', 'settings.json');
  const overridePath = path.join('.claude.local', 'settings.override.json');
  
  if (!fs.existsSync(basePath)) {
    console.log('⚠️  Base settings not found, skipping merge');
    return;
  }
  
  if (!fs.existsSync(overridePath)) {
    console.log('⚠️  Override settings not found, skipping merge');
    return;
  }
  
  // Load configurations
  const base = JSON.parse(fs.readFileSync(basePath, 'utf8'));
  const override = JSON.parse(fs.readFileSync(overridePath, 'utf8'));
  
  // Backup original
  fs.writeFileSync(basePath + '.backup', JSON.stringify(base, null, 2));
  
  // Deep merge
  const merged = deepMerge(base, override);
  
  // Write merged configuration
  fs.writeFileSync(basePath, JSON.stringify(merged, null, 2));
  console.log('✅ Configurations merged successfully');
  console.log('📁 Backup saved to .claude/settings.json.backup');
}

function deepMerge(target, source) {
  const output = Object.assign({}, target);
  
  if (isObject(target) && isObject(source)) {
    Object.keys(source).forEach(key => {
      if (isObject(source[key])) {
        if (!(key in target)) {
          Object.assign(output, { [key]: source[key] });
        } else {
          output[key] = deepMerge(target[key], source[key]);
        }
      } else if (Array.isArray(source[key])) {
        // For arrays, combine unique values
        if (Array.isArray(target[key])) {
          output[key] = [...new Set([...target[key], ...source[key]])];
        } else {
          output[key] = source[key];
        }
      } else {
        Object.assign(output, { [key]: source[key] });
      }
    });
  }
  
  return output;
}

function isObject(item) {
  return item && typeof item === 'object' && !Array.isArray(item);
}

// Run if called directly
if (require.main === module) {
  mergeConfigs();
}

module.exports = { mergeConfigs, deepMerge };