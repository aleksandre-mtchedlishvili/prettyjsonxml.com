# Pretty JSON & XML

> Free, browser-based viewer for JSON and XML.
> Paste or upload — get a searchable, sortable **table** or a foldable **tree**.
> Format, minify, base64 image preview, full-text search.
> 100% client-side: your data never leaves the browser.

**Live at [prettyjsonxml.com](https://prettyjsonxml.com)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![No build required](https://img.shields.io/badge/build-none-brightgreen)
![No dependencies](https://img.shields.io/badge/dependencies-zero-brightgreen)
![Single file](https://img.shields.io/badge/size-~225%20KB-blue)

## Why

Every JSON viewer pretty-prints. Useful for a 10-line config — useless for the actual data shape developers deal with every day: an array of objects. A pretty-printed 50-row API response is still 500 lines you scroll top-to-bottom.

Pretty JSON & XML treats those arrays as **tables**: sortable columns, searchable rows, click any row to expand the full nested detail. Same data, but you scan it instead of read it.

It also handles XML — including SOAP envelopes, RSS / Atom feeds, Maven POM, SVG, and any custom XML — using the same table-view detection (repeated elements become rows).

## Features

- ▦ **Table view** with auto-detected columns (frequency + semantic priority)
- 🌳 **Tree view** with foldable `{ } [ ]` brackets (native JSON syntax for JSON sources)
- ✨ **Format / minify** for both JSON and XML
- ⌕ **Instant full-text search** across rows + nested detail
- 🖼 **Inline base64 image preview** (PNG / JPEG / GIF / SVG)
- 📦 **Handles 9 MB+ files** via virtual scrolling + lazy tree expansion
- 🔒 **100% client-side** — single HTML file, no backend, no upload
- 🌓 Light / dark theme

## Use

Just open [prettyjsonxml.com](https://prettyjsonxml.com) and paste your data.

Or run it offline: download `index.html` and open it in any modern browser. No server, no install, no internet needed once loaded.

## Architecture

- **Single HTML file** — no build step, no bundler, no node_modules
- **Vanilla JavaScript** — zero runtime dependencies
- **Web Worker** for `JSON.parse` / format / minify (inline blob URL)
- **Virtual scroller** for tables with ≥ 100 rows (only ~50 in DOM at any time)
- **`content-visibility: auto`** for off-screen layout skipping
- **Lazy tree expansion** beyond depth 2 for large documents

For the detailed perf story (what worked, what didn't, including the Web Worker that made things slower), see the [guide](https://prettyjsonxml.com/guide/view-json-as-table) and the [dev.to write-up](#).

## Project layout

```
index.html                        The app — single HTML/CSS/JS file
privacy.html                      Privacy policy
terms.html                        Terms of use
guide/view-json-as-table.html     Long-form guide / SEO content
example/rss-feed.html             Sample-data landing page
og.jpg / og.svg                   1200×630 social-share image (+ source)
_headers                          Cloudflare Pages HTTP headers
sitemap.xml                       Sitemap for search engines
robots.txt                        Crawler rules
test-xmls/                        Sample fixtures for testing
```

## Run locally

Clone the repo and open `index.html` in any modern browser. That's it — no build step, no install, no internet needed once loaded.

For contributors testing changes: edit `index.html`, refresh the browser, repeat.

## Security & privacy posture

- **CSP** restricts the page to its own origin + inline scripts/styles + the three analytics origins
- **HSTS** — one year, `includeSubDomains`, preload-eligible
- **X-Frame-Options: DENY** + `frame-ancestors 'none'` — clickjacking protection
- **Referrer-Policy: no-referrer** — no URL leakage on outbound clicks
- **All file processing is client-side** — server never sees user data
- Sensitive elements (editor, viewer, path bar) are masked from session-recording analytics via `data-clarity-mask="true"`

See [`privacy.html`](privacy.html) for the user-facing privacy commitments.

## Contributing

Bug reports, feature ideas, and PRs are welcome.

- **Found a bug?** [Open an issue](https://github.com/aleksandre-mtchedlishvili/prettyjsonxml.com/issues/new) — include the file or data shape that triggers it
- **Want a feature?** Open an issue describing the use case
- **Have a fix?** PRs welcome — please keep the no-build / no-dependency philosophy

Areas with open territory:
- CSV / TSV export from the table view
- JSONC / JSON5 support (allow comments)
- Multi-column sort
- Service Worker for true offline use
- More example pages (`/example/soap-response`, `/example/maven-pom`, etc.)

## License

[MIT](LICENSE) — use it, fork it, ship it. Attribution appreciated but not required.
