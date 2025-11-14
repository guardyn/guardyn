# Security Policy

## Responsible Disclosure

Guardyn takes security seriously. We appreciate responsible disclosure of vulnerabilities and welcome contributions from the security research community.

## Reporting a Vulnerability

**Please report security issues to:** security@guardyn.app

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
- ✅ **Bug Bounty**: Rewards program planned for post-launch (Q2 2025)

## Scope

Current scope includes:

### In Scope

- Backend services (Rust microservices)
- Cryptographic implementations (X3DH, Double Ratchet, OpenMLS)
- Infrastructure configurations (Kubernetes manifests)
- gRPC API definitions
- Client applications (when released)
- Build and deployment processes

### Out of Scope

- Social engineering attacks
- Denial of service attacks
- Physical attacks
- Issues in third-party dependencies (please report to the respective maintainers)

## Security Features

Guardyn implements multiple layers of security:

- **End-to-End Encryption**: Signal Protocol (Double Ratchet) for 1-on-1, OpenMLS for groups
- **Post-Quantum Readiness**: Kyber + ECDH hybrid key exchange
- **Formal Verification**: TLA+ specifications, ProVerif cryptographic proofs
- **Reproducible Builds**: Nix flakes for deterministic builds
- **Supply Chain Security**: SBOM generation, artifact signing with Sigstore/Cosign
- **Memory Safety**: Rust language for backend services

## Vulnerability Disclosure Timeline

1. **Day 0**: You report the vulnerability
2. **Day 1-2**: We acknowledge receipt and begin investigation
3. **Day 3-7**: We validate the issue and assess severity
4. **Day 8-30**: We develop and test a fix
5. **Day 31-45**: We deploy the fix to production
6. **Day 46-90**: Public disclosure (coordinated with you)

We may adjust this timeline based on the severity and complexity of the issue.

## Security Acknowledgments

We maintain a Hall of Fame for security researchers who have responsibly disclosed vulnerabilities. Thank you for helping keep Guardyn secure!

### Hall of Fame

_No vulnerabilities reported yet - be the first!_

## Contact

- **Security Email**: security@guardyn.app
- **General Contact**: hello@guardyn.app
- **Project Repository**: https://github.com/guardyn/guardyn

## Additional Resources

- [Developer Documentation](https://docs.guardyn.io/developers)
- [Architecture Documentation](docs/mvp_discovery.md)
- [Cryptographic Specifications](docs/CRYPTO_SPEC.md)
- [Contributing Guidelines](CONTRIBUTING.md)

---

**Thank you for helping make Guardyn more secure!**

_Last updated: November 14, 2025_
