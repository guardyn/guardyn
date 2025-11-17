# Web Server Configuration for .well-known

This directory must be served with correct MIME types and headers for RFC 9116 compliance.

## Nginx Configuration

Add to your `nginx.conf` or site configuration:

```nginx
location /.well-known/security.txt {
    alias /path/to/guardyn/landing/.well-known/security.txt;
    add_header Content-Type "text/plain; charset=utf-8";
    add_header Cache-Control "public, max-age=3600";
}

location /.well-known/pgp-key.txt {
    alias /path/to/guardyn/landing/.well-known/pgp-key.txt;
    add_header Content-Type "text/plain; charset=utf-8";
    add_header Cache-Control "public, max-age=86400";
}
```

## Apache Configuration

Add to your `.htaccess` or Apache config:

```apache
<Files "security.txt">
    Header set Content-Type "text/plain; charset=utf-8"
    Header set Cache-Control "public, max-age=3600"
</Files>

<Files "pgp-key.txt">
    Header set Content-Type "text/plain; charset=utf-8"
    Header set Cache-Control "public, max-age=86400"
</Files>
```

## Static Site Hosting

### Netlify

Create `netlify.toml` in project root:

```toml
[[headers]]
  for = "/.well-known/security.txt"
  [headers.values]
    Content-Type = "text/plain; charset=utf-8"
    Cache-Control = "public, max-age=3600"

[[headers]]
  for = "/.well-known/pgp-key.txt"
  [headers.values]
    Content-Type = "text/plain; charset=utf-8"
    Cache-Control = "public, max-age=86400"
```

### Vercel

Create `vercel.json` in project root:

```json
{
  "headers": [
    {
      "source": "/.well-known/security.txt",
      "headers": [
        {
          "key": "Content-Type",
          "value": "text/plain; charset=utf-8"
        },
        {
          "key": "Cache-Control",
          "value": "public, max-age=3600"
        }
      ]
    },
    {
      "source": "/.well-known/pgp-key.txt",
      "headers": [
        {
          "key": "Content-Type",
          "value": "text/plain; charset=utf-8"
        },
        {
          "key": "Cache-Control",
          "value": "public, max-age=86400"
        }
      ]
    }
  ]
}
```

### GitHub Pages

GitHub Pages automatically serves files from `.well-known/` directory.

Just ensure the directory is in your published branch (`main` or `gh-pages`).

## Verification

After deployment, verify with:

```bash
# Check security.txt
curl -I https://guardyn.co/.well-known/security.txt

# Should return:
# Content-Type: text/plain; charset=utf-8
# Status: 200 OK

# Validate security.txt format
curl https://guardyn.co/.well-known/security.txt | grep -E "Contact:|Expires:|Encryption:"

# Check PGP key
curl https://guardyn.co/.well-known/pgp-key.txt | gpg --import --dry-run
```

## Testing Locally

```bash
# Serve landing directory
cd landing
python3 -m http.server 8000

# Test in another terminal
curl http://localhost:8000/.well-known/security.txt
curl http://localhost:8000/.well-known/pgp-key.txt
```

## Security.txt Validator

Use official validator: https://securitytxt.org/

Enter: `https://guardyn.co/.well-known/security.txt`

Expected result: ✅ Valid security.txt file

---

**Note**: This configuration is automatically handled if you're using the provided deployment scripts.
