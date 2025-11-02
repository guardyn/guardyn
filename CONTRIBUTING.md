# Contributing to Guardyn

Thank you for your interest in contributing to Guardyn! This document provides guidelines and best practices for contributing to the project.

## Domain-Agnostic Architecture

**Guardyn is 100% domain-agnostic** - it works with any domain you choose:

- ✅ **Never hardcode domains** - Always use the `DOMAIN` environment variable
- ✅ **Single source of truth** - Configure domain only in `.env` file
- ✅ **Use generic examples** - In documentation, use `yourdomain.com` not specific domains
- ✅ **Test with any domain** - Your changes should work regardless of domain name

## Getting Started

Please refer to the main [README.md](README.md) for setup instructions and project overview.

For detailed coding guidelines and AI-assisted development instructions, see [.github/copilot-instructions.md](.github/copilot-instructions.md).

## Code of Conduct

We expect all contributors to be respectful and professional. Please follow the language policy and coding conventions outlined in the project documentation.
