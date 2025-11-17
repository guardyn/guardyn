# PGP Private Key: Current Status

**Generated:** November 17, 2025  
**Status:** ✅ Key exists in GPG keyring  
**Repository Storage:** ❌ NOT stored (by design - security best practice)

---

## 📋 Summary

### ✅ What's Done

1. **PGP key generated**
   - Key ID: `72E235E0C28B304264341BF6AC2AE8F704CE083A`
   - Fingerprint: `72E2 35E0 C28B 3042 6434 1BF6 AC2A E8F7 04CE 083A`
   - Algorithm: RSA 4096-bit
   - Expires: November 17, 2027

2. **Public key deployed**
   - File: `landing/.well-known/pgp-key.txt` (1672 bytes)
   - URL: `https://guardyn.co/.well-known/pgp-key.txt` (after deployment)

3. **Security.txt created**
   - File: `landing/.well-known/security.txt`
   - RFC 9116 compliant
   - References PGP key for encryption

4. **Documentation created**
   - `docs/SECURITY_PGP_KEY.md` - Full management guide
   - `infra/secrets/PGP_KEY_BACKUP.md` - Detailed backup instructions
   - `_local/QUICK_BACKUP_PGP.md` - Fast backup commands

5. **Repository protected**
   - `.gitignore` rules added for `*.asc`, `*.key` files
   - Private keys excluded from version control

---

## ⚠️ What's NOT Done (Intentionally)

### Private Key NOT in Repository

**Why the file `infra/secrets/guardyn-security-private-key.enc.asc` is empty/missing:**

1. **SOPS encryption failed** - Configuration didn't support `*.enc.asc` files
2. **Decision made** - Keep private keys OUT of Git entirely (security best practice)
3. **Git storage is risky** - Even encrypted keys in Git history create attack surface

### Where Private Key Lives

**Current location:** Your local GPG keyring (`~/.gnupg/`)

Verify with:

```bash
gpg --list-secret-keys security@guardyn.io
```

Expected output:

```text
sec   rsa4096 2025-11-17 [SC] [expires: 2027-11-17]
      72E235E0C28B304264341BF6AC2AE8F704CE083A
uid           [ultimate] Guardyn Security Team <security@guardyn.io>
```

---

## 🚨 CRITICAL: You Need to Create Backup

**Problem:** Private key exists ONLY in `~/.gnupg/` directory

**Risk:** If you lose access to this machine or GPG directory gets corrupted, you CANNOT decrypt security reports

**Solution:** Create encrypted backup NOW

### Quick Backup (2 minutes)

```bash
# Option 1: Password-encrypted (recommended)
gpg --armor --export-secret-keys security@guardyn.io | \
  gpg --symmetric --cipher-algo AES256 --armor \
  > ~/guardyn-security-PRIVATE-$(date +%Y%m%d).asc.gpg

# Option 2: Age-encrypted (alternative)
gpg --armor --export-secret-keys security@guardyn.io | \
  age -r age1m4zvq4slkpsf9jd8l70hcddg7txke3xykyr4d3pjxlmmdzhe6u4sdgrj4j \
  > ~/guardyn-security-PRIVATE-$(date +%Y%m%d).asc.age
```

### Store in 2+ Locations

1. **Password manager** (1Password, Bitwarden) - BEST
2. **Encrypted cloud** (Google Drive/Dropbox with 2FA)
3. **USB drive** (VeraCrypt encrypted partition)

**See:** `_local/QUICK_BACKUP_PGP.md` for full instructions

---

## 🔒 Why NOT in Git Repository?

Even with SOPS encryption:

- **Git history is permanent** - Can't truly delete
- **Encryption can break** - Future quantum computers, algorithm weaknesses
- **Access control difficult** - Anyone with repo access has encrypted key
- **Rotation complex** - Old keys stay in history forever
- **Attack surface** - More places = more risk

**Industry standard:** Private keys in password managers, hardware tokens, or offline storage only.

---

## ✅ Pre-Launch Checklist

Before November 18 launch:

- [x] Generate PGP key
- [x] Export public key to `.well-known/pgp-key.txt`
- [x] Create `security.txt`
- [x] Document backup procedures
- [ ] **CREATE PRIVATE KEY BACKUP** ⚠️ (YOU MUST DO THIS)
- [ ] Store backup in 2+ secure locations
- [ ] Test backup restore procedure
- [ ] Deploy landing page with `.well-known/` directory
- [ ] Verify `https://guardyn.co/.well-known/security.txt` works

---

## 📚 References

- **Full backup guide:** `infra/secrets/PGP_KEY_BACKUP.md`
- **Quick commands:** `_local/QUICK_BACKUP_PGP.md`
- **Key management:** `docs/SECURITY_PGP_KEY.md`
- **Pre-launch tasks:** `_local/PRE_LAUNCH_CHECKLIST.md`

---

## 🆘 What If I Lose the Private Key?

1. Generate new key (see `docs/SECURITY_PGP_KEY.md`)
2. Update `landing/.well-known/pgp-key.txt`
3. Update `landing/.well-known/security.txt`
4. Announce key change publicly (GitHub, Twitter, website)
5. Security researchers won't be able to decrypt old reports

**Prevention:** Create backup NOW before launch.

---

**Action Required:** Run backup commands from `_local/QUICK_BACKUP_PGP.md` (takes 2 minutes)
