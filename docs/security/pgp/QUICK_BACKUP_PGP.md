# Quick PGP Backup Commands

⏱️ **Takes 2 minutes**

## 🚀 Fast Backup (Copy-Paste)

```bash
# 1. Export + encrypt private key
gpg --armor --export-secret-keys security@guardyn.io | \
  gpg --symmetric --cipher-algo AES256 --armor \
  > ~/guardyn-security-PRIVATE-$(date +%Y%m%d).asc.gpg

# 2. Upload to cloud storage (Dropbox/Google Drive with 2FA)
# OR save to password manager (1Password/Bitwarden)

# 3. Verify backup works
gpg --decrypt ~/guardyn-security-PRIVATE-*.asc.gpg | gpg --show-keys
```

**Done!** Store the `.asc.gpg` file in 2-3 secure locations.

---

## 📍 Storage Options

**Pick 2-3:**

1. **Password Manager** (1Password/Bitwarden) - Best option
2. **Encrypted cloud** (Google Drive/Dropbox with 2FA)
3. **USB drive** (encrypted with VeraCrypt)
4. **Paper printout** (QR code, store in safe)

---

## 🔓 Restore Backup

```bash
# Decrypt and import
gpg --decrypt ~/guardyn-security-PRIVATE-*.asc.gpg | gpg --import

# Verify
gpg --list-secret-keys security@guardyn.io
```

---

**Full guide:** `infra/secrets/PGP_KEY_BACKUP.md`
