# Tauri Application Icons

This directory should contain the following icon files for the Tauri application:

## Required Icons

### Windows

- `icon.ico` - 256x256 ICO file

### macOS

- `icon.icns` - ICNS file with multiple resolutions
- `icon.png` - 512x512 PNG

### Linux

- `icon.png` - 512x512 PNG
- `32x32.png` - 32x32 PNG
- `128x128.png` - 128x128 PNG
- `128x128@2x.png` - 256x256 PNG (HiDPI)

## Generating Icons

Use Tauri's icon generator:

```bash
cd client-desktop
cargo tauri icon path/to/source-icon.png
```

Or use an online tool like https://icon.kitchen/ with the Guardyn logo.

## Placeholder

For development, you can use a simple placeholder icon. The main Guardyn logo should be used for production builds.
