# Guardyn Security PGP Key Management

**Created**: November 17, 2025  
**Purpose**: Encrypted communication for security vulnerability reports

---

## 🔐 Key Information

**Key ID**: `72E235E0C28B304264341BF6AC2AE8F704CE083A`  
**Fingerprint**: `72E2 35E0 C28B 3042 6434 1BF6 AC2A E8F7 04CE 083A`  
**Email**: security@guardyn.io  
**Algorithm**: RSA 4096-bit  
**Created**: 2025-11-17  
**Expires**: 2027-11-17 (2 years)

---

## 📍 Public Key Locations

- **Web**: https://guardyn.co/.well-known/pgp-key.txt
- **Local**: `landing/.well-known/pgp-key.txt`
- **Security.txt**: https://guardyn.co/.well-known/security.txt

---

## 🔑 Private Key Storage

**The private key is stored in your GPG keyring**:

```bash
gpg --list-secret-keys security@guardyn.io
```

**⚠️ CRITICAL**: The private key is stored ONLY in:

1. **Your local GPG keyring** (`~/.gnupg/`)
2. **Backup** (create encrypted backup separately)

**DO NOT commit private key to Git!**

---

## 💾 Backup Instructions

### Create Encrypted Backup

```bash
# Export private key
gpg --armor --export-secret-keys security@guardyn.io > guardyn-security-PRIVATE.asc

# Encrypt with password
gpg --symmetric --cipher-algo AES256 guardyn-security-PRIVATE.asc

# Store guardyn-security-PRIVATE.asc.gpg in secure location:
# - Password manager (1Password, Bitwarden)
# - Encrypted USB drive
# - Cloud storage with encryption

# Delete unencrypted file
shred -u guardyn-security-PRIVATE.asc
```

### Restore from Backup

```bash
# Decrypt backup
gpg --decrypt guardyn-security-PRIVATE.asc.gpg > guardyn-security-PRIVATE.asc

# Import to GPG
gpg --import guardyn-security-PRIVATE.asc

# Clean up
shred -u guardyn-security-PRIVATE.asc
```

---

## 📧 Using the Key

### Decrypt Incoming Security Reports

```bash
# Researchers will send encrypted reports to security@guardyn.io
gpg --decrypt encrypted-report.asc
```

### Encrypt Responses

```bash
# Get researcher's public key
gpg --keyserver keys.openpgp.org --recv-keys RESEARCHER_KEY_ID

# Encrypt response
echo "Thank you for the report..." | gpg --encrypt --armor --recipient RESEARCHER_EMAIL > response.asc
```

---

## 🔄 Key Rotation

**Current key expires**: November 17, 2027

**Rotation schedule**:

- **3 months before expiration**: Generate new key
- **2 months before**: Update security.txt with new key
- **1 month before**: Send transition notice to security community
- **On expiration**: Revoke old key, make new key primary

### Extend Key Expiration

```bash
# Edit key
gpg --edit-key security@guardyn.io

# In GPG prompt:
gpg> expire
# Select new expiration (e.g., 2y)
gpg> save

# Re-export public key
gpg --armor --export security@guardyn.io > landing/.well-known/pgp-key.txt
```

---

## 🚨 Key Compromise Procedure

**If private key is compromised**:

1. **Revoke immediately**:

   ```bash
   gpg --gen-revoke security@guardyn.io > revocation.asc
   gpg --import revocation.asc
   gpg --send-keys 72E235E0C28B304264341BF6AC2AE8F704CE083A
   ```

2. **Update security.txt**:

   - Add warning about compromised key
   - Remove encryption link temporarily

3. **Generate new key**:

   ```bash
   gpg --full-generate-key
   # Follow prompts with NEW email or different parameters
   ```

4. **Notify security community**:
   - Post on guardyn.co
   - Email to known security researchers
   - GitHub Security Advisory

---

## 🔍 Verifying Key Authenticity

**For security researchers**:

1. **Check fingerprint** on multiple channels:

   - Website: https://guardyn.co/.well-known/security.txt
   - GitHub: https://github.com/guardyn/guardyn/blob/main/docs/CONTACT.md
   - Social media: Twitter @guardyn_io

2. **Expected fingerprint**:

   ```
   72E2 35E0 C28B 3042 6434 1BF6 AC2A E8F7 04CE 083A
   ```

3. **Verify after import**:
   ```bash
   gpg --fingerprint security@guardyn.io
   ```

---

## 📋 Maintenance Checklist

- [ ] **Monthly**: Check key expiration date
- [ ] **Quarterly**: Test encryption/decryption
- [ ] **Yearly**: Create fresh encrypted backup
- [ ] **Before expiration**: Start rotation process

---

## 🔗 Related Documents

- [CONTACT.md](../../docs/CONTACT.md) - All contact information
- [security.txt](../landing/.well-known/security.txt) - RFC 9116 security contact
- [pgp-key.txt](../landing/.well-known/pgp-key.txt) - Public PGP key

---

**Questions?** Email admin@guardyn.io
