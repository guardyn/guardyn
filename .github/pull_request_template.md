# Pull Request

## Description

<!-- Provide a clear and concise description of what this PR does -->

## Related Issues

<!-- Link to related issues using #issue_number or "Fixes #issue_number" -->

Fixes # Relates to #

## Type of Change

<!-- Mark the relevant option(s) with an [x] -->

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 📚 Documentation update
- [ ] 🧪 Test improvement
- [ ] 🏗️ Infrastructure/DevOps change
- [ ] ♻️ Code refactoring (no functional changes)
- [ ] 🔒 Security fix
- [ ] 🎨 UI/UX improvement
- [ ] ⚡ Performance improvement

## Component(s) Affected

<!-- Which components does this PR modify? -->

- [ ] Backend Services (Auth, Messaging, Media, Presence)
- [ ] Mobile Client (Flutter)
- [ ] Desktop Client
- [ ] Web Client
- [ ] Infrastructure (Kubernetes, deployment)
- [ ] Cryptography (E2EE, key exchange)
- [ ] Documentation
- [ ] CI/CD
- [ ] Build system
- [ ] Testing infrastructure
- [ ] Other: <!-- specify -->

## Changes Made

<!-- Describe the changes in detail. Use bullet points for clarity. -->

### What Changed?

-
-
-

### Why These Changes?

<!-- Explain the reasoning behind your approach -->

### Technical Details

<!-- Optional: Add technical implementation details, architecture decisions, or design patterns used -->

## Testing

<!-- Describe how you tested these changes -->

### Test Coverage

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] E2E tests added/updated
- [ ] Performance tests added/updated
- [ ] Manual testing completed

### Test Results

<!-- Paste relevant test output or link to CI results -->

```text
<!-- Test results here -->
```

### How to Test

<!-- Steps for reviewers to test your changes -->

1.
2.
3.

## Screenshots/Recordings

<!-- If applicable, add screenshots or screen recordings -->

**Before:**

<!-- Screenshot/description of previous state -->

**After:**

<!-- Screenshot/description of new state -->

## Performance Impact

<!-- Does this PR affect performance? -->

- [ ] No performance impact
- [ ] Performance improved (provide metrics)
- [ ] Performance degraded (explain why this trade-off is acceptable)
- [ ] Unknown (needs performance testing)

**Metrics:**

<!-- If applicable, provide before/after performance metrics -->

## Breaking Changes

<!-- Does this PR introduce breaking changes? -->

- [ ] No breaking changes
- [ ] Yes, this PR includes breaking changes (describe below)

**Breaking Changes Details:**

<!-- If yes, describe:
- What breaks?
- Why is it necessary?
- Migration guide for users
- Backward compatibility strategy (if any)
-->

## Security Considerations

<!-- Does this PR have security implications? -->

- [ ] No security implications
- [ ] Security improvement
- [ ] Potential security impact (explain below)

**Security Details:**

<!-- If applicable, explain security implications and how they're addressed -->

## Documentation

<!-- Has documentation been updated? -->

- [ ] Documentation updated (docs/ folder)
- [ ] Code comments added/updated
- [ ] API documentation updated (if applicable)
- [ ] README updated (if applicable)
- [ ] No documentation needed

**Documentation Changes:**

<!-- List documentation changes or link to updated docs -->

-
-

## Deployment Notes

<!-- Are there special deployment considerations? -->

- [ ] No special deployment steps
- [ ] Requires database migration
- [ ] Requires configuration changes
- [ ] Requires infrastructure changes
- [ ] Requires manual steps (describe below)

**Deployment Steps:**

<!-- If special steps are needed, describe them -->

1.
2.

## Checklist

<!-- Verify that you've completed these items -->

### Code Quality

- [ ] My code follows the project's style guidelines (see `.github/copilot-instructions.md`)
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My code uses English for all comments, documentation, and variable names
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings or errors
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

### File Placement

- [ ] All files are placed according to project structure guidelines
- [ ] Documentation is in the `docs/` directory (if applicable)
- [ ] Scripts are in appropriate directories (`infra/scripts/` or `backend/crates/e2e-tests/scripts/`)
- [ ] No temporary files committed (everything in `_local/` is gitignored)

### Naming Conventions

- [ ] File names follow project conventions (kebab-case for scripts/configs, snake_case for code)
- [ ] Directory names follow project conventions (kebab-case)
- [ ] Commit messages follow Conventional Commits format
- [ ] Protocol Buffer definitions match naming guidelines (if applicable)

### Test Execution

- [ ] E2E tests pass (`backend/crates/e2e-tests/scripts/run-e2e-tests.sh`)
- [ ] Unit tests pass (`cargo test`)
- [ ] Code formatting passes (`cargo fmt --check`)
- [ ] Linter passes (`cargo clippy -- -D warnings`)
- [ ] CI/CD pipeline passes

### Security

- [ ] No sensitive data (passwords, keys, tokens) in code or commits
- [ ] Security implications reviewed and documented
- [ ] Cryptographic changes reviewed (if applicable)
- [ ] Dependencies audited for vulnerabilities (`cargo audit`)

### Domain Agnostic

- [ ] No hardcoded domains in code or manifests
- [ ] Uses `${DOMAIN}` variable where applicable
- [ ] Works with any domain configuration

## Additional Context

<!-- Add any other context about the PR here -->

## Reviewer Notes

<!-- Optional: Notes for reviewers, areas needing special attention, or specific questions -->

**Areas needing special attention:**

-
- **Questions for reviewers:**

-
- ***

  **For Maintainers:**

- [ ] PR title follows Conventional Commits format
- [ ] Labels applied correctly
- [ ] Milestone set (if applicable)
- [ ] Breaking changes documented in release notes
- [ ] Security implications reviewed
