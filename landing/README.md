# Guardyn Landing Page

Modern, responsive landing page for Guardyn secure messenger.

## 🚀 Quick Start

### Local Development

Simply open `index.html` in your browser:

```bash
cd landing
# Option 1: Direct open
open index.html  # macOS
xdg-open index.html  # Linux

# Option 2: Simple HTTP server
python3 -m http.server 8080
# or
npx serve .
```

Visit: `http://localhost:8080`

## 📦 Deploy to Cloudflare Pages

### Option 1: Via Dashboard (Recommended)

1. **Login to Cloudflare Dashboard**

   - Go to [dash.cloudflare.com](https://dash.cloudflare.com)
   - Navigate to **Workers & Pages**

2. **Create New Project**

   - Click **Create application** → **Pages**
   - Select **Connect to Git**
   - Choose your GitHub repository: `guardyn/guardyn`

3. **Configure Build Settings**

   ```
   Project name: guardyn-landing
   Production branch: main
   Build command: (leave empty for static site)
   Build output directory: /landing
   Root directory: /
   ```

4. **Deploy**

   - Click **Save and Deploy**
   - Wait 1-2 minutes for build

5. **Add Custom Domain**
   - Go to project **Settings** → **Custom domains**
   - Click **Add custom domain**
   - Enter `guardyn.co`
   - If DNS on Cloudflare: automatic setup ✅
   - If DNS elsewhere: add CNAME record manually

### Option 2: Via Wrangler CLI

```bash
# Install Wrangler
npm install -g wrangler

# Login
wrangler login

# Deploy
cd landing
wrangler pages deploy . --project-name=guardyn-landing

# Add custom domain via dashboard
```

## 🔧 Configuration

### Update Form Submission

Replace Formspree form ID in `index.html`:

```html
<!-- Line ~430 -->
<form id="beta-form" action="https://formspree.io/f/YOUR_FORM_ID" method="POST"></form>
```

**Get Formspree ID:**

1. Sign up at [formspree.io](https://formspree.io)
2. Create new form
3. Copy form ID
4. Replace in HTML

### Update Social Links

Update links in `index.html`:

- GitHub: `https://github.com/guardyn` (line ~115, ~600)
- LinkedIn: `https://linkedin.com/company/guardyn` (line ~604)
- Email: `hello@guardyn.app` (line ~612)

### Add Cloudflare Web Analytics

1. Enable in Cloudflare dashboard: **Analytics** → **Web Analytics**
2. Copy tracking code
3. Add to `<head>` section:

```html
<script defer src="https://static.cloudflareinsights.com/beacon.min.js" data-cf-beacon='{"token": "YOUR_TOKEN"}'></script>
```

## 📁 Structure

```
landing/
├── index.html          # Main landing page
├── _headers           # Security headers (Cloudflare)
├── _redirects         # URL redirects (www → non-www)
├── robots.txt         # SEO crawling instructions
├── sitemap.xml        # SEO sitemap
└── README.md          # This file
```

## 🎨 Assets

Landing page uses assets from `../media/`:

- `logo.png` - Guardyn logo
- `bg.png` - Background image
- `logo_and_bg.png` - Combined asset

## 🔒 Security Features

- CSP headers configured
- XSS protection enabled
- Frame-Options: DENY
- Referrer-Policy: strict-origin
- HTTPS enforced
- No external dependencies (except Tailwind CDN)

## 🌐 DNS Configuration

### If DNS on Cloudflare

Custom domain setup is automatic in Pages dashboard.

### If DNS elsewhere

Add CNAME record:

```
Type: CNAME
Name: @  (or guardyn.co)
Value: guardyn-landing.pages.dev
TTL: Auto

Type: CNAME
Name: www
Value: guardyn-landing.pages.dev
TTL: Auto
```

## 📊 Performance

- **Lighthouse Score Target**: 95+
- **First Contentful Paint**: < 1.5s
- **Time to Interactive**: < 3s
- **Total Bundle Size**: < 100KB (static HTML)

## 🔄 Updates

Landing page automatically rebuilds on push to `main` branch.

### Manual Trigger

1. Go to Cloudflare Pages dashboard
2. Select project
3. Click **Create deployment**

## ✅ Checklist

Before going live:

- [ ] Update Formspree form ID
- [ ] Update all social media links
- [ ] Add custom domain in Cloudflare
- [ ] Enable Web Analytics
- [ ] Test on mobile devices
- [ ] Check Lighthouse scores
- [ ] Verify HTTPS working
- [ ] Test beta signup form
- [ ] Check all anchor links work
- [ ] Verify images load correctly

## 📝 SEO Optimization

Included:

- ✅ Meta descriptions
- ✅ Open Graph tags
- ✅ Twitter Card tags
- ✅ Sitemap.xml
- ✅ Robots.txt
- ✅ Semantic HTML5
- ✅ Mobile responsive
- ✅ Fast loading (< 2s)

## 🐛 Troubleshooting

**Images not loading?**

- Check paths in HTML (should be `../media/logo.png`)
- Verify files exist in `../media/` directory

**Form not working?**

- Update Formspree form ID
- Check network tab for CORS errors
- Verify Formspree account is active

**Custom domain not working?**

- Wait 5-10 minutes for DNS propagation
- Check DNS records with `dig guardyn.co`
- Verify SSL certificate issued

## 📞 Support

- GitHub: [github.com/guardyn/guardyn](https://github.com/guardyn/guardyn)
- Issues: [github.com/guardyn/guardyn/issues](https://github.com/guardyn/guardyn/issues)

---

**Built with** ❤️ **for privacy and security**
