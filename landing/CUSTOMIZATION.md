# Landing Page Customization Guide

## 🎨 Visual Customization

### Change Colors

Every colour is a CSS custom property in `css/theme.css`; the component rules that consume them
- nav, cards, buttons, footer, grid, skip link - are in `css/layout.css`. No page carries a
`<style>` block or a literal hex value of its own. Change a token in `theme.css` and every page
that links it follows.

| Token | Value | Used for |
|---|---|---|
| `--color-primary` | `#53B446` | Button fills, borders, focus rings |
| `--color-primary-strong` | `#3D6B4A` | Green text and icons (6.18:1 on white) |
| `--color-text` | `#1F2937` | Headings and body copy, and the text on primary buttons |
| `--color-text-secondary` | `#6B7280` | Secondary copy (4.83:1 on white) |
| `--color-text-placeholder` | `#9CA3AF` | Placeholders and captions only |
| `--color-surface` | `#FFFFFF` | Cards and bands |
| `--color-border` | `#E5E7EB` | Inputs and card borders |

Keep the contrast notes at the top of `theme.css` true when you change a value. White text on
`#53B446` fails WCAG AA at 2.63:1, which is why primary buttons carry dark text.

### Update Text Content

**Hero Section** (lines ~119-130):
```html
<h1 class="text-6xl md:text-7xl lg:text-8xl font-bold mb-6">
    Your Custom Headline<br/>
    <span class="gradient-text">Your Tagline</span>
</h1>
```

**Features** (lines ~270-350):
- Update emoji icons (🔐, 🏠, 📱, etc.)
- Change feature titles and descriptions
- Add/remove feature cards

### Replace Logo

1. Replace `../media/logo.png` with your logo
2. Update references in `index.html`:
   - Line ~97: Navigation logo
   - Line ~123: Hero section logo
   - Line ~628: Footer logo

Recommended logo sizes:
- Navigation: 40x40px
- Hero: 128x128px (high-res)
- Favicon: 32x32px, 64x64px

### Change Background

The background is a three-corner mesh gradient drawn by `body::before` in `css/theme.css`:

| Token | Value | Corner |
|---|---|---|
| `--color-mesh-mint` | `#CDE8D2` | top-right |
| `--color-mesh-sky` | `#AECDF4` | bottom-left |
| `--color-mesh-violet` | `#E8D5F0` | bottom-right |
| `--color-bg-base` | `#F7F9FB` | base fill |

`index.html` uses no background image; `media/bg.webp` is only referenced by the sub-pages.

### Update Fonts

The font stack is the `--font-sans` token in `css/theme.css`:

```css
--font-sans: Inter, Roboto, system-ui, -apple-system, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
```

No web font is requested. Visitors with Inter or Roboto installed see it; everyone else gets
their platform's sans-serif, and no request leaves the page for a font. To use another face,
self-host it under `landing/fonts/` with an `@font-face` rule in `theme.css` and put its name
first in the token. Do not add a Google Fonts link: it sends every visitor's address to a
third party.

## 📝 Content Sections

### Stats Section (lines ~145-165)

Update numbers:
```html
<div class="text-3xl font-bold text-blue-400">E2EE</div>
<div class="text-sm text-gray-400 mt-2">Signal Protocol</div>
```

Change to your metrics:
```html
<div class="text-3xl font-bold text-blue-400">10K+</div>
<div class="text-sm text-gray-400 mt-2">Active Users</div>
```

### Technology Stack (lines ~386-445)

Add/remove technologies:
```html
<span class="tech-badge bg-white/5 border border-white/10 px-6 py-3 rounded-lg">
    Your Technology
</span>
```

### Beta Form (lines ~448-490)

Customize form fields:
```html
<input type="text" name="name" placeholder="Your name" required>
<input type="email" name="email" placeholder="Email" required>
<select name="role">
    <option value="developer">Developer</option>
    <option value="company">Company</option>
</select>
```

## 🌐 SEO Optimization

### Update Meta Tags (lines ~9-15)

```html
<meta name="description" content="Your custom description (150-160 chars)">
<meta name="keywords" content="your, keywords, here">
<meta property="og:title" content="Your Page Title">
<meta property="og:description" content="Social media preview description">
<meta property="og:image" content="https://guardyn.co/social-preview.png">
```

**Create social preview image:**
- Size: 1200x630px (Facebook/LinkedIn)
- Include logo and tagline
- Save as `social-preview.png` in landing folder

### Update Sitemap (sitemap.xml)

```xml
<url>
    <loc>https://guardyn.co/</loc>
    <lastmod>2025-10-21</lastmod> <!-- Update date -->
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
</url>
```

## 🎬 Animations

### Fade-in timing (lines ~68-85)

Adjust delay for sequential animations:
```css
.delay-100 { animation-delay: 0.1s; }
.delay-200 { animation-delay: 0.2s; }
.delay-300 { animation-delay: 0.3s; } /* Increase for slower reveal */
```

### Hover effects

Customize card hover behavior:
```css
.feature-card:hover {
    transform: translateY(-5px);  /* Change lift distance */
    box-shadow: 0 20px 40px rgba(59, 130, 246, 0.3); /* Glow intensity */
}
```

## 📱 Mobile Responsiveness

The stylesheets are desktop-first and collapse at two plain media queries. There is no
utility-class framework, so there are no `sm:` / `md:` / `lg:` prefixes to use:

- `max-width: 1024px` — `css/crypto.css` only
- `max-width: 768px` — every stylesheet; the single phone breakpoint

Example, from `css/layout.css`:
```css
@media (max-width: 768px) {
    .hero-logo {
        font-size: 3rem;
    }
}
```

## 🔧 Advanced Customizations

### Add New Section

1. Copy existing section structure:
```html
<section class="py-20 bg-gray-900">
    <div class="container mx-auto px-4">
        <h2 class="text-4xl font-bold mb-8">New Section</h2>
        <!-- Your content -->
    </div>
</section>
```

2. Add anchor link in navigation:
```html
<a href="#new-section" class="hover:text-blue-400">New Section</a>
```

### Add Analytics

**Google Analytics** — blocked as written. `_headers` permits no off-origin `script-src`
beyond the Cloudflare beacon, so `googletagmanager.com` will be refused by the browser and
the only sign will be a console error. Adding it means widening the CSP deliberately:
```html
<!-- Add before </head>; also add googletagmanager.com to script-src in _headers -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

**Cloudflare Web Analytics** — nothing to add. Cloudflare Pages injects the beacon itself
once **Analytics** → **Web Analytics** is enabled in the dashboard, and `_headers` already
allows it. Pasting the snippet by hand just duplicates the injected script.

### Add Cookie Consent

```html
<!-- Add before </body> -->
<div id="cookie-banner" class="fixed bottom-0 w-full bg-gray-900 border-t border-white/10 p-4 z-50">
    <div class="container mx-auto flex justify-between items-center">
        <p class="text-sm">We use cookies to improve your experience.</p>
        <button onclick="acceptCookies()" class="btn-primary px-6 py-2 rounded-lg">
            Accept
        </button>
    </div>
</div>

<script>
function acceptCookies() {
    document.getElementById('cookie-banner').style.display = 'none';
    localStorage.setItem('cookies-accepted', 'true');
}
if (localStorage.getItem('cookies-accepted')) {
    document.getElementById('cookie-banner').style.display = 'none';
}
</script>
```

## 🚀 Performance Tips

1. **Optimize Images:**
   ```bash
   # Install ImageMagick
   sudo apt install imagemagick
   
   # Compress PNG
   convert logo.png -quality 85 -strip logo-optimized.png
   
   # Convert to WebP (modern format)
   convert logo.png -quality 80 logo.svg
   ```

2. **Lazy Load Images:**
   ```html
   <img src="image.png" loading="lazy" alt="Description">
   ```

3. **Preload Critical Resources:**
   ```html
   <link rel="preload" href="../media/logo.png" as="image">
   ```

## ✅ Testing Checklist

Before deploying customizations:

- [ ] Test on mobile devices (iOS Safari, Android Chrome)
- [ ] Check all links work
- [ ] Verify form submission
- [ ] Test dark mode (if added)
- [ ] Run Lighthouse audit (score > 90)
- [ ] Check cross-browser compatibility
- [ ] Validate HTML: [validator.w3.org](https://validator.w3.org)
- [ ] Test page speed: [pagespeed.web.dev](https://pagespeed.web.dev)

## 📚 Resources

- **Color Palette Generator**: [coolors.co](https://coolors.co)
- **Free Images**: [unsplash.com](https://unsplash.com)
- **Icon Library**: [heroicons.com](https://heroicons.com)
- **Gradient Generator**: [cssgradient.io](https://cssgradient.io)

## 🆘 Common Issues

**Images not loading:**
- Check file paths: `../media/logo.png`
- Verify files exist in media folder
- Clear browser cache

**Form not submitting:**
- Update Formspree form ID
- Check browser console for errors
- Verify CORS settings

**Styles not applying:**
- Is the right stylesheet linked for this page? Each page loads `css/theme.css` plus its own
- Clear browser cache
- Check for CSS syntax errors

Need help? Open an issue: [github.com/guardyn/guardyn/issues](https://github.com/guardyn/guardyn/issues)
