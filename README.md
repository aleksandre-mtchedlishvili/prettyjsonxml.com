# Data Viewer — XML & JSON

Free online XML and JSON viewer with beautiful table and tree views, instant search, and inline image preview. Files stay 100% in the user's browser — never uploaded to a server.

## Files in this directory

| File | Purpose |
|---|---|
| `xml-viewer.html` | **The app.** Rename to `index.html` when deploying. |
| `og.png` | 1200×630 social-share preview image (Open Graph / Twitter Card) |
| `og.svg` | Editable source for `og.png` (regenerate if branding changes) |
| `og-template.html` | HTML version of the OG image (mostly just a design reference now that og.svg exists) |
| `sitemap.xml` | Single-URL sitemap for Google Search Console |
| `robots.txt` | Crawler rules (blocks GPTBot/CCBot/etc. by default) |
| `_headers` | Cloudflare Pages HTTP headers (CSP, HSTS, etc.) |
| `test-xmls/` | Sample XML/JSON files used during development |

## Before you deploy — replace placeholders

Search-and-replace **`prettyjsonxml.com`** with your real domain in:

- `xml-viewer.html` (head section, ~9 occurrences: canonical, og:url, og:image, twitter:url, twitter:image, JSON-LD `url` & `image`)
- `sitemap.xml` (1 occurrence)
- `robots.txt` (1 occurrence)
- `og.svg` (1 occurrence — bottom-right corner text)
- `og.png` — regenerate after updating `og.svg`, see "Regenerating og.png" below

### Analytics (Google Analytics 4)

Currently wired to GA4 ID **`G-7429L5S7E8`**. If you ever rotate the property, search-and-replace the ID in `xml-viewer.html` (2 occurrences).

If you don't want analytics at all, delete the whole `<!-- Analytics -->` block. The CSP allows GA's domains regardless; that's fine and costs nothing.

### Optional: Cloudflare Web Analytics (free, cookieless)

In Cloudflare dashboard → Analytics → Web Analytics → enable for your domain → copy the token. Then uncomment the `<script defer src='...cloudflareinsights...'>` line in `xml-viewer.html` and replace `YOUR-CF-TOKEN`.

Cloudflare's stats are *real* numbers (not ad-blocked) and GDPR-compliant out of the box. Many people run both — GA for ecosystem integrations, CF for honest numbers.

### Optional: Monetization link

Footer has a "Buy me a coffee" link with `href="https://www.buymeacoffee.com/YOUR-USERNAME"`. Replace with your real BMC / Ko-fi / GitHub Sponsors URL, or delete the `<p class="landing-support">` block if you don't want a donation link.

## Deploying to Cloudflare Pages (recommended)

1. **Create a new Pages project** in the Cloudflare dashboard (Pages → Create → Direct Upload). No git required.
2. **Rename** `xml-viewer.html` → `index.html`.
3. **Upload** these files to the project root:
   - `index.html`
   - `og.png`
   - `sitemap.xml`
   - `robots.txt`
   - `_headers`
4. **Connect your domain** under Custom Domains. Cloudflare will issue an SSL cert automatically.
5. **If your domain is on Route 53**, point its NS records to Cloudflare, OR keep DNS on Route 53 and add a `CNAME` to the Pages URL.
6. Done. Site is live, on a global CDN, free, with HTTPS.

## Submitting to Google

1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add your domain as a property (verify via DNS TXT record)
3. **Sitemaps → Add new sitemap** → enter `sitemap.xml`
4. **URL Inspection → Request indexing** for the homepage
5. Allow 1–7 days for first indexing

## Regenerating `og.png` (after editing `og.svg`)

The PNG was rendered by drawing `og.svg` to a 1200×630 canvas in the browser. To redo:

1. Serve the dir locally: `npx http-server . -p 8765`
2. Open `http://localhost:8765/og.svg` in any modern browser
3. Run this in the browser console:

```js
(async () => {
  const r = await fetch('/og.svg');
  const svg = await r.text();
  const url = URL.createObjectURL(new Blob([svg], {type:'image/svg+xml'}));
  const img = new Image();
  await new Promise(res => { img.onload = res; img.src = url; });
  const c = document.createElement('canvas');
  c.width = 1200; c.height = 630;
  c.getContext('2d').drawImage(img, 0, 0, 1200, 630);
  c.toBlob(b => {
    const a = document.createElement('a');
    a.href = URL.createObjectURL(b);
    a.download = 'og.png';
    a.click();
  }, 'image/png');
})();
```

Alternative: use any online SVG→PNG converter (cloudconvert.com, svgtopng.com).

## Alternative hosting

- **GitHub Pages**: push to a public repo, enable Pages in settings, point Pages to root. Free, public source.
- **AWS S3 + CloudFront**: upload as static site, attach an ACM cert, alias Route 53 record to CloudFront distribution.
- **Your Hostinger VPS**: drop the files in `/var/www/html`, set up nginx with the headers from `_headers` rewritten as nginx `add_header` directives.

## Security posture

- **CSP** restricts the page to its own origin + inline scripts/styles + `data:`/`blob:` images
- **`Referrer-Policy: no-referrer`** prevents leaking the host URL on outbound clicks
- **`X-Frame-Options: DENY`** and **`frame-ancestors 'none'`** prevent clickjacking
- **HSTS** for one year (preload-eligible)
- All file processing is client-side — server never sees user data

## Notes on file-size guard

Files over **50 MB** trigger a confirmation dialog before parsing. Adjust `SIZE_WARN_MB` in `xml-viewer.html` if you want a different threshold.
