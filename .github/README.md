# 🤖 GitHub Automation Documentation

This directory contains GitHub workflow automation for issue management, labeling, and project coordination.

## 📁 Directory Structure

```
.github/
├── workflows/           # GitHub Actions workflows
│   ├── issue-labeler.yml      # Automatic issue labeling & triage
│   ├── stale-issues.yml       # Stale issue management
│   ├── label-sync.yml         # Repository label synchronization
│   └── issue-metrics.yml      # Issue analytics & reporting
├── ISSUE_TEMPLATE/      # Issue templates
│   ├── bug_report.yml         # Bug report template
│   ├── feature_request.yml    # Feature request template
│   ├── question.yml           # Question/support template
│   └── config.yml             # Template configuration
├── labels/              # Label definitions
│   └── labels.yml             # All repository labels
└── README.md           # This documentation
```

## 🚀 Workflows Overview

### 1. Issue Auto Labeler & Triage (`issue-labeler.yml`)

**Trigger**: When issues are opened, edited, or commented on

**Capabilities**:
- 🏷️ **Smart Labeling**: Automatically applies labels based on content analysis
- 👥 **Auto-Assignment**: Assigns issues to relevant maintainers
- 🎯 **Component Detection**: Identifies which part of the project is affected
- 💬 **Triage Comments**: Adds helpful comments for issues needing triage

**Label Rules**:
```yaml
Component Labels:
- 'mcp' → MCP-related content
- 'bash-aliases' → Shell/alias content  
- 'preferences' → Configuration content
- 'templates' → Template-related content
- 'scripts' → CLI/automation content
- 'documentation' → Docs content

Type Labels:
- 'bug' → Error/problem keywords
- 'enhancement' → Feature/improvement keywords
- 'question' → Question/help keywords
- 'maintenance' → Refactor/cleanup keywords
- 'security' → Security-related keywords

Priority Labels:
- 'priority-high' → Urgent/critical keywords
- 'priority-medium' → Default priority
- 'priority-low' → Nice-to-have keywords
```

### 2. Stale Issue Management (`stale-issues.yml`)

**Trigger**: Daily at 2 AM UTC + manual dispatch

**Capabilities**:
- ⏰ **Auto-Stale Marking**: Issues inactive for 30 days
- 🔒 **Auto-Close**: Stale issues closed after 7 days
- 🏷️ **Smart Exemptions**: Protected labels prevent auto-closure
- 📢 **Helpful Messages**: Clear communication about stale status

**Configuration**:
- Issues: 30 days → stale, +7 days → closed
- PRs: 45 days → stale, +14 days → closed
- Exempt labels: `keep-open`, `pinned`, `security`, `on-hold`, `in-progress`

### 3. Label Synchronization (`label-sync.yml`)

**Trigger**: When `labels.yml` is modified + manual dispatch

**Capabilities**:
- 🔄 **Auto-Sync**: Updates repository labels from configuration
- 🗑️ **Cleanup**: Removes unused labels
- 📝 **Consistency**: Ensures all labels match the definition file

### 4. Issue Metrics & Analytics (`issue-metrics.yml`)

**Trigger**: Weekly on Mondays + manual dispatch

**Capabilities**:
- 📊 **Analytics**: Comprehensive issue statistics
- 📈 **Trends**: Track issue patterns over time
- 🎯 **Component Analysis**: Issues by project component
- ⏱️ **Performance**: Average resolution times
- 🤖 **Auto-Reporting**: Summary in GitHub Actions

**Metrics Tracked**:
- Total, open, and closed issues (last 30 days)
- Issues by label and component
- Average time to resolution
- Recommendations for issue management

## 🏷️ Label System

The repository uses a comprehensive labeling system defined in `labels/labels.yml`:

### Priority Labels
- 🔴 `priority-critical` - Needs immediate attention
- 🟠 `priority-high` - Should be addressed soon  
- 🟡 `priority-medium` - Normal timeline
- 🔵 `priority-low` - Nice to have

### Type Labels
- 🐛 `bug` - Something broken
- ✨ `enhancement` - New feature/improvement
- ❓ `question` - Support request
- 📖 `documentation` - Docs related
- 🔧 `maintenance` - Technical debt/refactoring
- 🔒 `security` - Security related

### Component Labels
- 🔌 `mcp` - MCP functionality
- 🖥️ `bash-aliases` - Shell commands
- ⚙️ `preferences` - Configuration
- 📝 `templates` - Project templates
- 🤖 `scripts` - CLI/automation
- 🔗 `claude-flow-integration` - Claude Flow related

### Status Labels
- 🔍 `triage-needed` - Needs classification
- ⚡ `in-progress` - Being worked on
- 🚫 `blocked` - Waiting on dependencies
- ⏸️ `on-hold` - Strategic pause
- ✅ `ready-for-review` - Code review needed
- 💬 `needs-feedback` - Awaiting input

## 📝 Issue Templates

Three comprehensive templates are available:

### 🐛 Bug Report (`bug_report.yml`)
- Structured bug reporting
- Environment information collection
- Reproduction steps
- Expected vs actual behavior
- Pre-submission checklist

### ✨ Feature Request (`feature_request.yml`)
- Problem statement
- Proposed solution
- Use cases and examples
- Implementation considerations
- Breaking change assessment

### ❓ Question/Support (`question.yml`)
- Categorized questions
- Context and background
- Environment details
- Documentation verification
- Urgency levels

## 🔧 Configuration & Customization

### Updating Labels

1. Edit `.github/labels/labels.yml`
2. Commit changes to main branch
3. Label sync workflow runs automatically
4. All repository labels updated

### Modifying Auto-Assignment

Edit the `assignmentRules` section in `issue-labeler.yml`:

```javascript
const assignmentRules = {
  'mcp': ['rsee301'],           // MCP expert
  'bash-aliases': ['rsee301'],  // Shell expert
  'documentation': ['rsee301'], // Docs maintainer
  'security': ['rsee301']       // Security expert
};
```

### Adjusting Stale Timelines

Modify these values in `stale-issues.yml`:

```yaml
days-before-stale: 30        # Days before marking stale
days-before-close: 7         # Days from stale to close
days-before-pr-stale: 45     # PR stale timeline
days-before-pr-close: 14     # PR close timeline
```

### Custom Label Rules

Add new rules in the `contentRules` section of `issue-labeler.yml`:

```javascript
const contentRules = {
  'your-label': ['keyword1', 'keyword2', 'phrase'],
  // ... existing rules
};
```

## 📊 Monitoring & Analytics

### GitHub Actions Dashboard
- View workflow runs: Repository → Actions tab
- Check automation logs and success rates
- Monitor label application accuracy

### Issue Metrics Report
- Weekly automated reports in Actions summary
- Track issue trends and resolution times
- Component-wise issue distribution

### Manual Triggers
All workflows can be manually triggered:
1. Go to Actions tab
2. Select desired workflow
3. Click "Run workflow"
4. Choose branch and parameters

## 🛡️ Security Considerations

- **Token Permissions**: Workflows use minimal required permissions
- **Sensitive Data**: Templates include warnings about data redaction
- **Auto-Assignment**: Limited to pre-configured maintainers
- **Label Management**: Only authorized changes sync to repository

## 🤝 Contributing to Automation

To improve or extend the automation:

1. **Test Changes**: Use workflow dispatch to test modifications
2. **Monitor Impact**: Check automation accuracy after changes
3. **Update Documentation**: Keep this README current
4. **Review Permissions**: Ensure minimal required access
5. **Validate Templates**: Test issue templates before deployment

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Issue Template Syntax](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests)
- [Label Management Best Practices](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work)

---

This automation system is designed to scale with the project and can be extended with additional workflows as needed.