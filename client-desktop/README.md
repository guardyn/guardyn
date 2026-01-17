# Guardyn Desktop Client

Tauri 2.2 desktop application with SolidJS frontend for Windows, macOS, and Linux.

## Architecture

```
client-desktop/
├── src/                    # SolidJS frontend
│   ├── components/         # Reusable UI components
│   ├── pages/              # Page components
│   ├── styles/             # TailwindCSS styles
│   └── types/              # TypeScript interfaces
├── src-tauri/              # Rust backend
│   ├── src/
│   │   ├── commands/       # Tauri commands (IPC)
│   │   ├── main.rs         # Entry point
│   │   ├── lib.rs          # Library exports
│   │   ├── state.rs        # Application state
│   │   └── tray.rs         # System tray
│   └── Cargo.toml          # Rust dependencies
└── package.json            # Node.js dependencies
```

## Prerequisites

- **Rust** 1.75+ (via rustup)
- **Node.js** 18+ (LTS recommended)
- **System dependencies** (for Tauri):
  - Linux: `webkit2gtk`, `libgtk-3-dev`, `libappindicator3-dev`
  - macOS: Xcode Command Line Tools
  - Windows: WebView2 (bundled with Windows 11)

## Quick Start

```bash
# Install dependencies
./scripts/setup.sh

# Start development server
npm run tauri dev

# Build for production
npm run tauri build
```

## Development Commands

| Command               | Description                           |
| --------------------- | ------------------------------------- |
| `npm run dev`         | Start Vite dev server (frontend only) |
| `npm run tauri dev`   | Start Tauri in development mode       |
| `npm run tauri build` | Build production binaries             |
| `npm run build`       | Build frontend assets                 |
| `npm run lint`        | Run ESLint                            |

## Features

### Security

- End-to-end encryption using `guardyn-crypto`
- PQXDH (Post-Quantum X3DH) key exchange
- Double Ratchet protocol for message encryption
- Local secure key storage

### Desktop Integration

- System tray support
- Native notifications
- Global keyboard shortcuts
- Auto-updates (production)

## Cryptography

The desktop client uses the unified `guardyn-crypto` crate for all cryptographic operations:

- **X3DH/PQXDH**: Initial key exchange with post-quantum security
- **Double Ratchet**: Forward secrecy for messages
- **PADMÉ padding**: Metadata-protected message sizes
- **MLS**: Group messaging protocol

All crypto operations run in native Rust, not in JavaScript.

## Build Targets

| Platform | Format              | Notes                                    |
| -------- | ------------------- | ---------------------------------------- |
| Windows  | `.msi`, `.exe`      | Requires WebView2                        |
| macOS    | `.dmg`, `.app`      | Universal binary (Intel + Apple Silicon) |
| Linux    | `.deb`, `.AppImage` | Requires webkit2gtk                      |

## Configuration

### Environment Variables

```env
VITE_API_URL=http://localhost:8080
VITE_WS_URL=ws://localhost:8081
```

### Tauri Configuration

See `src-tauri/tauri.conf.json` for:

- Window settings
- Security policies
- Update endpoints
- Build targets

## Troubleshooting

### Linux: Missing webkit2gtk

```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev libgtk-3-dev libappindicator3-dev

# Fedora
sudo dnf install webkit2gtk4.1-devel gtk3-devel libappindicator-gtk3-devel
```

### macOS: Xcode tools

```bash
xcode-select --install
```

### Windows: WebView2

Download from [Microsoft](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)

## License

GNU Affero General Public License v3.0 - see [LICENSE](../LICENSE)
