# Contributing to Guardyn

<p align="center">
  <strong>🎉 Welcome to the Privacy Rebellion! 🎉</strong>
</p>

<p align="center">
  Thank you for your interest in Guardyn! Every contribution matters — whether it's code, documentation, bug reports, or spreading the word. Together, we're building the future of private communication.
</p>

<p align="center">
  <a href="#-5-minute-quick-start"><strong>⚡ Quick Start</strong></a> •
  <a href="#-good-first-issues"><strong>🎯 Good First Issues</strong></a> •
  <a href="#-justfile-commands"><strong>🛠️ Justfile</strong></a> •
  <a href="#-ways-to-contribute"><strong>💡 Ways to Help</strong></a>
</p>

---

## 🚀 Project Status (January 2026)

**Guardyn v1.0.1 is production-readybackend/proto/auth.proto client-mobile/proto/auth.proto* We completed 57 technical debt items (228 hours of work).

| Component | Status | Description |
|-----------|--------|-------------|
| Backend Services | ✅ Ready | Auth, Messaging, Presence, Media, Call, Notification |
| Cryptography | ✅ Ready | PQXDH (ML-KEM hybrid), Double Ratchet, OpenMLS, SFrame |
| Mobile Clients | ✅ Ready | Flutter (iOS, Android) |
| Desktop Clients | ✅ Ready | Tauri (Windows, macOS, Linux) |
| Infrastructure | ✅ Ready | Kubernetes, TiKV, ScyllaDB, Redpanda |
| Security Audit | 🚧 Planned | Cure53 audit scheduled Q1 2026 |

**We need your help with:**
- 🔒 Security audits and penetration testing
- 📖 Documentation improvements
- 🌍 Translations and localization
- 🧪 Testing on different devices/platforms
- ✨ New features and enhancements

---

## ⚡ 5-Minute Quick Start

The fastest way to start contributing:

### Prerequisites

| Tool | Install |
|------|---------|
| **Docker** | [docker.com](https://docker.com) (required) |
| **Nix** | `curl -L https://nixos.org/nix/install \| sh` (optional, provides all tools) |
| **Just** | `cargo install just` or `brew install just` (task runner) |

### Option 1: Docker Compose (Recommended for Beginners)

```bash
# Clone the repo
git clone https://github.com/guardyn/guardyn.git
cd guardyn

# Start everything (takes ~30 seconds)
docker compose -f docker-compose.dev.yml up -d

# Check status
docker compose -f docker-compose.dev.yml ps

# View logs
docker compose -f docker-compose.dev.yml logs -f

# Stop when done
docker compose -f docker-compose.dev.yml down
```

**That's it!** Backend is running on `localhost:8080`.

### Option 2: With Justfile (Even Easier!)

```bash
git clone https://github.com/guardyn/guardyn.git
cd guardyn

# Start all services
just dc-up

# Check status
just dc-ps

# View logs
just dc-logs

# Stop
just dc-down
```

### Option 3: Full Nix Environment

```bash
git clone https://github.com/guardyn/guardyn.git
cd guardyn

# Enter reproducible shell (installs ALL tools: Rust, kubectl, helm, etc.)
nix develop

# Now you have access to everything
just dc-up           # Start Docker Compose
cargo build          # Build Rust
flutter run          # Run Flutter
kubectl get pods     # Kubernetes (if needed)
```

---

## 🛠️ Justfile Commands

We use [Just](https://github.com/casey/just) as our task runner. It's like `make` but better!

```bash
just --list          # See all available commands
```

### Essential Commands

| Command | Description |
|---------|-------------|
| **Docker Compose (Recommended)** | |
| `just dc-up` | Start all services (~30 sec) |
| `just dc-down` | Stop all services |
| `just dc-logs` | Follow logs |
| `just dc-ps` | Show container status |
| `just dc-rebuild <service>` | Rebuild and restart a service |
| `just dc-reset` | Stop and delete all data |
| **Development** | |
| `just dev-desktop` | Run Tauri desktop client |
| `just dev-android` | Run Flutter on Android |
| `just dev-devices` | List available devices |
| **Testing** | |
| `just test-desktop-unit` | Desktop unit tests |
| `just test-desktop-e2e` | Desktop E2E tests |
| `just test-auth-android` | Android auth tests |
| `just ffi-test` | Crypto FFI tests |
| **Advanced (Kubernetes)** | |
| `just kube-create` | Create k3d cluster |
| `just kube-bootstrap` | Install core components |
| `just verify-kube` | Verify cluster health |
| `just teardown` | Destroy cluster |

### Docker Compose Quick Reference

```bash
just dc-up                    # Start everything
just dc-up-data               # Start only databases
just dc-up-service auth-service  # Start specific service
just dc-rebuild auth-service  # Rebuild after code changes
just dc-log auth-service      # Follow logs for one service
just dc-shell auth-service    # Open shell in container
just dc-cqlsh                 # ScyllaDB CQL shell
just dc-redpanda-health       # Check Redpanda status
just dc-stats                 # Show resource usage
```

---

## 🎯 Good First Issues

New to the project? Start here:

### 📖 Documentation
- Improve setup guides
- Add code examples
- Translate documentation
- Fix typos and unclear instructions

### 🧪 Testing
- Add unit tests for uncovered code
- Test on different devices/platforms
- Report bugs with reproduction steps

### 🎨 UI/UX
- Improve error messages
- Accessibility improvements
- Dark/light theme tweaks

**Look for issues labeled:**
- [`good first issue`](https://github.com/guardyn/guardyn/labels/good%20first%20issue)
- [`help wanted`](https://github.com/guardyn/guardyn/labels/help%20wanted)
- [`documentation`](https://github.com/guardyn/guardyn/labels/documentation)

**Don't see something interesting?** [Open a discussion](https://github.com/guardyn/guardyn/discussions) and tell us what you'd like to work on!

---

## 💡 Ways to Contribute

### 🐛 Report Bugs
1. [Search existing issues](https://github.com/guardyn/guardyn/issues) first
2. If not found, [create a bug report](https://github.com/guardyn/guardyn/issues/new?template=bug_report.md)
3. Include: steps to reproduce, expected vs actual behavior, logs

### ✨ Suggest Features
1. [Check the roadmap](docs/IMPLEMENTATION_PLAN.md) first
2. [Open a feature request](https://github.com/guardyn/guardyn/issues/new?template=feature_request.md)
3. Describe the problem you're solving, not just the solution

### 🔧 Submit Code

```bash
# 1. Fork the repository on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/guardyn.git
cd guardyn

# 3. Create a feature branch
git checkout -b feat/your-feature-name

# 4. Start the dev environment
just dc-up

# 5. Make your changes

# 6. Run tests
cargo test                     # Backend
just test-desktop-unit         # Desktop
cd client-mobile && flutter test  # Mobile

# 7. Commit (follow conventional commits)
git commit -m "feat(auth): add OAuth2 support"

# 8. Push and create a Pull Request
git push origin feat/your-feature-name
```

### 📖 Improve Documentation
- All docs are in the `docs/` directory
- Follow [English-only policy](#-language-policy)
- Use clear, simple language

### 🌍 Spread the Word
- Star the repo ⭐
- Share on social media
- Write blog posts/tutorials
- Give talks about Guardyn
- Tell your privacy-conscious friends

### 💝 Sponsor Development
- [GitHub Sponsors](https://github.com/sponsors/guardyn)
- [Support page](https://guardyn.co/sponsor)

---

## 📋 Pull Request Guidelines

### Before Submitting

- [ ] Tests pass: `cargo test && just test-desktop-unit`
- [ ] Code formatted: `cargo fmt && npm run lint`
- [ ] No warnings: `cargo clippy -- -D warnings`
- [ ] Documentation updated (if behavior changed)
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]
```

**Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`

**Examples:**
```
feat(auth): add OAuth2 provider support
fix(messaging): resolve message ordering issue
docs: update deployment guide
test(e2e): add group chat tests
```

### PR Review Process

1. ✅ CI checks pass (build, tests, linting)
2. 👀 Code review by maintainer
3. 💬 Address feedback
4. 🎉 Merge!

---

## 📁 Project Structure

```
guardyn/
├── backend/              # Rust backend services
│   ├── crates/          # Service implementations
│   │   ├── auth-service/
│   │   ├── messaging-service/
│   │   ├── crypto/      # guardyn-crypto library
│   │   └── e2e-tests/   # Integration tests
│   └── proto/           # Protocol Buffers
├── client-mobile/       # Flutter (iOS/Android)
├── client-desktop/      # Tauri (Windows/macOS/Linux)
├── docs/                # Documentation
├── infra/               # Infrastructure (k8s, scripts)
├── landing/             # Website
├── Justfile             # Task runner commands
└── docker-compose.dev.yml  # Local development
```

---

## 🌐 Language Policy

**All code and documentation must be in English.**

- ✅ Code comments in English
- ✅ Commit messages in English
- ✅ Documentation in English
- ✅ Variable/function names in English
- ❌ No other languages in code or docs

**Exception:** Localization files in `client-mobile/lib/l10n/` and `landing/i18n/`

---

## 🔒 Security

**Found a vulnerability?** Please email [security@guardyn.app](mailto:security@guardyn.app) directly.

**DO NOT open public issues for security vulnerabilities.**

We follow responsible disclosure and will credit researchers in our security advisories.

---

## 🤝 Code of Conduct

We expect all contributors to be respectful and professional. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

---

## 💬 Get Help

- **Questions?** [Open a discussion](https://github.com/guardyn/guardyn/discussions)
- **Bugs?** [File an issue](https://github.com/guardyn/guardyn/issues/new?template=bug_report.md)
- **Chat?** [Join our community](https://github.com/guardyn/guardyn/discussions)

---

## 🙏 Thank You!

Every contribution makes Guardyn better. We appreciate your time and effort!

<p align="center">
  <strong>The Privacy Rebellion needs you! 🛡️</strong>
</p>

---

## 📚 Detailed Documentation

For deeper dives:

| Topic | Document |
|-------|----------|
| Developer Setup | [docs/DEVELOPER_QUICKSTART.md](docs/DEVELOPER_QUICKSTART.md) |
| Architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Testing | [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) |
| API Reference | [docs/GRPC_API.md](docs/GRPC_API.md) |
| Deployment | [docs/PRODUCTION_DEPLOYMENT.md](docs/PRODUCTION_DEPLOYMENT.md) |
| AI Coding Guidelines | [.github/copilot-instructions.md](.github/copilot-instructions.md) |
