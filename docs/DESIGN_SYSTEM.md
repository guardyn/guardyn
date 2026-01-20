# Guardyn Design System

> **Version:** 1.0.0  
> **Last Updated:** 2025-01-XX  
> **Platforms:** Desktop (Tauri/SolidJS), Mobile (Flutter)

This document describes the unified design system for Guardyn messenger, ensuring visual and functional parity between desktop and mobile clients.

## Table of Contents

1. [Philosophy](#philosophy)
2. [Color Palette](#color-palette)
3. [Typography](#typography)
4. [Spacing](#spacing)
5. [Shadows & Effects](#shadows--effects)
6. [Theming](#theming)
7. [Components](#components)
8. [Usage Examples](#usage-examples)
9. [File Locations](#file-locations)

---

## Philosophy

Guardyn's design system is built on these principles:

- **Privacy-First Visual Language** — Calm, trustworthy aesthetics that reinforce security
- **Platform Consistency** — Identical design tokens across desktop and mobile
- **Modern Aesthetics** — Glassmorphism, neumorphic shadows, micro-animations
- **Accessibility** — WCAG 2.1 AA compliant contrast ratios
- **Performance** — Optimized assets, variable fonts, efficient shadows

---

## Color Palette

### Brand Colors

| Name                    | Light Mode | Dark Mode | Usage                           |
| ----------------------- | ---------- | --------- | ------------------------------- |
| **Guardyn Green**       | `#22c55e`  | `#22c55e` | Primary actions, brand identity |
| **Guardyn Green Light** | `#4ade80`  | `#4ade80` | Hover states, accents           |
| **Guardyn Green Dark**  | `#16a34a`  | `#16a34a` | Pressed states                  |

### Semantic Colors

| Purpose     | Light Mode | Dark Mode |
| ----------- | ---------- | --------- |
| **Success** | `#22c55e`  | `#4ade80` |
| **Error**   | `#ef4444`  | `#f87171` |
| **Warning** | `#f59e0b`  | `#fbbf24` |
| **Info**    | `#3b82f6`  | `#60a5fa` |

### Chat Backgrounds

These are the signature pastel colors for message areas:

| Theme     | Color             | Hex       |
| --------- | ----------------- | --------- |
| **Light** | Soft mint green   | `#f5fdf8` |
| **Dark**  | Deep forest green | `#0d1f12` |

### Sidebar Colors

| Theme     | Color      | Hex       |
| --------- | ---------- | --------- |
| **Light** | Near white | `#fafafa` |
| **Dark**  | Near black | `#111111` |

### Gray Scale

```
50:  #fafafa    (lightest)
100: #f5f5f5
200: #e5e5e5
300: #d4d4d4
400: #a3a3a3
500: #737373
600: #525252
700: #404040
800: #262626
900: #171717
950: #0a0a0a    (darkest)
```

---

## Typography

### Font Family

**Inter Variable** is our primary typeface, chosen for:

- Excellent readability at all sizes
- Variable font support (weight axis)
- Professional, modern appearance

```css
/* Desktop (CSS) */
font-family:
  "Inter Variable",
  -apple-system,
  BlinkMacSystemFont,
  "Segoe UI",
  sans-serif;
```

```dart
// Mobile (Flutter)
GoogleFonts.inter()
```

### Type Scale

| Name           | Size            | Line Height | Weight | Usage              |
| -------------- | --------------- | ----------- | ------ | ------------------ |
| **Display**    | 36px / 2.25rem  | 1.1         | 700    | Hero sections      |
| **H1**         | 30px / 1.875rem | 1.2         | 700    | Page titles        |
| **H2**         | 24px / 1.5rem   | 1.25        | 600    | Section headers    |
| **H3**         | 20px / 1.25rem  | 1.3         | 600    | Card titles        |
| **H4**         | 18px / 1.125rem | 1.4         | 600    | Subsections        |
| **Body**       | 16px / 1rem     | 1.5         | 400    | Default text       |
| **Body Small** | 14px / 0.875rem | 1.5         | 400    | Secondary text     |
| **Caption**    | 12px / 0.75rem  | 1.4         | 400    | Labels, timestamps |
| **Overline**   | 10px / 0.625rem | 1.6         | 500    | Category labels    |

---

## Spacing

We use a **4px base grid** for all spacing:

| Token | Value | Usage            |
| ----- | ----- | ---------------- |
| `xs`  | 4px   | Tight gaps       |
| `sm`  | 8px   | Icon margins     |
| `md`  | 16px  | Standard padding |
| `lg`  | 24px  | Section gaps     |
| `xl`  | 32px  | Card padding     |
| `2xl` | 48px  | Major sections   |
| `3xl` | 64px  | Page margins     |

### Border Radius

| Token  | Value  | Usage              |
| ------ | ------ | ------------------ |
| `none` | 0      | No rounding        |
| `sm`   | 4px    | Subtle rounding    |
| `md`   | 8px    | Standard cards     |
| `lg`   | 12px   | Larger cards       |
| `xl`   | 16px   | Prominent elements |
| `2xl`  | 24px   | Modals             |
| `full` | 9999px | Pills, avatars     |

---

## Shadows & Effects

### Elevation System

| Level   | CSS Value                            | Usage       |
| ------- | ------------------------------------ | ----------- |
| **sm**  | `0 1px 2px rgba(0,0,0,0.05)`         | Subtle lift |
| **md**  | `0 4px 6px -1px rgba(0,0,0,0.1)`     | Cards       |
| **lg**  | `0 10px 15px -3px rgba(0,0,0,0.1)`   | Dropdowns   |
| **xl**  | `0 20px 25px -5px rgba(0,0,0,0.1)`   | Modals      |
| **2xl** | `0 25px 50px -12px rgba(0,0,0,0.25)` | Dialogs     |

### Glassmorphism

Glass effects create depth while maintaining visibility of background content:

```css
/* Light Theme Glass */
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(12px);
border: 1px solid rgba(255, 255, 255, 0.2);

/* Dark Theme Glass */
background: rgba(23, 23, 23, 0.7);
backdrop-filter: blur(12px);
border: 1px solid rgba(255, 255, 255, 0.1);
```

**Tailwind Classes:**

```html
<div class="glass-card">
  <!-- Content with glassmorphism effect -->
</div>
```

### Neumorphic Shadows

Soft, embossed appearance for interactive elements:

```css
/* Light Theme - Raised */
box-shadow:
  6px 6px 12px rgba(0, 0, 0, 0.1),
  -6px -6px 12px rgba(255, 255, 255, 0.8);

/* Light Theme - Pressed */
box-shadow:
  inset 4px 4px 8px rgba(0, 0, 0, 0.1),
  inset -4px -4px 8px rgba(255, 255, 255, 0.8);
```

**Tailwind Classes:**

```html
<button class="shadow-neumorphic-raised hover:shadow-neumorphic-pressed">Button</button>
```

### Glow Effects

Accent glow for focus states and highlights:

```css
box-shadow: 0 0 20px rgba(34, 197, 94, 0.3); /* Guardyn green glow */
```

### Auth Background Effects (Gradient Orbs)

The authentication pages feature animated gradient orbs that create a dynamic, modern background:

| Orb | Size | Color | Position |
| --- | ---- | ----- | -------- |
| **Orb 1 (Green)** | 500px | `#22c55e` → `#16a34a` | Top-right (-150px, -100px) |
| **Orb 2 (Cyan)** | 400px | `#0ea5e9` → `#06b6d4` | Bottom-left (-100px, -100px) |
| **Orb 3 (Purple)** | 300px | `#8b5cf6` → `#a855f7` | Center (50%, 50%) |

**Visual Properties:**

| Property | Light Theme | Dark Theme |
| -------- | ----------- | ---------- |
| **Opacity** | 0.6 | 0.5 |
| **Blur** | 60px | 80px |
| **Animation** | 20s float | 20s float |

**Desktop CSS:**

```css
.gradient-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(60px);
  opacity: 0.6;
  animation: float 20s ease-in-out infinite;
}

.gradient-orb-1 {
  width: 500px; height: 500px;
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  top: -150px; right: -100px;
}

.gradient-orb-2 {
  width: 400px; height: 400px;
  background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%);
  bottom: -100px; left: -100px;
  animation-delay: -5s;
}

.gradient-orb-3 {
  width: 300px; height: 300px;
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  opacity: 0.4;
  animation-delay: -10s;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  25% { transform: translate(20px, -20px); }
  50% { transform: translate(-10px, 10px); }
  75% { transform: translate(15px, 15px); }
}
```

**Flutter Implementation:**

```dart
class _Orb extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double top, left, right, bottom;
  final Duration animationDelay;

  // Opacity: isDark ? 0.5 : 0.6
  // Blur: isDark ? 80.0 : 60.0
}
```

---

## Theming

### Theme Modes

Guardyn supports three theme modes:

| Mode       | Behavior                                         |
| ---------- | ------------------------------------------------ |
| **Light**  | Fixed light theme                                |
| **Dark**   | Fixed dark theme                                 |
| **System** | Follows OS preference via `prefers-color-scheme` |

### Desktop Implementation

```tsx
// contexts/ThemeContext.tsx
import { ThemeProvider, useTheme } from "../contexts/ThemeContext";

function App() {
  return (
    <ThemeProvider>
      <YourApp />
    </ThemeProvider>
  );
}

function SomeComponent() {
  const { mode, resolvedTheme, setMode, colors } = useTheme();

  return <div style={{ background: colors.background.primary }}>Current theme: {resolvedTheme}</div>;
}
```

### Mobile Implementation

```dart
// Using ThemeBloc
BlocProvider<ThemeBloc>(
  create: (_) => ThemeBloc()..add(const LoadSavedTheme()),
  child: BlocBuilder<ThemeBloc, ThemeState>(
    builder: (context, state) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: state.themeMode,
        home: const HomeScreen(),
      );
    },
  ),
)

// Changing theme
context.read<ThemeBloc>().add(const SetDarkTheme());
```

### Theme Persistence

Both platforms persist theme preference:

- **Desktop:** `localStorage` with key `guardyn-theme-mode`
- **Mobile:** `SharedPreferences` with key `theme_mode`

---

## Components

### Theme Switcher

A 3-way toggle allowing users to switch between Light, Dark, and System modes.

**Desktop:**

```tsx
import { ThemeSwitcher } from "../components/ThemeSwitcher";

<ThemeSwitcher />;
```

**Mobile:**

```dart
import 'package:guardyn_client/shared/widgets/theme_switcher.dart';

ThemeSwitcher()
```

### Glass Card

**Desktop (Tailwind):**

```html
<div class="glass-card rounded-xl p-6">
  <h3>Card Title</h3>
  <p>Card content with glassmorphism effect</p>
</div>
```

**Mobile (Flutter):**

```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).extension<AppColorsExtension>()!.glass.withOpacity(0.7),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  ),
)
```

### Neumorphic Button

**Desktop (Tailwind):**

```html
<button
  class="
  px-6 py-3 
  rounded-xl 
  bg-gray-100 
  shadow-neumorphic-raised 
  hover:shadow-neumorphic-pressed 
  active:shadow-neumorphic-pressed
  transition-shadow duration-200
">
  Click Me
</button>
```

---

## Usage Examples

### Chat Message Area

```tsx
// Desktop
<div class="bg-chat-light dark:bg-chat-dark min-h-screen">
  {messages.map((msg) => (
    <MessageBubble key={msg.id} {...msg} />
  ))}
</div>
```

```dart
// Mobile
Container(
  color: Theme.of(context).extension<AppColorsExtension>()!.chatBackground,
  child: ListView.builder(
    itemBuilder: (context, index) => MessageBubble(messages[index]),
  ),
)
```

### Settings Screen with Theme Switcher

```tsx
// Desktop
function SettingsScreen() {
  return (
    <div class="p-8">
      <h1 class="text-2xl font-semibold mb-6">Settings</h1>

      <section class="glass-card rounded-xl p-6 mb-4">
        <h2 class="text-lg font-medium mb-4">Appearance</h2>
        <div class="flex items-center justify-between">
          <span>Theme</span>
          <ThemeSwitcher />
        </div>
      </section>
    </div>
  );
}
```

```dart
// Mobile
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Theme'),
                  ThemeSwitcher(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## File Locations

### Desktop (client-desktop/)

| File                               | Purpose                                   |
| ---------------------------------- | ----------------------------------------- |
| `src/design/tokens.ts`             | Color palette, typography, spacing tokens |
| `src/design/shadows.ts`            | Elevation, glass, neumorphic shadows      |
| `src/design/index.ts`              | Re-exports all design tokens              |
| `src/contexts/ThemeContext.tsx`    | Theme provider with 3-mode switching      |
| `src/components/ThemeSwitcher.tsx` | Theme toggle component                    |
| `src/styles/index.css`             | Inter font face declarations              |
| `tailwind.config.js`               | Tailwind theme extensions                 |

### Mobile (client-mobile/)

| File                                     | Purpose                        |
| ---------------------------------------- | ------------------------------ |
| `lib/shared/theme/app_colors.dart`       | Color palette matching desktop |
| `lib/shared/theme/app_typography.dart`   | Typography scale               |
| `lib/shared/theme/app_spacing.dart`      | Spacing tokens                 |
| `lib/shared/theme/app_shadows.dart`      | Shadow utilities               |
| `lib/shared/theme/app_theme.dart`        | Complete ThemeData             |
| `lib/shared/theme/theme_bloc.dart`       | Theme state management         |
| `lib/shared/widgets/theme_switcher.dart` | Theme toggle widget            |

---

## Adding New Tokens

When adding new design tokens:

1. **Add to Desktop first** (`src/design/tokens.ts`)
2. **Mirror to Mobile** (`lib/shared/theme/app_colors.dart` or equivalent)
3. **Update Tailwind** if needed (`tailwind.config.js`)
4. **Update this document**

### Token Naming Convention

- Use `camelCase` for JavaScript/TypeScript
- Use `snake_case` for Dart
- Prefix semantic colors with their purpose (e.g., `errorRed`, `successGreen`)

---

## Accessibility

### Contrast Ratios

All text/background combinations meet WCAG 2.1 AA standards:

| Combination            | Ratio  | Requirement |
| ---------------------- | ------ | ----------- |
| Body text on light bg  | 7:1+   | AAA         |
| Body text on dark bg   | 7:1+   | AAA         |
| Large text on light bg | 4.5:1+ | AA          |
| Interactive elements   | 3:1+   | AA          |

### Focus States

All interactive elements have visible focus indicators:

- **Keyboard focus:** 2px solid ring with Guardyn green
- **Focus-visible only:** No focus ring on mouse click

### Motion

Respect user preference for reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Changelog

### v1.0.0 (2025-01-XX)

- Initial design system release
- Color palette with light/dark themes
- Typography scale with Inter Variable
- Spacing and radius tokens
- Glassmorphism and neumorphic effects
- Theme switcher (3-mode)
- Desktop and mobile implementations
