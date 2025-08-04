/**
 * GitHub Commands Module
 * Provides GitHub-related commands for flow-tools
 */

import { Command } from 'commander';
import prIterateCommand from './pr-iterate.js';

// Create the github command group
const githubCommand = new Command('github')
  .description('GitHub integration commands for automated workflows');

// Add subcommands
githubCommand.addCommand(prIterateCommand);

// Additional GitHub commands can be added here:
// githubCommand.addCommand(prEnhanceCommand);
// githubCommand.addCommand(issueManageCommand);
// githubCommand.addCommand(releaseCommand);

export default githubCommand;