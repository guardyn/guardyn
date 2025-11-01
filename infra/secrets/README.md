# Secrets Handling

- Generate AGE key locally and store it in `age-key.txt` (gitignored).
- Use `sops` with `.sops.yaml` at repository root to encrypt `*.enc.yaml` manifests.
- Never commit raw credentials. Reference Vault paths or placeholders when sharing manifests.
