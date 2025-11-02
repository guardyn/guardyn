# Landing Page Customization Guide

## 🎨 Visual Customization

### Change Colors

Edit `index.html` in the `<style>` section:

```css
/* Primary gradient colors */
.gradient-text {
    background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
    /* Change to your brand colors, e.g.: */
    /* background: linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 100%); */
}

/* Button colors */
.btn-primary {
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    /* Customize button gradient */
}

/* Background overlay */
.hero-bg {
    background: linear-gradient(135deg, rgba(15, 23, 42, 0.95) 0%, rgba(30, 41, 59, 0.95) 100%),
                url('../media/bg.png');
    /* Adjust opacity: change 0.95 to make background more/less visible */
}
```

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

Replace `../media/bg.png` with your background image.

**Recommended specs:**
- Size: 1920x1080px or larger
- Format: PNG or WebP
- File size: < 500KB (optimized)

### Update Fonts

Current font: **Inter** from Google Fonts

To change:

```html
<!-- Line ~37: Replace font -->
<link href="https://fonts.googleapis.com/css2?family=YourFont:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
* {
    font-family: 'YourFont', sans-serif;
}
</style>
```

Popular alternatives:
- `Poppins` - Modern and clean
- `Roboto` - Material Design
- `Montserrat` - Geometric sans-serif
- `Space Grotesk` - Tech-focused

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

All breakpoints use Tailwind CSS:
- `sm:` - 640px+
- `md:` - 768px+
- `lg:` - 1024px+
- `xl:` - 1280px+

Example mobile-first design:
```html
<h1 class="text-4xl md:text-6xl lg:text-8xl">
    <!-- 4xl on mobile, 6xl on tablet, 8xl on desktop -->
</h1>
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

**Google Analytics:**
```html
<!-- Add before </head> -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

**Cloudflare Web Analytics:**
```html
<script defer src='https://static.cloudflareinsights.com/beacon.min.js' 
        data-cf-beacon='{"token": "YOUR_TOKEN"}'></script>
```

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
   convert logo.png -quality 80 logo.webp
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

- **Tailwind CSS Docs**: [tailwindcss.com/docs](https://tailwindcss.com/docs)
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
- Tailwind CDN loaded? (Check line ~36)
- Clear browser cache
- Check for CSS syntax errors

Need help? Open an issue: [github.com/anrysys/guardyn/issues](https://github.com/anrysys/guardyn/issues)
