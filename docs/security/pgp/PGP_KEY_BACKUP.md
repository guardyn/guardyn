# PGP Private Key Backup Instructions

**⚠️ CRITICAL: The PGP private key is NOT stored in this repository for security reasons.**

The private key exists only in your local GPG keyring (`~/.gnupg/`).

---

## 🔒 Why Not in Git?

Even with SOPS encryption, storing private keys in Git repositories is a security risk:

- Git history is permanent
- Encryption can be broken in the future
- Access control is difficult with Git
- Rotation becomes complex

**Best practice**: Keep private keys in secure, offline storage only.

---

## 💾 Creating a Backup

### Option 1: Encrypted with Password (Recommended)

```bash
# Export private key
gpg --armor --export-secret-keys security@guardyn.io > guardyn-security-PRIVATE.asc

# Encrypt with strong password
gpg --symmetric --cipher-algo AES256 guardyn-security-PRIVATE.asc

# This creates: guardyn-security-PRIVATE.asc.gpg

# Delete unencrypted file
shred -u guardyn-security-PRIVATE.asc

# Store guardyn-security-PRIVATE.asc.gpg in:
# - Password manager (1Password, Bitwarden, etc.)
# - Encrypted USB drive
# - Secure cloud storage (Dropbox/Google Drive with 2FA)
```

### Option 2: Encrypted with Age (Alternative)

```bash
# Export private key
gpg --armor --export-secret-keys security@guardyn.io > guardyn-security-PRIVATE.asc

# Encrypt with Age key
age -r age1m4zvq4slkpsf9jd8l70hcddg7txke3xykyr4d3pjxlmmdzhe6u4sdgrj4j \
  guardyn-security-PRIVATE.asc > guardyn-security-PRIVATE.asc.age

# Delete unencrypted file
shred -u guardyn-security-PRIVATE.asc

# Store guardyn-security-PRIVATE.asc.age securely
```

---

## 🔓 Restoring from Backup

### From Password-Encrypted Backup

```bash
# Decrypt backup
gpg --decrypt guardyn-security-PRIVATE.asc.gpg > guardyn-security-PRIVATE.asc

# Import to GPG
gpg --import guardyn-security-PRIVATE.asc

# Clean up
shred -u guardyn-security-PRIVATE.asc
```

### From Age-Encrypted Backup

```bash
# Decrypt with Age key
age -d -i infra/secrets/age-key.txt \
  guardyn-security-PRIVATE.asc.age > guardyn-security-PRIVATE.asc

# Import to GPG
gpg --import guardyn-security-PRIVATE.asc

# Clean up
shred -u guardyn-security-PRIVATE.asc
```

---

## 📍 Backup Storage Locations

### Recommended (Pick 2-3):

1. **Password Manager** (Best)

   - 1Password / Bitwarden / LastPass
   - Attach file to secure note
   - Enable 2FA on password manager

2. **Encrypted USB Drive**

   - VeraCrypt encrypted partition
   - Store in physical safe
   - Keep offline

3. **Secure Cloud Storage**

   - Google Drive / Dropbox with 2FA
   - Encrypt file BEFORE upload
   - Use strong password

4. **Hardware Security Key** (Advanced)
   - YubiKey with GPG support
   - Store key on hardware token
   - Requires physical access

---

## 🚨 Emergency Recovery

If you lose access to the private key:

1. **Generate new key** (see docs/SECURITY_PGP_KEY.md)
2. **Update security.txt** with new key
3. **Notify security community**:
   - GitHub Security Advisory
   - guardyn.co announcement
   - Twitter/X post

---

## ✅ Backup Checklist

- [ ] Private key exported
- [ ] File encrypted with strong password/key
- [ ] Unencrypted file securely deleted (`shred -u`)
- [ ] Backup stored in 2+ secure locations
- [ ] Backup locations documented (offline)
- [ ] Backup tested (decrypt + import + verify)
- [ ] Calendar reminder: Test backup every 6 months

---

## 📝 Current Key Information

- **Email**: security@guardyn.io
- **Fingerprint**: `72E2 35E0 C28B 3042 6434 1BF6 AC2A E8F7 04CE 083A`
- **Created**: November 17, 2025
- **Expires**: November 17, 2027
- **Location**: Your GPG keyring (`~/.gnupg/`)

---

## 🔐 Verifying Key is in Keyring

```bash
gpg --list-secret-keys security@guardyn.io
```

Expected output:

```
sec   rsa4096 2025-11-17 [SC] [expires: 2027-11-17]
      72E235E0C28B304264341BF6AC2AE8F704CE083A
uid           [ultimate] Guardyn Security Team <security@guardyn.io>
```

If you don't see this, you need to restore from backup!

---

**Questions?** See docs/SECURITY_PGP_KEY.md for full key management guide.
