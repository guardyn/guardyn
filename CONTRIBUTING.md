# Contributing to Guardyn

Thank you for your interest in contributing to Guardyn! This document provides guidelines and best practices for contributing to the project.

## 🎯 Current Project Status (November 15, 2025)

**Guardyn is in active MVP development:**

- ✅ **Backend Services**: Auth and Messaging services production-ready and deployed
- ✅ **Cryptography**: X3DH, Double Ratchet, and OpenMLS fully implemented
- ✅ **Infrastructure**: Kubernetes cluster operational with TiKV, ScyllaDB, NATS
- ✅ **Testing**: 8/8 E2E integration tests passing
- 🚧 **Mobile Client**: Authentication complete, messaging UI in progress
- ⏳ **Presence & Media Services**: Planned for next milestone

We welcome contributions in all areas, especially mobile UI development, security audits, and documentation!

## Getting Started

Please refer to the main [README.md](README.md) for setup instructions and project overview.

For detailed coding guidelines and AI-assisted development instructions, see [.github/copilot-instructions.md](.github/copilot-instructions.md).

## Code of Conduct

We expect all contributors to be respectful and professional. Please read our [Code of Conduct](CODE_OF_CONDUCT.md) for details on our standards and enforcement.

## 🐛 Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Check documentation** in the [docs/](docs/) directory
3. **For security vulnerabilities**: Email <security@guardyn.app> directly (DO NOT open public issues)

We have several issue templates to help you report different types of issues:

- **[Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)** - Report bugs or unexpected behavior
- **[Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)** - Suggest new features or enhancements
- **[Documentation Issue](.github/ISSUE_TEMPLATE/documentation.md)** - Report documentation problems
- **[Testing Issue](.github/ISSUE_TEMPLATE/testing.md)** - Report test or CI/CD issues
- **[Infrastructure Issue](.github/ISSUE_TEMPLATE/infrastructure.md)** - Report infrastructure/DevOps problems
- **[Contribution Question](.github/ISSUE_TEMPLATE/contribution.md)** - Ask about contributing

## 📁 Project Structure and File Organization

### Standard Directory Layout

```
guardyn/
├── backend/              # Backend services (Rust)
│   ├── crates/          # Rust workspace crates
│   │   ├── auth-service/
│   │   ├── messaging-service/
│   │   ├── e2e-tests/
│   │   │   ├── scripts/      # Test runner scripts
│   │   │   ├── performance/  # k6 performance tests
│   │   │   └── tests/        # E2E test code
│   │   └── common/
│   └── proto/           # Protocol Buffers definitions
├── client/              # Client applications (Flutter)
├── docs/                # All project documentation
│   ├── *.md            # Technical documentation
│   └── guides/         # User guides and tutorials
├── infra/               # Infrastructure as Code
│   ├── k8s/            # Kubernetes manifests
│   ├── scripts/        # Infrastructure scripts (deployment, maintenance)
│   └── secrets/        # Encrypted secrets (SOPS)
├── cicd/                # CI/CD configurations
│   ├── github/         # GitHub Actions workflows
│   └── docker/         # CI-specific Dockerfiles
├── landing/             # Landing page
└── _local/              # Local development artifacts (gitignored)
```

### File Placement Guidelines

#### Documentation (`docs/`)

All project documentation goes in the `docs/` directory:

- **Technical Documentation**: `docs/GRPC_API.md`, `docs/DATABASE_SCHEMA.md`
- **Architecture Guides**: `docs/mvp_discovery.md`, `docs/infra_poc.md`
- **Testing Documentation**: `docs/TESTING_GUIDE.md`, `docs/QUICKSTART_TESTING.md`
- **Observability**: `docs/OBSERVABILITY_GUIDE.md`
- **Implementation Plans**: `docs/IMPLEMENTATION_PLAN.md`

**Do NOT place documentation in:**
- ❌ Project root (except `README.md`, `CONTRIBUTING.md`, `LICENSE`)
- ❌ Service directories (except service-specific READMEs)

#### Scripts

**Infrastructure Scripts** → `infra/scripts/`
- Deployment scripts: `build-and-deploy-services.sh`, `redeploy-messaging.sh`
- Bootstrap scripts: `bootstrap.sh`, `deploy.sh`
- Verification scripts: `verify.sh`, `verify-tikv.sh`
- Database initialization: `deploy-schemas.sh`, `scylla-init.cql`

**Test Scripts** → `backend/crates/e2e-tests/scripts/`
- E2E test runners: `run-e2e-tests.sh`
- Performance test runners: `run-performance-tests.sh`, `k6-test.sh`

**Build Scripts** → Service directory or `backend/`
- Service-specific builds: `backend/crates/<service>/build.sh`
- Global build: `backend/build-local.sh`

#### Test Files

**E2E Tests** → `backend/crates/e2e-tests/`
- Test code: `backend/crates/e2e-tests/tests/*.rs`
- Test scripts: `backend/crates/e2e-tests/scripts/*.sh`
- Performance tests: `backend/crates/e2e-tests/performance/*.js`

**Unit Tests** → Colocate with source code
- Rust: `src/module.rs` and `src/module_test.rs` or `#[cfg(test)]` modules
- Flutter: `test/` directory in each package

#### Configuration Files

**Infrastructure Configuration** → `infra/`
- Kubernetes: `infra/k8s/base/` and `infra/k8s/overlays/`
- k3d: `infra/k3d-config.yaml`
- Secrets: `infra/secrets/*.enc.yaml`

**Project Root Configuration**
- Nix: `flake.nix`, `flake.lock`
- Tasks: `Justfile`
- Git: `.gitignore`, `.gitattributes`
- SOPS: `.sops.yaml`
- Licensing: `LICENSE`, `NOTICE`

#### Temporary/Local Files → `_local/`

All temporary files, work-in-progress documents, and local artifacts:
- Progress reports: `_local/progress-report-*.md`
- Personal notes: `_local/notes.md`
- Local testing artifacts: `_local/test-data/`

**MUST be gitignored** - Never commit `_local/` to repository.

## 📝 Naming Conventions

### File Naming

**Documentation Files**
- Use SCREAMING_SNAKE_CASE for main docs: `README.md`, `CONTRIBUTING.md`, `TESTING_GUIDE.md`
- Use kebab-case for specific guides: `mvp-discovery.md`, `infra-poc.md`
- Use descriptive names: `DATABASE_SCHEMA.md` not `schema.md`

**Script Files**
- Use kebab-case with `.sh` extension: `run-e2e-tests.sh`, `build-and-deploy-services.sh`
- Make executable: `chmod +x script-name.sh`
- Add shebang: `#!/usr/bin/env bash`

**Source Code Files**
- Rust: `snake_case.rs` (e.g., `auth_service.rs`, `message_store.rs`)
- Proto: `snake_case.proto` (e.g., `auth.proto`, `messaging.proto`)
- Dart/Flutter: `snake_case.dart` (e.g., `login_screen.dart`)

**Configuration Files**
- YAML: `kebab-case.yaml` (e.g., `k3d-config.yaml`, `app-secrets.yaml`)
- TOML: `Cargo.toml`, `flake.toml`
- JSON: `camelCase.json` or `kebab-case.json`

### Directory Naming

**Use kebab-case for directories:**
- ✅ `auth-service/`, `e2e-tests/`, `cicd/`
- ❌ `AuthService/`, `e2e_tests/`, `CI_CD/`

**Exceptions:**
- Rust workspace: `crates/` (Rust convention)
- Kubernetes: `k8s/` (industry standard abbreviation)
- Proto: `proto/` (gRPC convention)

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks
- `ci:` CI/CD changes

**Examples:**
```
feat(auth): add OAuth2 provider support
fix(messaging): resolve message ordering issue
docs: update deployment guide with TLS setup
refactor(crypto): simplify key derivation logic
test(e2e): add group chat message delivery tests
```

## 🔧 Development Workflow

### Before You Start

1. **Check existing issues**: Look for related work to avoid duplicates
2. **Create an issue**: Describe the problem/feature you're addressing
3. **Fork the repository**: Work in your own fork
4. **Create a feature branch**: `git checkout -b feat/your-feature-name`

### Making Changes

1. **Follow the file placement guidelines** above
2. **Use consistent naming conventions**
3. **Write tests** for new features
4. **Update documentation** when changing behavior
5. **Add comments** for complex logic
6. **Follow language policy** (English only)

### Testing Your Changes

```bash
# Run unit tests
cd backend && cargo test

# Run E2E tests
backend/crates/e2e-tests/scripts/run-e2e-tests.sh

# Run performance tests
backend/crates/e2e-tests/scripts/k6-test.sh

# Check code formatting
cargo fmt --check
cargo clippy -- -D warnings
```

### Submitting Changes

1. **Commit your changes** with conventional commit messages
2. **Push to your fork**: `git push origin feat/your-feature-name`
3. **Open a Pull Request** against `main` branch
4. **Fill out the PR template** (see `.github/pull_request_template.md`)
5. **Address review feedback** promptly
6. **Ensure CI passes** before merge

## 📋 Pull Request Guidelines

When you open a PR, GitHub will automatically populate a comprehensive template that includes:

- **Description and context** - What changes are made and why
- **Type of change** - Bug fix, feature, breaking change, etc.
- **Components affected** - Which parts of the codebase are modified
- **Testing details** - Test coverage and how to verify changes
- **Breaking changes** - Documentation of any breaking changes
- **Security considerations** - Security implications review
- **Documentation updates** - Changes to docs or comments
- **Comprehensive checklist** - Code quality, file placement, naming, testing, security

**Key sections to complete:**

- Link related issues using `Fixes #123` or `Relates to #456`
- Mark the type(s) of change your PR introduces
- Describe what changed and why
- Provide test results and instructions for reviewers
- Complete all relevant checklist items

**Full template:** [`.github/pull_request_template.md`](.github/pull_request_template.md)

### PR Review Process

1. **Automated checks**: CI must pass (build, tests, linting)
2. **Code review**: At least one maintainer approval required
3. **Documentation**: Verify docs are updated if needed
4. **Testing**: Confirm tests cover new functionality
5. **Merge**: Squash and merge with clean commit message

## 🎯 Common Contribution Types

### Adding Documentation

1. Create markdown file in `docs/` directory
2. Use clear, descriptive filename
3. Add to relevant README or index
4. Follow English-only policy

### Adding a Script

1. Place in appropriate directory (`infra/scripts/` or `backend/crates/e2e-tests/scripts/`)
2. Use kebab-case naming with `.sh` extension
3. Add shebang and make executable
4. Document usage in script header
5. Add to relevant README

### Adding a Service

1. Create directory in `backend/crates/`
2. Add `Cargo.toml` with proper metadata
3. Implement gRPC service from proto
4. Add unit tests
5. Update `backend/Cargo.toml` workspace
6. Add deployment manifests in `infra/k8s/base/`
7. Document in `docs/`

### Fixing a Bug

1. Create issue describing the bug
2. Write test that reproduces the issue
3. Fix the bug
4. Verify test passes
5. Add regression test if needed
6. Update documentation if behavior changed

## 🔍 Code Review Checklist

Reviewers should verify:

- [ ] Files are in correct directories
- [ ] Naming conventions are followed
- [ ] Code is in English (comments, variables, functions)
- [ ] Documentation is updated
- [ ] Tests are included
- [ ] No hardcoded domains or credentials
- [ ] Commit messages are clear
- [ ] No unnecessary files in PR

## 📚 Resources

- [Language Policy](.github/copilot-instructions.md#-language-policy---critical)
- [Naming Conventions](.github/copilot-instructions.md#-naming-conventions---critical)
- [Architecture Overview](.github/copilot-instructions.md#architecture)
- [Testing Guide](docs/TESTING_GUIDE.md)
- [Infrastructure Guide](docs/infra_poc.md)

## 🙏 Thank You!

Your contributions make Guardyn better for everyone. We appreciate your time and effort in following these guidelines!

