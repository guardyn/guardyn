---
name: 🧪 Testing Issue
about: Report issues with tests or CI/CD pipelines
title: "[TEST] "
labels: ["testing", "needs-triage"]
assignees: ""
---

## Test Issue Description

<!-- Describe the testing issue -->

## Test Type

<!-- What kind of test is affected? -->

- [ ] E2E Integration Tests
- [ ] Unit Tests
- [ ] Performance Tests (k6)
- [ ] CI/CD Pipeline
- [ ] Test Infrastructure
- [ ] Test Coverage
- [ ] Other: <!-- specify -->

## Location

**Component:** <!-- e.g., auth-service, messaging-service, e2e-tests -->

**Test File:** <!-- e.g., backend/crates/e2e-tests/tests/auth_flow.rs -->

**Test Name:** <!-- e.g., test_user_registration -->

**CI Workflow:** <!-- e.g., .github/workflows/test.yml -->

## Issue Details

### What's Wrong?

<!-- Describe the test issue in detail -->

### Expected Behavior

<!-- What should happen? -->

### Actual Behavior

<!-- What actually happens? -->

### Reproducibility

- [ ] Consistently fails
- [ ] Intermittent (flaky test)
- [ ] Fails only in CI
- [ ] Fails only locally
- [ ] Fails in specific environment: <!-- specify -->

## Test Output

<!-- Paste test output, error messages, or CI logs -->

```text
<!-- Paste test output here -->
```

## Environment

**Local Development:**

- OS: <!-- e.g., Ubuntu 22.04, macOS 14.0 -->
- Rust version: <!-- e.g., 1.75.0 -->
- Kubernetes: <!-- e.g., k3d v5.6.0 -->
- Nix: <!-- e.g., 2.18.0 -->

**CI Environment:**

- Runner: <!-- e.g., ubuntu-latest, self-hosted -->
- Workflow: <!-- e.g., test.yml, build.yml -->

## Steps to Reproduce

1. <!-- First step -->
2. <!-- Second step -->
3. <!-- Additional steps... -->

## Impact

<!-- How does this affect the project? -->

- [ ] Blocking CI/CD pipeline
- [ ] False positives (test fails but functionality works)
- [ ] False negatives (test passes but functionality broken)
- [ ] Slow test execution
- [ ] Flaky tests causing merge delays
- [ ] Missing test coverage

## Possible Cause

<!-- Optional: What might be causing this issue? -->

## Suggested Fix

<!-- Optional: How could this be fixed? -->

## Additional Context

<!-- Add any other context, related issues, or screenshots -->

---

**Before submitting:**

- [ ] I have verified this is a testing/CI issue, not a functionality bug
- [ ] I have included relevant test output and error messages
- [ ] I have specified whether this is reproducible or intermittent
- [ ] I have checked if this affects CI or local development (or both)
