# 🚀 Quick Start - Guardyn Landing Page

## Fastest Way to Deploy (5 minutes)

### Step 1: Test Locally
```bash
cd landing
python3 -m http.server 8080
# Visit: http://localhost:8080
```

### Step 2: Deploy to Cloudflare Pages

**Via Dashboard** (No CLI needed):

1. Login: [dash.cloudflare.com](https://dash.cloudflare.com)
2. **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
3. Select repository: `anrysys/guardyn`
4. Settings:
   - Build output: `/landing`
   - Build command: (leave empty)
5. **Save and Deploy** ✅

### Step 3: Add Custom Domain

1. In Pages project → **Custom domains**
2. Add: `guardyn.app`
3. Done! (Automatic if DNS on Cloudflare)

### Step 4: Setup Beta Form

**Quick option - Formspree:**

1. Sign up: [formspree.io](https://formspree.io)
2. Create form → Copy ID
3. Edit `landing/index.html` line ~430:
   ```html
   <form action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
   ```
4. Git commit & push → Auto-redeploys!

---

## ✅ Done!

Your landing page is live at: **https://guardyn.app**

**Optional enhancements:**
- Enable Web Analytics in Cloudflare dashboard
- Add SSL (automatic)
- Configure email notifications in Formspree

---

## 📱 Preview Links

After deployment:
- **Production**: https://guardyn.app
- **Cloudflare Preview**: https://guardyn-landing.pages.dev

---

## Need Help?

See full guide: [landing/README.md](./README.md)
