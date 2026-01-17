# Guardyn App Store Submission Guide

> **Phase 5: Launch Preparation**
> **Version:** 1.0
> **Last Updated:** 2026-01-17

## Overview

This guide covers the complete process of submitting Guardyn to:
- Apple App Store (iOS)
- Google Play Store (Android)

## Prerequisites

### Apple Developer Account

- Active Apple Developer Program membership ($99/year)
- App Store Connect access
- Code signing certificates and provisioning profiles
- Xcode 15+ installed

### Google Play Console

- Active Google Play Developer account ($25 one-time)
- Play Console access
- Keystore file for signing

## iOS App Store Submission

### 1. App Store Connect Setup

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in app details:
   - **Platform:** iOS
   - **Name:** Guardyn
   - **Primary Language:** English
   - **Bundle ID:** com.guardyn.app
   - **SKU:** guardyn-ios-v1

### 2. App Information

**Description:**
```
Guardyn is a privacy-first secure messenger with end-to-end encryption.

Key Features:
• End-to-end encrypted messaging (X3DH + Double Ratchet)
• Group chats with MLS encryption
• Voice and video calls with E2EE
• Post-quantum cryptography (ML-KEM hybrid)
• Self-destructing messages
• Hardware-backed key storage (Secure Enclave)
• No metadata collection

Your conversations stay private. Always.

Security Verified:
• Open-source cryptography library
• Regular security audits
• Zero-knowledge architecture
```

**Keywords:**
```
secure messenger, encrypted chat, private messaging, e2ee, end-to-end encryption, secure calls, privacy, signal alternative, encrypted video calls
```

**Categories:**
- Primary: Social Networking
- Secondary: Utilities

**Age Rating:**
- 12+ (Infrequent/Mild Mature/Suggestive Themes - user-generated content)

### 3. Screenshots Requirements

| Device | Size | Count Required |
|--------|------|----------------|
| iPhone 6.7" | 1290 x 2796 | 3-10 |
| iPhone 6.5" | 1284 x 2778 | 3-10 |
| iPhone 5.5" | 1242 x 2208 | 3-10 |
| iPad Pro 12.9" | 2048 x 2732 | 3-10 |

**Screenshot Content:**
1. Chat list with conversations
2. Encrypted chat conversation
3. Voice/video call screen
4. Group chat with encryption indicator
5. Settings with privacy options

### 4. Build Configuration

```bash
cd client

# Update version in pubspec.yaml
# version: 1.0.0+1

# Build release iOS app
flutter build ios --release

# Or use Xcode
open ios/Runner.xcworkspace
```

**Xcode Settings:**
1. Select "Any iOS Device" as target
2. Product → Archive
3. Distribute App → App Store Connect

### 5. Privacy Manifest (iOS 17+)

Create `ios/Runner/PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeContactInfo</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### 6. Export Compliance

For the encryption questionnaire:
- **Does your app use encryption?** Yes
- **Is it exempt from EAR?** Yes (mass market, open-source algorithms)
- **Does it qualify for exemption?** Yes (uses standard encryption: AES, X25519, Ed25519)

Provide Encryption Registration Number (ERN) if required.

### 7. App Review Notes

```
Guardyn is a secure messaging application with end-to-end encryption.

Test Account:
Phone: +1 555-0100
Verification Code: 123456

Notes for Reviewer:
- The app requires another user to test messaging. Please use the demo account above.
- Encryption is performed client-side using open-source algorithms.
- No user data is accessible to Guardyn servers.
- Source code for cryptography: https://github.com/guardyn/guardyn-crypto
```

## Google Play Store Submission

### 1. Google Play Console Setup

1. Log in to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in app details:
   - **App name:** Guardyn
   - **Default language:** English (US)
   - **App or game:** App
   - **Free or paid:** Free

### 2. Store Listing

**Short Description (80 chars):**
```
Secure encrypted messenger with E2EE voice & video calls
```

**Full Description (4000 chars):**
```
Guardyn is a privacy-first secure messenger designed for those who value their privacy.

🔒 END-TO-END ENCRYPTION
Every message, call, and file is encrypted with state-of-the-art cryptography:
• X3DH + Double Ratchet for 1-on-1 chats
• MLS protocol for group encryption
• SFrame for voice and video calls
• Post-quantum cryptography (ML-KEM) for future-proof security

📱 FULL-FEATURED MESSENGER
• Text, voice, and video messages
• Crystal-clear E2EE voice and video calls
• Group chats with cryptographic verification
• File sharing with encryption
• Message reactions, replies, and editing
• Self-destructing messages
• Read receipts and typing indicators

🛡️ PRIVACY BY DESIGN
• Zero metadata collection
• No phone number required (coming soon)
• Hardware-backed key storage
• Sealed sender technology
• No analytics or tracking
• Open-source cryptography

⚡ MODERN EXPERIENCE
• Beautiful, intuitive interface
• Fast message delivery
• Reliable push notifications
• Cross-platform synchronization

🔐 SECURITY VERIFIED
• Regular third-party security audits
• Open-source cryptography library
• Transparent security architecture
• Bug bounty program

Your privacy is not negotiable. Download Guardyn today.
```

### 3. Graphics Assets

| Asset | Size | Format |
|-------|------|--------|
| App icon | 512 x 512 | PNG (32-bit) |
| Feature graphic | 1024 x 500 | PNG/JPEG |
| Phone screenshots | Min 320px, max 3840px | PNG/JPEG |
| Tablet screenshots | Min 320px, max 3840px | PNG/JPEG |

### 4. Build Configuration

```bash
cd client

# Generate keystore (first time only)
keytool -genkey -v -keystore guardyn-release.keystore \
  -alias guardyn -keyalg RSA -keysize 2048 -validity 10000

# Configure key.properties
cat > android/key.properties << EOF
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=guardyn
storeFile=/path/to/guardyn-release.keystore
EOF

# Build release APK
flutter build apk --release

# Or build app bundle (recommended)
flutter build appbundle --release
```

### 5. Content Rating

Complete the IARC questionnaire:
- **Violence:** None
- **Sexual Content:** None
- **Language:** None
- **Controlled Substances:** None
- **User Interaction:** Yes (user-to-user communication)
- **Location Sharing:** No
- **In-app Purchases:** No

Expected rating: **PEGI 3 / Everyone**

### 6. Data Safety Form

| Question | Answer |
|----------|--------|
| Does your app collect or share data? | Yes (user-generated content) |
| Data collected | Name (optional), Phone number, Messages (E2EE) |
| Data encrypted in transit? | Yes |
| Can users request data deletion? | Yes |
| App follows Google Play Families policy? | N/A (not for children) |

**Data types collected:**

- **Personal info (name):** Optional, encrypted, for account personalization
- **Phone number:** Required for registration, not shared
- **Messages:** End-to-end encrypted, server cannot access content
- **Media files:** End-to-end encrypted

### 7. App Signing

Enable Google Play App Signing:
1. Go to Release > Setup > App signing
2. Choose "Use Google-generated key"
3. Upload app bundle with upload key

## Release Checklist

### Pre-submission

- [ ] Version number updated in pubspec.yaml
- [ ] Changelog prepared for this version
- [ ] All screenshots updated
- [ ] App icons are correct resolution
- [ ] Privacy policy URL is live
- [ ] Terms of service URL is live
- [ ] Support email is valid
- [ ] Test accounts are working

### iOS Specific

- [ ] PrivacyInfo.xcprivacy is present
- [ ] Export compliance answered
- [ ] App Review notes provided
- [ ] TestFlight testing completed
- [ ] Crash-free rate > 99%

### Android Specific

- [ ] Data safety form completed
- [ ] Content rating obtained
- [ ] App bundle signed correctly
- [ ] Target API level is current (34+)
- [ ] Internal testing completed

### Post-submission

- [ ] Monitor review status
- [ ] Respond to reviewer questions within 24h
- [ ] Prepare marketing materials
- [ ] Plan launch announcement

## Common Rejection Reasons

### iOS

1. **Guideline 2.1 - Performance: App Completeness**
   - Ensure all features work as described
   - Provide clear test instructions

2. **Guideline 5.1.1 - Data Collection and Storage**
   - Update privacy policy
   - Complete App Privacy details in App Store Connect

3. **Guideline 4.0 - Design**
   - Follow Human Interface Guidelines
   - Ensure accessibility compliance

### Android

1. **Impersonation**
   - Use unique branding
   - Don't imply official status

2. **Incomplete Content**
   - All features must be functional
   - No placeholder content

3. **Privacy Policy Missing**
   - Must be accessible from store listing
   - Must cover all data collection

## Timeline

| Stage | iOS | Android |
|-------|-----|---------|
| Initial review | 24-48 hours | 2-7 days |
| Rejection appeal | 1-3 days | 1-5 days |
| Update review | 24-48 hours | 1-3 days |

## Support Resources

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policy Center](https://play.google.com/about/developer-content-policy/)
- [Flutter deployment docs](https://docs.flutter.dev/deployment)
