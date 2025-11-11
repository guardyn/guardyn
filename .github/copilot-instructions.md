# Guardyn AI Coding Instructions

## Project Overview

Guardyn is a privacy-focused secure communication platform (MVP/PoC phase) built with:
- **Security-first**: E2EE messaging (X3DH/Double Ratchet/OpenMLS), audio/video calls, group chat with cryptographic verification
- **Infrastructure**: Kubernetes-native (k3d for local dev), TiKV + ScyllaDB for data, NATS JetStream for messaging
- **Reproducibility**: Nix flakes for deterministic builds, SOPS + Age for secrets, cosign for artifact signing

## 🌍 Language Policy - CRITICAL

**ENGLISH IS THE ONLY PERMITTED LANGUAGE FOR ALL PROJECT CONTENT.**

### Mandatory Rules

1. **ALL documentation MUST be written in English**
   - README files
   - Technical documentation (docs/)
   - API documentation
   - Architecture diagrams and descriptions
   - Setup guides and tutorials
   - Troubleshooting guides

2. **ALL code comments MUST be in English**
   - Go code comments
   - Dart/Flutter code comments
   - JavaScript/TypeScript code comments
   - Configuration file comments
   - Shell script comments
   - SQL/CQL comments

3. **ALL commit messages MUST be in English**
   - Follow Conventional Commits format in English
   - Examples: `feat:`, `fix:`, `docs:`, `refactor:`

4. **ALL variable/function names MUST use English words**
   - No transliteration from other languages
   - Use clear, descriptive English names

5. **STRICTLY FORBIDDEN:**
   - ❌ Russian language (Cyrillic: русский)
   - ❌ Ukrainian language (Cyrillic: українська)
   - ❌ Any other Cyrillic-based languages
   - ❌ Any non-English languages in code or documentation
   - ❌ Mixed language content (English + other languages)

### Exceptions (ONLY)

Translation files for localization purposes ONLY:
- `client/lib/l10n/` - Flutter localization files
- `landing/i18n/` - Landing page translations
- Explicitly marked translation files with `.{locale}.md` naming

**Example valid translations:**
- `README.md` ✅ (English - main file)
- `README.ru.md` ✅ (Russian translation - explicit suffix)
- `SETUP.uk.md` ✅ (Ukrainian translation - explicit suffix)

### Audit Readiness Requirement

This project MUST be **audit-ready** for security review:
- International security auditors require English documentation
- Code must be comprehensible to global security experts
- No ambiguity in security-critical implementations
- English is the international standard for security audits

### Enforcement

**When generating or editing ANY file:**
1. Check: Is this content in English?
2. If NO → Rewrite in English or refuse the task
3. If translating existing content → Mark clearly as translation

**When reviewing existing files:**
- If non-English content is found → Flag for translation
- Suggest English equivalents
- Never add non-English content to existing English files

**AI Agent Behavior:**
- Always write in English by default
- If user requests content in another language → Ask for clarification
- Remind user of English-only policy
- Offer to create a separate translation file if needed

### Why This Matters

1. **Security Audits**: Third-party auditors need English documentation
2. **International Collaboration**: Global contributors need to understand code
3. **Professional Standards**: Industry best practices require English
4. **Maintainability**: Future developers need consistent language
5. **Legal/Compliance**: English is standard for legal tech documents

---

## 📝 Naming Conventions - CRITICAL

**Consistent naming across Protocol Buffers and Rust code is mandatory.**

### Protocol Buffers Style Guide

Follow official [Protocol Buffers Style Guide](https://protobuf.dev/programming-guides/style/):

1. **Messages**: PascalCase
   ```protobuf
   message RegisterRequest { }
   message ErrorResponse { }
   ```

2. **Fields**: snake_case
   ```protobuf
   string user_id = 1;
   int32 retry_count = 2;
   ```

3. **Enums**: PascalCase for type, SCREAMING_SNAKE_CASE for values
   ```protobuf
   enum ErrorCode {
     UNKNOWN = 0;
     INVALID_REQUEST = 1;
     UNAUTHORIZED = 2;
     NOT_FOUND = 3;
     INTERNAL_ERROR = 4;
   }
   ```

4. **Services**: PascalCase
   ```protobuf
   service AuthService { }
   ```

5. **RPC methods**: PascalCase
   ```protobuf
   rpc RegisterUser(RegisterRequest) returns (RegisterResponse);
   ```

### Rust Code Generation from Proto

**Prost** (Protocol Buffers for Rust) automatically converts proto naming to Rust conventions:

1. **Proto enums → Rust enums**: SCREAMING_SNAKE_CASE → PascalCase
   ```rust
   // Proto: INTERNAL_ERROR
   ErrorCode::InternalError

   // Proto: UNAUTHORIZED
   ErrorCode::Unauthorized

   // Proto: NOT_FOUND
   ErrorCode::NotFound

   // Proto: INVALID_REQUEST
   ErrorCode::InvalidRequest
   ```

2. **Proto messages → Rust structs**: Already PascalCase (unchanged)
   ```rust
   RegisterRequest
   ErrorResponse
   ```

3. **Proto fields → Rust fields**: Already snake_case (unchanged)
   ```rust
   user_id
   retry_count
   ```

### Mandatory Rules

1. **NEVER use custom enum variants in Rust code**
   - ❌ `ErrorCode::Internal` (doesn't exist in proto)
   - ✅ `ErrorCode::InternalError` (matches proto `INTERNAL_ERROR`)

2. **ALWAYS reference proto definitions when coding**
   - Check `backend/proto/*.proto` files for exact enum values
   - Use generated code from `src/generated/` as source of truth

3. **Proto files are the canonical source**
   - Update proto first, then regenerate Rust code
   - Never modify generated `*.rs` files manually

4. **Use full enum paths in error handling**
   ```rust
   use proto::common::error_response::ErrorCode;

   ErrorCode::InternalError as i32  // Correct
   ErrorCode::Unauthorized as i32   // Correct
   ErrorCode::NotFound as i32       // Correct
   ```

### Code Review Checklist

Before committing code that uses proto-generated types:

- [ ] All enum variants match proto definitions (with PascalCase conversion)
- [ ] No custom/invented enum variants
- [ ] Struct field names match proto snake_case
- [ ] Build succeeds with `cargo build --release`
- [ ] No warnings about missing enum variants

### Common Mistakes to Avoid

| ❌ Wrong (Custom Name) | ✅ Correct (Proto-Generated) | Proto Definition |
|------------------------|------------------------------|------------------|
| `ErrorCode::Internal` | `ErrorCode::InternalError` | `INTERNAL_ERROR` |
| `ErrorCode::Unauthenticated` | `ErrorCode::Unauthorized` | `UNAUTHORIZED` |
| `ErrorCode::InvalidInput` | `ErrorCode::InvalidRequest` | `INVALID_REQUEST` |
| `ErrorCode::AlreadyExists` | `ErrorCode::Conflict` | `CONFLICT` |

### Verification

When adding new proto definitions:

1. Define in proto with SCREAMING_SNAKE_CASE:
   ```protobuf
   enum Status {
     STATUS_UNKNOWN = 0;
     STATUS_PENDING = 1;
     STATUS_COMPLETED = 2;
   }
   ```

2. Generated Rust will use PascalCase:
   ```rust
   Status::StatusUnknown
   Status::StatusPending
   Status::StatusCompleted
   ```

3. Test compilation:
   ```bash
   cargo build --release -p <service-name>
   ```

---

## 🌐 Domain-Agnostic Architecture - CRITICAL

**Guardyn is 100% domain-agnostic** - it works with ANY domain you choose.

### SINGLE SOURCE OF TRUTH for Domain Configuration

**The `DOMAIN` environment variable in the configuration file is the ONLY place to configure the project domain. All services automatically use this value.**

### Mandatory Rules

1. **NEVER hardcode domains in code, manifests, or documentation**
   - ❌ `https://guardyn.io/api`
   - ❌ `auth.guardyn.local`
   - ✅ `https://${DOMAIN}/api`
   - ✅ `auth.${DOMAIN}`

2. **Use the DOMAIN variable everywhere**
   - Kubernetes Ingress hosts
   - TLS certificate SANs
   - Service URLs
   - API endpoints
   - Redirect URIs

3. **Generic examples in documentation**
   - Use `yourdomain.com` or `example.com` for examples
   - Never use specific real domains in tutorials
   - Show how to configure, not pre-configure

4. **Test with any domain**
   - Your changes MUST work with any domain name
   - Don't assume domain structure (no hardcoded subdomains)
   - Don't assume TLD (.com, .io, .local, etc.)

### Domain Configuration - Where to Set It

**Set domain ONLY in ONE place:**

```yaml
# For local development
DOMAIN: guardyn.local

# For production
DOMAIN: yourdomain.com
```

**All services automatically use this:**
- Auth service: `auth.${DOMAIN}`
- API gateway: `api.${DOMAIN}`
- WebSocket: `ws.${DOMAIN}`
- Media: `media.${DOMAIN}`
- Web client: `app.${DOMAIN}`

### Examples

**❌ WRONG - Hardcoded domain:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: auth-ingress
spec:
  rules:
  - host: auth.guardyn.io  # NEVER DO THIS
```

**✅ CORRECT - Domain variable:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: auth-ingress
spec:
  rules:
  - host: auth.${DOMAIN}  # Configured via kustomize
```

**❌ WRONG - Domain in documentation:**
```markdown
Access the application at https://guardyn.io
```

**✅ CORRECT - Generic example:**
```markdown
Access the application at https://yourdomain.com (replace with your configured domain)
```

### Why This Matters

1. **Deployment Flexibility**: Works in any environment (dev, staging, prod, on-prem)
2. **Multi-Tenancy Ready**: Easy to deploy multiple instances with different domains
3. **Testing**: Can test with .local, .test, or real domains
4. **Security Audits**: No hardcoded assumptions that could hide bugs
5. **Open Source**: Users can deploy with their own domains

---

## 📁 File Organization and Naming Standards - CRITICAL

**Consistent file placement and naming conventions are mandatory for maintainability.**

### Directory Structure Standards

```
guardyn/
├── backend/              # Backend services (Rust)
│   ├── crates/          # Rust workspace crates (snake_case names)
│   │   ├── auth-service/
│   │   ├── messaging-service/
│   │   ├── media-service/
│   │   ├── presence-service/
│   │   ├── notification-service/
│   │   ├── e2e-tests/
│   │   │   ├── scripts/      # Test runner scripts
│   │   │   ├── performance/  # k6 performance tests
│   │   │   └── tests/        # E2E test code
│   │   ├── common/          # Shared code
│   │   └── crypto/          # Cryptography primitives
│   ├── proto/               # Protocol Buffers definitions
│   └── build-local.sh       # Local build script
├── client/                  # Client applications (Flutter)
├── docs/                    # ALL project documentation
│   ├── *.md                # Technical documentation
│   └── guides/             # User guides (if needed)
├── infra/                   # Infrastructure as Code
│   ├── k8s/                # Kubernetes manifests
│   │   ├── base/          # Base Kustomize manifests
│   │   └── overlays/      # Environment-specific overlays
│   ├── scripts/            # Infrastructure scripts
│   │   ├── bootstrap.sh
│   │   ├── deploy.sh
│   │   ├── verify.sh
│   │   ├── build-and-deploy-services.sh
│   │   └── redeploy-messaging.sh
│   └── secrets/            # SOPS-encrypted secrets
├── cicd/                    # CI/CD configurations
│   ├── github/
│   │   ├── actions/       # Custom GitHub Actions
│   │   └── workflows/     # Workflow definitions
│   └── docker/            # CI-specific Dockerfiles
├── landing/                 # Landing page
└── _local/                  # Local artifacts (MUST BE GITIGNORED)
```

### File Placement Rules

#### 1. Documentation Files → `docs/`

**ALL documentation MUST be in `docs/` directory:**

- ✅ `docs/TESTING_GUIDE.md` - Testing documentation
- ✅ `docs/QUICKSTART_TESTING.md` - Quick testing reference
- ✅ `docs/GRPC_API.md` - API documentation
- ✅ `docs/DATABASE_SCHEMA.md` - Database schema
- ✅ `docs/OBSERVABILITY_GUIDE.md` - Monitoring and logging
- ✅ `docs/IMPLEMENTATION_PLAN.md` - Implementation roadmap
- ✅ `docs/mvp_discovery.md` - Product vision
- ✅ `docs/infra_poc.md` - Infrastructure guide

**Exceptions (files allowed in project root):**
- `README.md` - Main project README
- `CONTRIBUTING.md` - Contribution guidelines
- `LICENSE` - License file
- `NOTICE` - Legal notices

**NEVER place documentation in:**
- ❌ Project root (except exceptions above)
- ❌ Service directories (except service-specific READMEs)
- ❌ `_local/` directory

#### 2. Infrastructure Scripts → `infra/scripts/`

**ALL infrastructure and deployment scripts:**

- ✅ `infra/scripts/bootstrap.sh` - Cluster bootstrap
- ✅ `infra/scripts/deploy.sh` - Service deployment
- ✅ `infra/scripts/verify.sh` - Smoke tests
- ✅ `infra/scripts/build-and-deploy-services.sh` - Build and deploy
- ✅ `infra/scripts/redeploy-messaging.sh` - Messaging redeployment
- ✅ `infra/scripts/deploy-schemas.sh` - Database schema deployment
- ✅ `infra/scripts/verify-tikv.sh` - TiKV verification

#### 3. Test Scripts → `backend/crates/e2e-tests/scripts/`

**ALL test runner scripts:**

- ✅ `backend/crates/e2e-tests/scripts/run-e2e-tests.sh` - E2E test runner
- ✅ `backend/crates/e2e-tests/scripts/run-performance-tests.sh` - Performance tests
- ✅ `backend/crates/e2e-tests/scripts/k6-test.sh` - k6 wrapper with Nix

**Test code organization:**
- E2E tests: `backend/crates/e2e-tests/tests/*.rs`
- Performance tests: `backend/crates/e2e-tests/performance/*.js`
- Test fixtures: `backend/crates/e2e-tests/fixtures/`

#### 4. Build Scripts

**Service-specific build scripts:**
- ✅ `backend/crates/<service>/build.rs` - Cargo build script
- ✅ `backend/build-local.sh` - Local development build

**NEVER place build scripts in:**
- ❌ Project root
- ❌ `infra/scripts/` (unless deploying infrastructure)

#### 5. Configuration Files

**Infrastructure configuration → `infra/`:**
- `infra/k8s/base/` - Kubernetes base manifests
- `infra/k8s/overlays/` - Environment-specific overlays
- `infra/k3d-config.yaml` - k3d cluster configuration
- `infra/secrets/*.enc.yaml` - SOPS-encrypted secrets

**Project root configuration:**
- `flake.nix`, `flake.lock` - Nix configuration
- `Justfile` - Task runner configuration
- `.gitignore`, `.gitattributes` - Git configuration
- `.sops.yaml` - SOPS encryption configuration
- `Cargo.toml` - Rust workspace configuration

#### 6. Temporary/Local Files → `_local/`

**ALL temporary and work-in-progress files:**

- ✅ `_local/progress-report-*.md` - Progress reports
- ✅ `_local/notes.md` - Personal notes
- ✅ `_local/test-data/` - Local test artifacts
- ✅ `_local/*.md` - Any work-in-progress documents

**CRITICAL:**
- `_local/` MUST be in `.gitignore`
- NEVER commit `_local/` contents to repository
- Use for local development only

### Naming Conventions

#### File Names

**Documentation Files:**
- Main docs: `SCREAMING_SNAKE_CASE.md`
  - Examples: `README.md`, `CONTRIBUTING.md`, `TESTING_GUIDE.md`
- Specific guides: `kebab-case.md`
  - Examples: `mvp-discovery.md`, `infra-poc.md`, `quick-start.md`

**Script Files:**
- Format: `kebab-case.sh`
- Examples: `run-e2e-tests.sh`, `build-and-deploy-services.sh`
- Must be executable: `chmod +x script.sh`
- Must have shebang: `#!/usr/bin/env bash`

**Source Code:**
- Rust: `snake_case.rs`
  - Examples: `auth_service.rs`, `message_store.rs`, `crypto_utils.rs`
- Proto: `snake_case.proto`
  - Examples: `auth.proto`, `messaging.proto`, `common.proto`
- Dart/Flutter: `snake_case.dart`
  - Examples: `login_screen.dart`, `message_widget.dart`

**Configuration:**
- YAML: `kebab-case.yaml` or `kebab-case.yml`
  - Examples: `k3d-config.yaml`, `app-secrets.yaml`
- TOML: Standard names
  - Examples: `Cargo.toml`, `pyproject.toml`
- JSON: `camelCase.json` or `kebab-case.json`

#### Directory Names

**Standard:** Use `kebab-case` for directories:
- ✅ `auth-service/`, `e2e-tests/`, `messaging-service/`
- ❌ `AuthService/`, `e2e_tests/`, `MessagingService/`

**Exceptions (industry standards):**
- `crates/` - Rust convention
- `k8s/` - Kubernetes abbreviation
- `proto/` - gRPC convention
- `cicd/` - CI/CD abbreviation

### File Organization Checklist

When adding new files, verify:

- [ ] Documentation files are in `docs/`
- [ ] Infrastructure scripts are in `infra/scripts/`
- [ ] Test scripts are in `backend/crates/e2e-tests/scripts/`
- [ ] Configuration files are in appropriate directories
- [ ] Temporary files are in `_local/` (and gitignored)
- [ ] File names follow naming conventions
- [ ] Scripts have correct permissions and shebang
- [ ] No documentation in project root (except exceptions)

### Common Mistakes to Avoid

| ❌ Wrong | ✅ Correct | Reason |
|---------|-----------|---------|
| `ROOT/test-guide.md` | `docs/TESTING_GUIDE.md` | Documentation in root |
| `ROOT/deploy.sh` | `infra/scripts/deploy.sh` | Scripts in wrong location |
| `backend/run-tests.sh` | `backend/crates/e2e-tests/scripts/run-e2e-tests.sh` | Test scripts misplaced |
| `AuthService/` | `auth-service/` | Wrong directory naming |
| `run_tests.sh` | `run-tests.sh` | Wrong file naming |
| `notes.md` | `_local/notes.md` | Temporary files not in _local/ |

---

## Architecture

### Component Structure
- `infra/`: Complete Kubernetes stack with kustomize overlays (`local`/`prod`)
  - Namespaces: `platform`, `data`, `messaging`, `observability`, `apps` (see `infra/k8s/base/namespaces/namespaces.yaml`)
  - Data layer: TiKV (distributed transactional KV), ScyllaDB (high-throughput storage)
  - Messaging: NATS JetStream for event streaming
  - Observability: Prometheus + Loki + Tempo + Grafana stack
- `cicd/`: GitHub Actions workflows + reproducible-build action
- `docs/`: `mvp_discovery.md` (product vision), `infra_poc.md` (infrastructure guide)

### Key Design Decisions
- **Kustomize over Helm for base manifests**: Helm only for 3rd-party operators (NATS, TiKV, Scylla, Prometheus)
- **k3d clusters mimic production**: 3 servers + 2 agents with Cilium CNI, registry at `guardyn-registry:5000`
- **All secrets encrypted with SOPS**: Age keys in `infra/secrets/age-key.txt` (gitignored), config in `.sops.yaml`
- **Domain-agnostic by design**: `DOMAIN` variable is the single source of truth for all services

## Developer Workflows

### Environment Setup
```bash
nix develop  # Enter reproducible shell with all tools (Rust, kubectl, helm, k3d, sops, cosign)
```
Toolchain pinned in `flake.nix` (nixos-23.11, rust-overlay for stable Rust).

### Kubernetes Cluster Management
```bash
just kube-create       # Creates k3d cluster from infra/k3d-config.yaml (3 servers, 2 agents)
just kube-bootstrap    # Installs CRDs + namespaces + core operators
just k8s-deploy <svc>  # Deploys service: nats | tikv | scylladb | monitoring
just verify-kube       # Smoke tests (pod readiness, NATS pub/sub, TiKV/Scylla health)
just teardown          # Destroys cluster
```

**Critical**: Always run `kube-bootstrap` before deploying services. Deployment order matters:
1. Namespaces + cert-manager + Cilium
2. Data stores (tikv, scylladb)
3. Messaging (nats)
4. Monitoring last

### Secrets Management
- Generate Age key: `age-keygen -o infra/secrets/age-key.txt`
- Update `.sops.yaml` with public key before encrypting
- Encrypt manifests: `sops -e secrets.yaml > secrets.enc.yaml`
- Never commit plaintext credentials to git
- Reference vault paths or placeholders when sharing manifests

### CI/CD Pipeline
- **build.yml**: Runs on PRs, lints (rustfmt, clippy), security scans (cargo-audit)
- **test.yml**: Integration tests on `main` push—spins up k3d cluster, deploys core services, runs smoke tests
- **release.yml**: On version tags (`v*.*.*`), builds release binaries, generates SBOM (syft), signs with cosign

All workflows use Nix for reproducible environments.

## Code Conventions

### Infrastructure
- **Kustomize bases in `infra/k8s/base/`**: Each component has `kustomization.yaml` + manifests
- **Overlays select environment**: `local` for dev, `prod` for production overrides (see `infra/k8s/overlays/`)
- **Helm values in component dirs**: E.g., `infra/k8s/base/nats/values.yaml` configures 3-node JetStream cluster
- **Scripts idempotent**: `bootstrap.sh`, `deploy.sh`, `verify.sh` safe to re-run

### Security
- **All k8s manifests labeled**: `guardyn.io/stage: poc` for easy filtering
- **Port mappings explicit in k3d-config.yaml**: HTTP/HTTPS (80/443), NATS (4222/4223) exposed on localhost
- **Image signatures required in prod**: Use `cosign verify` before deployment

### Testing
- Smoke tests in `verify.sh` check:
  - Pod readiness across all namespaces
  - NATS pub/sub with `natsio/nats-box` ephemeral pod
  - TiKV status via `pd-ctl -u http://localhost:2379 store`
  - ScyllaDB health via `nodetool status`

## Common Tasks

### Adding a New Service
1. Create `infra/k8s/base/<service>/kustomization.yaml`
2. Add Helm values or raw manifests
3. Update `deploy.sh` with deployment case
4. Add to `bootstrap.sh` if installing CRDs
5. Add smoke test to `verify.sh`
6. Update overlays in `infra/k8s/overlays/local/kustomization.yaml`

### Modifying k3d Cluster
- Edit `infra/k3d-config.yaml` for node count, ports, registry config
- Teardown and recreate: `just teardown && just kube-create && just kube-bootstrap`

### Debugging Failed Deployments
```bash
kubectl get pods -A                          # Check all pod statuses
kubectl describe pod <pod> -n <namespace>    # Detailed events
kubectl logs <pod> -n <namespace>            # Container logs
helm list -A                                 # Verify Helm releases
```

### Working with Encrypted Secrets
```bash
sops infra/secrets/data.enc.yaml             # Decrypts in-editor (needs age-key.txt)
kubectl apply -f <(sops -d secrets.enc.yaml) # Decrypt and apply
```

## Troubleshooting

- **SOPS decryption fails**: Ensure `infra/secrets/age-key.txt` exists and matches public key in `.sops.yaml`
- **Pods stuck in `Pending`**: Check `kubectl get pvc` for storage issues—local-path-provisioner may need initialization
- **NATS connection refused**: Verify port-forward `kubectl port-forward -n messaging svc/nats 4222:4222`, then test with `nats-box`
- **TiKV not responding**: TiKV requires PD + TiKV pods running—check logs and connectivity to PD service

## Reference Files
- Product vision: `docs/mvp_discovery.md` (personas, user stories, security requirements)
- Infrastructure guide: `docs/infra_poc.md` (complete setup walkthrough)
- Justfile commands: Run `just --list` for all available tasks
