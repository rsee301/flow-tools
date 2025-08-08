#!/bin/bash

echo "🔍 MCP Suite Health Check"
echo "========================="

ERRORS=0

# Check Claude Flow
echo -n "Claude Flow: "
if npx claude-flow@alpha version > /dev/null 2>&1; then
  VERSION=$(npx claude-flow@alpha version 2>/dev/null | head -n1)
  echo "✅ OK ($VERSION)"
else
  echo "❌ FAILED"
  ((ERRORS++))
fi

# Check Code Index MCP
echo -n "Code Index MCP: "
if npx @modelcontextprotocol/server-code-index --help > /dev/null 2>&1; then
  echo "✅ OK"
else
  echo "❌ FAILED"
  ((ERRORS++))
fi

# Check hooks functionality
echo -n "Claude Flow Hooks: "
if npx claude-flow@alpha hooks validate > /dev/null 2>&1; then
  echo "✅ OK"
else
  echo "❌ FAILED"
  ((ERRORS++))
fi

# Check configuration files
echo -n "Configuration Files: "
CONFIG_OK=true
for file in .claude/settings.json CLAUDE.md; do
  if [ ! -f "$file" ]; then
    CONFIG_OK=false
    break
  fi
done

if $CONFIG_OK; then
  echo "✅ OK"
else
  echo "❌ Missing files"
  ((ERRORS++))
fi

# Check local overrides
echo -n "Local Overrides: "
if [ -f ".claude.local/settings.override.json" ]; then
  echo "✅ Found"
else
  echo "⚠️  Not configured (optional)"
fi

# Summary
echo "========================="
if [ $ERRORS -eq 0 ]; then
  echo "✅ All systems operational"
  exit 0
else
  echo "❌ $ERRORS issues found"
  exit 1
fi