# Pretty JSON & XML — `prettyjsonxml.com`

Free, browser-based viewer for JSON and XML. Paste or upload, get a searchable sortable **table** or a foldable **tree**. Format / minify, inline base64 image preview, full-text search. 100% client-side — files never leave the browser.

Live at **<https://prettyjsonxml.com/>**.

## Files in this directory

| File | Purpose |
|---|---|
| `index.html` | **The app.** Single-file HTML/CSS/JS. ~225 KB. |
| `privacy.html` | Privacy policy page |
| `terms.html` | Terms of use page |
| `guide/view-json-as-table.html` | Long-form SEO guide |
| `example/rss-feed.html` | Sample-data landing page (RSS) |
| `og.jpg` | 1200×630 social-share image (Open Graph / Twitter) |
| `og.svg` | Editable source for `og.jpg` (regenerate if branding changes) |
| `og-template.html` | HTML version of the OG image — design reference |
| `sitemap.xml` | Sitemap listing all 5 indexable URLs |
| `robots.txt` | Crawler rules (allows search engines, blocks GPTBot/CCBot/ClaudeBot/Google-Extended) |
| `_headers` | Cloudflare Pages HTTP headers (CSP, HSTS, X-Frame-Options, cache rules) |
| `test-xmls/` | Sample XML/JSON fixtures used during development (not deployed) |
| `deploy/` | Build artifact: just the runtime files, ready to drag-upload (gitignored) |
| `response_1779436642581.xml` | 9.4 MB SOAP fixture for perf testing (gitignored) |

## Analytics

The site loads three trackers, all deferred until after `window.load`:

- **Google Analytics 4** — measurement ID `G-7429L5S7E8`. Rotate via search-and-replace in `index.html` (2 occurrences).
- **Microsoft Clarity** — project ID `wvbuum2njr`. Session recordings + heatmaps. The editor, viewer, and path-bar are masked with `data-clarity-mask="true"` so Clarity records the layout but never the data you paste.
- **Cloudflare Web Analytics** — token `b19f5e1e82ce4c659c6b44aea880391f`. Cookieless, GDPR-friendly.

All three are skipped on `localhost` so dev traffic doesn't pollute prod.

## Deploying to Cloudflare Pages

### Build the deploy folder

From this directory:

```bash
rm -rf deploy && mkdir -p deploy/guide deploy/example
cp index.html privacy.html terms.html _headers robots.txt sitemap.xml og.jpg deploy/
cp guide/view-json-as-table.html deploy/guide/
cp example/rss-feed.html deploy/example/
```

This gives you a `deploy/` directory with only the runtime files (no `.git`, no test fixtures, no oversize sample XML).

### Upload — drag the **folder**, not a ZIP

In the Cloudflare dashboard:

1. **Workers & Pages → your project → Create deployment → Direct upload**
2. **Drag the entire `deploy/` folder** into the upload area
3. Wait ~30 seconds for propagation across edges
4. Visit the URLs to verify

**Avoid ZIP uploads on Windows.** PowerShell's `Compress-Archive` writes paths with backslashes (`guide\view-json-as-table.html`), which violates the ZIP spec. Cloudflare's Linux-based extractor interprets the backslash as part of the filename rather than a folder separator, so subfolder pages 404.

If you really need a ZIP, build it with 7-Zip / WinRAR / `git archive` / Git Bash's `zip` — those use forward slashes correctly.

### After deploy — verify these URLs

| URL | Should serve |
|---|---|
| `prettyjsonxml.com/` | Main app |
| `prettyjsonxml.com/privacy` | Privacy policy |
| `prettyjsonxml.com/terms` | Terms |
| `prettyjsonxml.com/guide/view-json-as-table` | Long-form guide |
| `prettyjsonxml.com/example/rss-feed` | RSS example |
| `prettyjsonxml.com/sitemap.xml` | Raw XML sitemap |

Cloudflare Pages auto-strips `.html` extensions in the address bar (clean URLs). The `.html` form still works as a 301 redirect.

If you see a 404 right after upload, wait 60 seconds and try again — edge propagation is usually that fast but not instant.

## Submitting to search engines

1. **Google Search Console** ([search.google.com/search-console](https://search.google.com/search-console))
   - Verify property via DNS TXT (already done — see verification records on the zone)
   - Sitemaps → Add new sitemap → `sitemap.xml`
   - URL Inspection → "Request indexing" for each new URL

2. **Bing Webmaster Tools** ([bing.com/webmasters](https://bing.com/webmasters)) — same sitemap

3. **Validate rich results** ([search.google.com/test/rich-results](https://search.google.com/test/rich-results))
   - Home page should detect `WebApplication`, `FAQPage`, `HowTo`
   - Guide page should detect `Article`

## Regenerating `og.jpg` (after editing `og.svg`)

```bash
npx http-server . -p 8765
```

Open `http://localhost:8765/og.svg` and in the browser console:

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
    a.download = 'og.jpg';
    a.click();
  }, 'image/jpeg', 0.9);
})();
```

Quality `0.9` keeps the file around 80 KB. Adjust if you need smaller.

## Security posture

- **CSP** — restricts to own origin + inline scripts/styles + analytics origins. `worker-src 'self' blob:` for the inline JSON-parse worker. `frame-ancestors 'none'`, `object-src 'none'`, `form-action 'none'`.
- **HSTS** — one year, includeSubDomains, preload-eligible
- **X-Frame-Options: DENY** — clickjacking protection
- **Referrer-Policy: no-referrer** — no URL leakage on outbound links
- **All processing is client-side** — server never sees user data
- **Editor/viewer masked from Clarity** via `data-clarity-mask="true"`

## Performance posture

- **Phase 1**: `content-visibility: auto` on table sections/rows/cards — browser skips off-screen layout
- **Phase 2**: JSON parse/format/minify in a Web Worker (blob URL, inline source)
- **Phase 3**: Virtual scrolling for table sections with ≥100 rows — only ~50 rows in DOM at a time
- **Editor read-only above 5 MB** — assigning huge strings to a `<textarea>` freezes the main thread. The data still parses and renders fully.
- **Defer DOMParser** via `setTimeout(0)` after upload so the toast paints first

## Alternative hosting

- **GitHub Pages** — push to a public repo, enable Pages, point to root
- **AWS S3 + CloudFront** — upload as static site, attach an ACM cert
- **nginx VPS** — drop the files in `/var/www/html`, copy `_headers` rules into nginx `add_header` directives

## File-size threshold

Files over **50 MB** trigger a confirmation dialog before parsing. Adjust `SIZE_WARN_MB` in `index.html` if you need a different threshold.

The 5 MB editor-skip threshold is `EDITOR_SKIP_MB` (also in `index.html`) — files above this load into the viewer but skip the textarea population.
