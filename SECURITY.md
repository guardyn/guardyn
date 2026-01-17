# Security Policy

## Responsible Disclosure

Guardyn takes security seriously. We appreciate responsible disclosure of vulnerabilities and welcome contributions from the security research community.

## Reporting a Vulnerability

**Please report security issues to:** <security@guardyn.app>

**DO NOT** open public GitHub issues for security vulnerabilities.

### What to Include

When reporting a vulnerability, please provide:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Any suggested fixes (if available)
- Your contact information for follow-up

## Our Commitment

- ✅ **Response Time**: We will acknowledge your report within 48 hours
- ✅ **Updates**: We will keep you informed throughout the fix process
- ✅ **Credit**: We will credit you in our security acknowledgments (unless you prefer to remain anonymous)
- ✅ **Bug Bounty**: Rewards program planned for post-launch (Q2 2026)

## Scope

Current scope includes:

### In Scope

- Backend services (Rust microservices)
- Cryptographic implementations (guardyn-crypto library)
- Infrastructure configurations (Kubernetes manifests)
- gRPC API definitions
- Mobile client (Flutter - iOS/Android)
- Desktop client (Tauri - Windows/macOS/Linux)
- Build and deployment processes

### Out of Scope

- Social engineering attacks
- Denial of service attacks
- Physical attacks
- Issues in third-party dependencies (please report to the respective maintainers)

## Security Features

Guardyn implements multiple layers of security:

### Cryptography

- **PQXDH Key Exchange**: X3DH + ML-KEM (ML-KEM-768) hybrid for post-quantum resistance
- **Double Ratchet**: Signal Protocol for 1-on-1 messaging with AES-256-GCM
- **OpenMLS**: IETF RFC 9420 for group encryption with AES-256-GCM
- **SFrame**: End-to-end encryption for voice/video calls
- **Sealed Sender**: Metadata protection (hides sender identity from server)
- **PADMÉ Padding**: Traffic analysis protection

### Key Storage

- **iOS**: Secure Enclave for hardware-backed key protection
- **Android**: Android KeyStore for hardware-backed key protection
- **Desktop**: Platform keyring integration

### Infrastructure Security

- **Rate Limiting**: Sliding window algorithm with per-user and per-IP limits
- **TLS Everywhere**: cert-manager with Let's Encrypt
- **Network Policies**: Kubernetes NetworkPolicies for service isolation
- **SOPS/Age**: Encrypted secrets management

### Build Security

- **Memory Safety**: Rust language for backend services
- **Reproducible Builds**: Nix flakes for deterministic builds
- **Supply Chain Security**: SBOM generation with Syft, artifact signing with Cosign
- **Dependency Auditing**: cargo-deny for vulnerability scanning

## Security Testing

We employ multiple security testing methodologies:

- **Penetration Testing**: OWASP ZAP, Nuclei, custom security scanners
- **Dependency Scanning**: Trivy, cargo-deny, cargo-audit
- **Static Analysis**: Clippy with strict lints
- **Container Scanning**: Trivy for Docker images

## Vulnerability Disclosure Timeline

1. **Day 0**: You report the vulnerability
2. **Day 1-2**: We acknowledge receipt and begin investigation
3. **Day 3-7**: We validate the issue and assess severity
4. **Day 8-30**: We develop and test a fix
5. **Day 31-45**: We deploy the fix to production
6. **Day 46-90**: Public disclosure (coordinated with you)

We may adjust this timeline based on the severity and complexity of the issue.

## Security Audits

**Status:** External audit pending

- Penetration testing infrastructure ready
- Security hardening review completed
- Cure53 external audit scheduled for Q1 2026

## Security Acknowledgments

We maintain a Hall of Fame for security researchers who have responsibly disclosed vulnerabilities. Thank you for helping keep Guardyn secure!

### Hall of Fame

_No vulnerabilities reported yet - be the first!_

## Contact

- **Security Email**: <security@guardyn.app>
- **General Contact**: <hello@guardyn.app>
- **Project Repository**: [github.com/guardyn/guardyn](https://github.com/guardyn/guardyn)

## Additional Resources

- [Encryption Architecture](docs/ENCRYPTION_ARCHITECTURE.md)
- [Security Audit Preparation](docs/security/SECURITY_AUDIT.md)
- [Penetration Testing Guide](docs/security/PENETRATION_TESTING.md)
- [Rate Limiting Documentation](docs/security/RATE_LIMITING.md)
- [Sealed Sender Protocol](docs/security/SEALED_SENDER.md)

---

**Thank you for helping make Guardyn more secure!**

_Last updated: January 17, 2026_
