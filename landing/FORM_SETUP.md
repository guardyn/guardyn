# Email Form Setup Guide

## Option 1: Formspree (Recommended - Free & Easy)

### Setup Steps:

1. **Sign up at Formspree**

   - Go to [formspree.io](https://formspree.io)
   - Sign up with email or GitHub

2. **Create New Form**

   - Click "New Form"
   - Name: "Guardyn Beta Signup"
   - Choose free plan (50 submissions/month)

3. **Get Form Endpoint**

   - Copy your form endpoint: `https://formspree.io/f/YOUR_FORM_ID`

4. **Update index.html**

   ```html
   <!-- Replace line ~430 -->
   <form id="beta-form" action="https://formspree.io/f/YOUR_FORM_ID" method="POST"></form>
   ```

5. **Configure Notifications**
   - In Formspree dashboard, set email where submissions go
   - Add custom success message if needed

### Free Plan Limits:

- ✅ 50 submissions/month
- ✅ Email notifications
- ✅ Spam filtering
- ✅ No branding on free tier

---

## Option 2: Cloudflare Workers (Free & Unlimited)

### Setup Steps:

1. **Create Worker**

   ```bash
   cd landing
   wrangler init beta-form-worker
   ```

2. **Worker Code (worker.js)**

   ```javascript
   export default {
     async fetch(request, env) {
       if (request.method !== "POST") {
         return new Response("Method not allowed", { status: 405 });
       }

       try {
         const formData = await request.formData();
         const email = formData.get("email");

         // Validate email
         const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
         if (!email || !emailRegex.test(email)) {
           return new Response("Invalid email", { status: 400 });
         }

         // Send to your notification service
         await fetch("https://api.telegram.org/bot" + env.TELEGRAM_BOT_TOKEN + "/sendMessage", {
           method: "POST",
           headers: { "Content-Type": "application/json" },
           body: JSON.stringify({
             chat_id: env.TELEGRAM_CHAT_ID,
             text: `🚀 New Guardyn Beta Signup!\n\nEmail: ${email}`,
           }),
         });

         // Or save to KV storage
         await env.BETA_SIGNUPS.put(email, new Date().toISOString());

         return new Response("Success", { status: 200 });
       } catch (error) {
         return new Response("Error", { status: 500 });
       }
     },
   };
   ```

3. **Deploy Worker**

   ```bash
   wrangler deploy
   ```

4. **Update index.html**
   ```html
   <form id="beta-form" action="https://beta-form.YOUR_SUBDOMAIN.workers.dev" method="POST"></form>
   ```

---

## Option 3: Google Forms (Free & Unlimited)

### Setup Steps:

1. **Create Google Form**

   - Go to [forms.google.com](https://forms.google.com)
   - Create new form with email field

2. **Get Pre-filled Link**

   - Click "Get pre-filled link"
   - Enter test email
   - Copy the URL
   - Extract form ID from URL: `https://docs.google.com/forms/d/e/{FORM_ID}/formResponse`

3. **Update index.html with AJAX**

   ```html
   <form id="beta-form" onsubmit="submitToGoogleForm(event)">
     <input type="email" name="email" id="email" required />
     <button type="submit">Sign Up</button>
   </form>

   <script>
     async function submitToGoogleForm(e) {
       e.preventDefault();
       const email = document.getElementById("email").value;
       const formData = new FormData();
       formData.append("entry.YOUR_ENTRY_ID", email); // Get from pre-filled link

       await fetch("https://docs.google.com/forms/d/e/YOUR_FORM_ID/formResponse", {
         method: "POST",
         body: formData,
         mode: "no-cors",
       });

       alert("Thanks for signing up!");
       e.target.reset();
     }
   </script>
   ```

---

## Option 4: Direct to Email (via SendGrid API)

### Setup Steps:

1. **Get SendGrid API Key**

   - Sign up at [sendgrid.com](https://sendgrid.com)
   - Get API key (100 emails/day free)

2. **Create Cloudflare Worker**

   ```javascript
   export default {
     async fetch(request, env) {
       if (request.method !== "POST") {
         return new Response("Method not allowed", { status: 405 });
       }

       const formData = await request.formData();
       const email = formData.get("email");

       // Send email via SendGrid
       await fetch("https://api.sendgrid.com/v3/mail/send", {
         method: "POST",
         headers: {
           Authorization: `Bearer ${env.SENDGRID_API_KEY}`,
           "Content-Type": "application/json",
         },
         body: JSON.stringify({
           personalizations: [
             {
               to: [{ email: "admin@guardyn.app" }],
               subject: "New Beta Signup",
             },
           ],
           from: { email: "noreply@guardyn.app" },
           content: [
             {
               type: "text/plain",
               value: `New beta signup: ${email}`,
             },
           ],
         }),
       });

       return new Response("Success", { status: 200 });
     },
   };
   ```

---

## Recommendation for Guardyn

**Use Formspree** for quick start:

- ✅ No code required
- ✅ 5 minute setup
- ✅ Perfect for MVP
- ✅ Easy to migrate later

**Switch to Cloudflare Workers** when scaling:

- ✅ Unlimited submissions
- ✅ Full control
- ✅ Can integrate with database
- ✅ Add custom logic

---

## Testing

After setup, test form:

```bash
curl -X POST https://guardyn.co \
  -d "email=test@example.com"
```

Check:

- [ ] Email received
- [ ] Form resets after submission
- [ ] Success message shows
- [ ] No console errors

---

## Analytics

Track form submissions:

1. **Google Analytics Event**

   ```javascript
   gtag("event", "beta_signup", {
     event_category: "engagement",
     event_label: "landing_page",
   });
   ```

2. **Cloudflare Web Analytics**
   - Automatic tracking enabled
   - View in dashboard

---

## Spam Protection

### Add reCAPTCHA (optional)

1. Get site key from [google.com/recaptcha](https://www.google.com/recaptcha)
2. Add to form:
   ```html
   <div class="g-recaptcha" data-sitekey="YOUR_SITE_KEY"></div>
   <script src="https://www.google.com/recaptcha/api.js" async defer></script>
   ```

Formspree has built-in spam filtering, so reCAPTCHA may not be needed initially.
