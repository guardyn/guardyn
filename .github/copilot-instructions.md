# Guardyn AI Coding Instructions

## Project Overview

Guardyn is a privacy-focused secure communication platform (MVP/PoC phase) built with:
- **Security-first**: E2EE messaging (X3DH/Double Ratchet/OpenMLS), audio/video calls, group chat with cryptographic verification
- **Infrastructure**: Kubernetes-native (k3d for local dev), FoundationDB + ScyllaDB for data, NATS JetStream for messaging
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

## Architecture

### Component Structure
- `infra/`: Complete Kubernetes stack with kustomize overlays (`local`/`prod`)
  - Namespaces: `platform`, `data`, `messaging`, `observability`, `apps` (see `infra/k8s/base/namespaces/namespaces.yaml`)
  - Data layer: FoundationDB (consensus), ScyllaDB (high-throughput storage)
  - Messaging: NATS JetStream for event streaming
  - Observability: Prometheus + Loki + Tempo + Grafana stack
- `cicd/`: GitHub Actions workflows + reproducible-build action
- `docs/`: `mvp_discovery.md` (product vision), `infra_poc.md` (infrastructure guide)

### Key Design Decisions
- **Kustomize over Helm for base manifests**: Helm only for 3rd-party operators (NATS, FDB, Scylla, Prometheus)
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
just k8s-deploy <svc>  # Deploys service: nats | foundationdb | scylladb | monitoring
just verify-kube       # Smoke tests (pod readiness, NATS pub/sub, FDB/Scylla health)
just teardown          # Destroys cluster
```

**Critical**: Always run `kube-bootstrap` before deploying services. Deployment order matters:
1. Namespaces + cert-manager + Cilium
2. Data stores (foundationdb, scylladb)
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
  - FoundationDB status via `fdbcli --exec "status minimal"`
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
- **FDB operator not responding**: FoundationDB requires 3+ pods for quorum—check node affinity and resource limits

## Reference Files
- Product vision: `docs/mvp_discovery.md` (personas, user stories, security requirements)
- Infrastructure guide: `docs/infra_poc.md` (complete setup walkthrough)
- Justfile commands: Run `just --list` for all available tasks
