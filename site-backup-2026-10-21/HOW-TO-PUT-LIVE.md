# Put PyMason (and site updates) live — director cheat sheet

You do **not** need to code. Claude/Grok already built the files. You only **upload**.

## What was prepared for you

| Local path | Becomes live at |
|------------|-----------------|
| `StudioOps\site\pymason.html` | https://wpaistudio.net/pymason.html |
| `StudioOps\site\pymason\` (app) | https://wpaistudio.net/pymason/ |
| Home / Products / Studio | Already linked to PyMason |

A packed zip is built by:

```powershell
pwsh -File C:\WPAI\Software\StudioOps\scripts\Pack-Site.ps1
```

That creates: `C:\WPAI\Software\StudioOps\dist\wpaistudio-net-site-YYYYMMDD-HHMMSS.zip`

## Option A — Cloudflare Pages (recommended if site is already on Cloudflare)

From the DEPLOY note Claude left (`airo-site\DEPLOY.md`):

1. Open https://dash.cloudflare.com and sign in.
2. Go to **Workers & Pages** → your **wpaistudio** (or similar) Pages project.
3. Click **Create deployment** / **Upload assets** / **Retry deployment** (wording varies).
4. Either:
   - **Drag the whole `site` folder** after unzipping the pack, **or**
   - Unzip the latest `dist\wpaistudio-net-site-*.zip` and drag **those unzipped files** (so `index.html` is at the root of the upload).
5. Wait for deploy → open https://wpaistudio.net/pymason.html

**Important:** upload **contents** of the zip, not a nested folder that puts the site under `/something/`.

## Option B — GoDaddy File Manager (if domain still hosts files there)

1. Run the pack script above.
2. Unzip the zip on your PC.
3. GoDaddy → your hosting → **File Manager** → public web root (`public_html` or similar).
4. Upload / overwrite:
   - `index.html`, `products.html`, `studio.html`, `pymason.html`, …
   - `css/`, `js/`, `assets/`
   - **new folder** `pymason/` (the app — whole folder)
5. Hard-refresh https://wpaistudio.net/pymason.html

## Option C — Local only (see it before upload)

```powershell
cd C:\WPAI\Software\StudioOps\site
python -m http.server 8090
```

Then open:

- http://localhost:8090/pymason.html  ← product page  
- http://localhost:8090/pymason/      ← free trial app  

## After it’s live — check

1. https://wpaistudio.net/pymason.html  
2. Home page shows a **PyMason** card  
3. Products page lists PyMason at the top  
4. **Start free trial** opens the login gate (checkbox + studio / wpai-forge)

## Feedback email (already on the page)

Testers: **rob@wpaistudio.net** subject `PyMason feedback (trial)`

## If something 404s

| Symptom | Fix |
|---------|-----|
| `/pymason.html` 404 | Product page not uploaded |
| `/pymason/` 404 | Forgot the `pymason/` **folder** with `index.html` |
| Old home page | Browser cache → Ctrl+Shift+R, or CDN still serving old deploy |

## You don’t need

- Git (unless you already connected a repo to Pages)
- npm build for this static site
- To edit HTML yourself for a normal update — ask an AI to change files, then re-pack + re-upload

---

© 2026 Wizard Productions AI Studio. All Rights Reserved.
