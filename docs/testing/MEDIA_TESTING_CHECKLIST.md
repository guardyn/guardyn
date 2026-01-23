# Media Feature Manual Testing Checklist

This checklist covers comprehensive manual testing of media functionality across Flutter Mobile and Tauri Desktop clients.

## Prerequisites

- [ ] Backend services running (Docker Compose or k3d cluster)
- [ ] MinIO storage accessible
- [ ] Two test user accounts created
- [ ] Test media files ready (images, videos, audio, documents)

---

## 1. Chat Attachments

### 1.1 Flutter Mobile - 1-on-1 Chat

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Send image | 1. Open chat 2. Tap attachment button 3. Select image 4. Send | Image appears in chat bubble with thumbnail | [ ] |
| Send video | 1. Tap attachment 2. Select video 3. Send | Video appears with play button overlay | [ ] |
| Send audio | 1. Tap attachment 2. Select audio file 3. Send | Audio player appears in bubble | [ ] |
| Send document (PDF) | 1. Tap attachment 2. Select PDF 3. Send | Document card appears with filename | [ ] |
| Send large file (10MB+) | Upload larger file | Progress indicator shown, upload completes | [ ] |
| Cancel upload | Start upload, tap cancel | Upload cancelled, no message sent | [ ] |

### 1.2 Flutter Mobile - Group Chat

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Send image to group | Same as 1-on-1 | Image visible to all group members | [ ] |
| Multiple attachments | Select 3+ files | All files upload and appear | [ ] |

### 1.3 Tauri Desktop - 1-on-1 Chat

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Send image | 1. Click attachment 2. Select file 3. Send | Image appears in chat bubble | [ ] |
| Send document | 1. Click attachment 2. Select PDF 3. Send | Document card with icon appears | [ ] |
| Drag and drop | Drag file into chat area | File uploads and sends | [ ] |
| Upload progress | Send large file | Progress bar shown during upload | [ ] |

### 1.4 Tauri Desktop - Group Chat

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Send image to group | Click attachment, select, send | Image visible to all members | [ ] |
| Multiple files | Select multiple files at once | All files upload successfully | [ ] |

---

## 2. Media Viewer

### 2.1 Flutter Mobile

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Open image fullscreen | Tap image in chat | Fullscreen viewer opens | [ ] |
| Pinch to zoom | Pinch gesture on image | Image zooms in/out smoothly | [ ] |
| Double tap zoom | Double tap on image | Image zooms to fit/original | [ ] |
| Pan zoomed image | Pan while zoomed | Image pans smoothly | [ ] |
| Swipe between images | Swipe left/right | Navigate to next/previous image | [ ] |
| Close viewer | Tap X or swipe down | Viewer closes, return to chat | [ ] |
| Play video | Tap video in chat | Video plays with controls | [ ] |
| Play audio | Tap audio in chat | Audio plays with timeline | [ ] |

### 2.2 Tauri Desktop

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Open image lightbox | Click image in chat | Lightbox overlay opens | [ ] |
| Zoom with scroll | Scroll wheel on image | Image zooms in/out | [ ] |
| Zoom with buttons | Click +/- buttons | Image zooms | [ ] |
| Navigate with arrows | Click left/right arrows | Navigate between images | [ ] |
| Keyboard navigation | Arrow keys | Previous/next image | [ ] |
| Close with ESC | Press Escape key | Lightbox closes | [ ] |
| Close with backdrop | Click outside image | Lightbox closes | [ ] |
| Play video | Click video | Video plays inline | [ ] |
| Download button | Click download icon | File downloads to system | [ ] |

---

## 3. Media Gallery

### 3.1 Flutter Mobile

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Open gallery | 1. Open group info 2. Tap "Media, Links & Docs" | Gallery page opens | [ ] |
| View media tab | Select "Media" tab | Grid of images/videos shown | [ ] |
| View documents tab | Select "Docs" tab | List of documents shown | [ ] |
| View links tab | Select "Links" tab | List of shared links shown | [ ] |
| Tap image in gallery | Tap any image | Opens in fullscreen viewer | [ ] |
| Scroll pagination | Scroll to bottom | More media loads automatically | [ ] |
| Empty state | Open gallery with no media | "No media yet" message shown | [ ] |

### 3.2 Tauri Desktop

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Open gallery | 1. Open group info 2. Click "Media" toggle | Gallery section expands | [ ] |
| View tabs | Click Media/Links/Docs tabs | Content switches | [ ] |
| Grid layout | View Media tab | 3-column grid of thumbnails | [ ] |
| Click thumbnail | Click any image | Opens lightbox viewer | [ ] |
| Document list | View Docs tab | List with icons and sizes | [ ] |
| Infinite scroll | Scroll down | More items load | [ ] |

---

## 4. User Avatar

### 4.1 Flutter Mobile

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| View current avatar | Go to Settings | Current avatar shown (or initials) | [ ] |
| Upload new avatar | 1. Tap avatar 2. Select image 3. Confirm | New avatar uploaded and displayed | [ ] |
| Avatar crop | After selecting image | Crop interface appears | [ ] |
| Remove avatar | Tap "Remove" option | Avatar removed, initials shown | [ ] |
| Avatar in chat list | View conversations | Avatars shown for contacts | [ ] |
| Avatar in chat header | Open conversation | Contact avatar in header | [ ] |
| Avatar in group members | View group info | Member avatars visible | [ ] |

### 4.2 Tauri Desktop

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| View current avatar | Go to Settings | Avatar displayed in profile section | [ ] |
| Hover overlay | Hover over avatar | "Change" overlay appears | [ ] |
| Upload avatar | Click avatar, select file | New avatar uploaded | [ ] |
| Remove avatar | Click "Remove" button | Avatar removed | [ ] |
| Avatar in sidebar | View conversation list | Contact avatars shown | [ ] |
| Avatar in chat | Open conversation | Avatar in header and bubbles | [ ] |

---

## 5. Group Icon

### 5.1 Flutter Mobile

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| View group icon | Open group info | Icon displayed (or default) | [ ] |
| Change icon (admin) | Tap icon, select image | New icon uploaded | [ ] |
| Icon in group list | View group conversations | Icons shown in list | [ ] |
| Non-admin cannot change | Non-admin taps icon | No edit option available | [ ] |

### 5.2 Tauri Desktop

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| View group icon | Open group info | Icon displayed | [ ] |
| Change icon (admin) | Click icon, select file | New icon uploaded | [ ] |
| Icon in sidebar | View group list | Icons visible | [ ] |

---

## 6. Cross-Platform Sync

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Flutter → Desktop image | 1. Send image from Flutter 2. Check Desktop | Image appears on Desktop | [ ] |
| Desktop → Flutter image | 1. Send image from Desktop 2. Check Flutter | Image appears on Flutter | [ ] |
| Flutter → Desktop document | 1. Send PDF from Flutter 2. Check Desktop | Document appears on Desktop | [ ] |
| Desktop → Flutter document | 1. Send PDF from Desktop 2. Check Flutter | Document appears on Flutter | [ ] |
| Avatar sync | 1. Change avatar on Flutter 2. Check Desktop | Avatar updated on Desktop | [ ] |
| Group icon sync | 1. Change icon on Desktop 2. Check Flutter | Icon updated on Flutter | [ ] |
| Media gallery sync | 1. Send media from both 2. Check gallery | All media visible on both | [ ] |

---

## 7. Error Handling

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Network error during upload | Start upload, disconnect network | Error message, retry option | [ ] |
| Invalid file type | Try to upload unsupported file | Error message shown | [ ] |
| File too large | Upload file exceeding limit | Size limit error shown | [ ] |
| Download failure | Attempt download, server down | Error with retry option | [ ] |
| Corrupted file | Upload corrupted image | Appropriate error handling | [ ] |
| Expired download URL | Wait for URL to expire, retry | New URL generated, download works | [ ] |

---

## 8. Performance

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| Large image thumbnail | Send 20MB image | Thumbnail generated quickly | [ ] |
| Multiple concurrent uploads | Send 5 files simultaneously | All upload successfully | [ ] |
| Gallery with 100+ items | Open gallery with many items | Loads smoothly with pagination | [ ] |
| Memory usage | Open many media items | No memory leaks | [ ] |
| Cache efficiency | View same media twice | Second load is instant | [ ] |

---

## Test Sign-Off

| Platform | Tester | Date | Status |
|----------|--------|------|--------|
| Flutter iOS | | | |
| Flutter Android | | | |
| Tauri Windows | | | |
| Tauri macOS | | | |
| Tauri Linux | | | |

## Notes

_Add any issues found during testing:_

1. 
2. 
3. 
