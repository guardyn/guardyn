# Secrets Directory

This directory contains SOPS-encrypted secrets for Guardyn infrastructure.

---

## 🔐 What's Here

### Encrypted Secrets (Safe to Commit)

- `*.enc.yaml` - SOPS-encrypted Kubernetes secrets
- `*.enc.asc` - SOPS-encrypted PGP keys (if needed)

### Age Encryption Key (NEVER Commit)

- `age-key.txt` - Master decryption key (gitignored)
- **Public key:** `age1m4zvq4slkpsf9jd8l70hcddg7txke3xykyr4d3pjxlmmdzhe6u4sdgrj4j`

---

## 🚫 What's NOT Here (By Design)

### PGP Private Key

**Location:** Your GPG keyring (`~/.gnupg/`)  
**Reason:** Private keys should NEVER be in Git, even encrypted

**Current key:**

- Fingerprint: `72E2 35E0 C28B 3042 6434 1BF6 AC2A E8F7 04CE 083A`
- Email: `security@guardyn.io`
- Expires: November 17, 2027

**Backup instructions:** See `PGP_KEY_BACKUP.md` in this directory

---

## 🔧 Usage

### Decrypt a Secret

```bash
sops -d infra/secrets/some-secret.enc.yaml
```

### Encrypt a Secret

```bash
sops -e secrets.yaml > secrets.enc.yaml
```

### Edit Encrypted Secret

```bash
sops infra/secrets/some-secret.enc.yaml
```

SOPS will decrypt in your editor, then re-encrypt on save.

---

## 📋 Files in This Directory

| File | Purpose | Safe to Commit? |
|------|---------|-----------------|
| `age-key.txt` | Master decryption key | ❌ NO (gitignored) |
| `*.enc.yaml` | Encrypted Kubernetes secrets | ✅ YES |
| `*.enc.asc` | Encrypted PGP keys | ✅ YES (if needed) |
| `*.asc` (unencrypted) | Raw PGP keys | ❌ NO (gitignored) |
| `*.key` (unencrypted) | Raw keys | ❌ NO (gitignored) |
| `PGP_KEY_BACKUP.md` | Backup instructions | ✅ YES |

---

## ⚙️ Configuration

Encryption rules defined in project root: `.sops.yaml`

```yaml
creation_rules:
  - path_regex: infra/secrets/.*\.enc\.yaml$
    encrypted_regex: '^(data|stringData)$'
    age: ["age1m4zvq4slkpsf9jd8l70hcddg7txke3xykyr4d3pjxlmmdzhe6u4sdgrj4j"]
```

---

## 🆘 Troubleshooting

### "error loading config: no matching creation rules"

- Check `.sops.yaml` has correct `path_regex`
- Ensure filename matches pattern (e.g., `*.enc.yaml`)
- Verify Age key is correct

### "failed to decrypt: no valid decryption key"

- Ensure `age-key.txt` exists in this directory
- Check file permissions: `chmod 600 age-key.txt`
- Verify Age key matches public key in `.sops.yaml`

### "cannot find age-key.txt"

Generate new Age key:

```bash
age-keygen -o infra/secrets/age-key.txt
```

Then update `.sops.yaml` with the new public key.

---

## 📚 Documentation

- **PGP backup guide:** `PGP_KEY_BACKUP.md`
- **Quick backup:** `../_local/QUICK_BACKUP_PGP.md`
- **PGP management:** `../docs/SECURITY_PGP_KEY.md`
- **SOPS usage:** <https://github.com/getsops/sops>

---

## 📝 Legacy Note

Generate AGE key locally and store it in `age-key.txt` (gitignored).  
Use `sops` with `.sops.yaml` at repository root to encrypt `*.enc.yaml` manifests.  
Never commit raw credentials. Reference Vault paths or placeholders when sharing manifests.

