# GitHub Templates

This directory contains GitHub templates for the Guardyn project to ensure consistency and quality in contributions.

## Pull Request Template

**Location:** `.github/pull_request_template.md`

This template is automatically populated when you create a new Pull Request. It provides a comprehensive structure for documenting your changes.

**Key sections:**

- **Description & Related Issues** - What and why
- **Type of Change** - Bug fix, feature, breaking change, etc.
- **Components Affected** - Which parts are modified
- **Testing** - Coverage and verification steps
- **Performance Impact** - Metrics and considerations
- **Breaking Changes** - Migration guide if needed
- **Security Considerations** - Security implications
- **Documentation** - Updates to docs
- **Deployment Notes** - Special deployment steps
- **Comprehensive Checklist** - Quality, testing, security, conventions

## Issue Templates

**Location:** `.github/ISSUE_TEMPLATE/`

We provide specialized templates for different types of issues:

1. **Bug Report** (`bug_report.md`) - Report bugs or unexpected behavior
2. **Feature Request** (`feature_request.md`) - Suggest new features
3. **Documentation Issue** (`documentation.md`) - Report documentation problems
4. **Testing Issue** (`testing.md`) - Report test or CI/CD issues
5. **Infrastructure Issue** (`infrastructure.md`) - Infrastructure/DevOps problems
6. **Contribution Question** (`contribution.md`) - Questions about contributing

**Configuration:** `config.yml` - Directs security reports and questions to appropriate channels

See [ISSUE_TEMPLATE/README.md](ISSUE_TEMPLATE/README.md) for detailed documentation.

## Using the Templates

### For Contributors

**When opening a PR:**

1. Create your feature branch: `git checkout -b feat/your-feature`
2. Make your changes following project guidelines
3. Push to your fork: `git push origin feat/your-feature`
4. Open PR on GitHub - template will auto-populate
5. Fill out all relevant sections
6. Complete the checklist items
7. Submit and wait for review

**When opening an issue:**

1. Click "New Issue" on GitHub
2. Choose the appropriate template
3. Fill out all required sections
4. Remove unused placeholders
5. Submit the issue

### For Maintainers

**PR Review:**

- Verify template sections are completed
- Check all checklist items are addressed
- Ensure CI passes
- Review code quality and conventions
- Verify documentation updates
- Check for breaking changes
- Review security implications
- Approve or request changes

**Issue Triage:**

- Add appropriate labels beyond `needs-triage`
- Set milestones if applicable
- Assign to team members
- Link related issues/PRs
- Request additional information if needed

## Template Philosophy

Our templates are designed to:

1. **Save Time** - Pre-structured information reduces back-and-forth
2. **Ensure Quality** - Checklists catch common issues before review
3. **Maintain Standards** - Consistent format across all contributions
4. **Document Decisions** - Context and reasoning preserved
5. **Security-First** - Security considerations built into every PR
6. **Audit-Ready** - Clear documentation for security reviews

## Customization

Templates evolve with the project. To improve them:

1. Open a [Documentation Issue](ISSUE_TEMPLATE/documentation.md)
2. Describe the improvement needed
3. Explain the reasoning
4. Submit a PR with changes

## Related Documentation

- [CONTRIBUTING.md](../CONTRIBUTING.md) - Full contribution guidelines
- [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md) - Community standards
- [.github/copilot-instructions.md](copilot-instructions.md) - Detailed coding guidelines
- [SECURITY.md](../SECURITY.md) - Security policy and responsible disclosure

---

**Questions about templates?** Open a [Contribution Question](ISSUE_TEMPLATE/contribution.md) issue!
