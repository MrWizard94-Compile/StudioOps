# Airo Design Handoff → Claude (Orchestrator)

**From:** Grok Executor  
**For:** Full Airo design replication of WPAI studio site  
**Date:** 2026-07-10  
**Director:** Rob — collab strengths-based; Grok graphics, Claude structure/QA  

---

## 1. Live references

| What | URL / path |
|------|------------|
| Share link | `https://airo.ai/share/Z2ZkcThqaDNiZjpjMzY6OWQ5Y2RzUHFfRDBX` |
| Preview host | `https://gfdq8jh3bf.preview.c36.airoapp.ai/` |
| Share token | `9d9cdsPq_D0W` (decoded id: `gfdq8jh3bf:c36:9d9cdsPq_D0W`) |
| Site ID | `gfdq8jh3bf` |
| Airo editor | `https://airo-builder.godaddy.com/develop/gfdq8jh3bf?siteId=gfdq8jh3bf` |
| Product | Airo App Builder (`aab-v1`), Vite + React 19 + Tailwind + React Router |
| Health API | `GET /api/health` → `{"status":"ok",...}` |

Content is gated: raw `src/content/*` forbids direct import; pages consume `import { home, products, studio, about, contact } from 'virtual:content'`.

---

## 2. Routes (Airo SPA → our static files)

| Airo route | Local file | Content key |
|------------|------------|-------------|
| `/` | `site/index.html` | `home` |
| `/products` | `site/products.html` | `products` |
| `/studio` | `site/studio.html` | `studio` |
| `/about` | `site/about.html` | `about` |
| `/contact` | `site/contact.html` | `contact` |
| `*` | — | NotFound |

Layout shell: `RootLayout` → `Website` → `Header` + `Outlet` + `Footer` + cookie banner.

---

## 3. Design tokens (exact from Airo `globals.css` `:root`)

### Fonts (Google)

```
https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700&family=Inter:wght@400;500;600&display=swap
```

| Token | Value |
|-------|--------|
| `--font-sans` | `"Inter", -apple-system, BlinkMacSystemFont, sans-serif` |
| `--font-heading` | `"Cinzel", Georgia, serif` |
| `--font-serif` | ui-serif, Georgia, Times New Roman |
| `--font-mono` | ui-monospace, SF Mono, Monaco, … |

### Colors (HSL channels — use as `hsl(var(--token))`)

| Token | HSL | Role |
|-------|-----|------|
| `--background` | `15 25% 3%` | Page coal |
| `--foreground` | `0 0% 96%` | Body text |
| `--card` | `30 13% 6%` | Card surface |
| `--card-foreground` | `32 46% 93%` | Card text (warm bone) |
| `--primary` | `23 100% 57%` | Ember orange ≈ `#ff7a26` |
| `--primary-foreground` | `0 0% 100%` | On-primary |
| `--secondary` | `53 100% 57%` | Gold accent |
| `--secondary-foreground` | `0 0% 39%` | On-secondary |
| `--muted` | `23 18% 9%` | Muted surface |
| `--muted-foreground` | `24 19% 58%` | Secondary text |
| `--accent` | `12 82% 51%` | Deep ember ≈ `#e8451c` |
| `--accent-foreground` | `0 0% 100%` | On-accent |
| `--border` / `--input` | `23 27% 13%` | Borders |
| `--ring` | `23 100% 57%` | Focus ring |
| `--destructive` | `0 84% 60%` | Errors |

Chart scale: `23 100%` at 87% / 72% / 57% / 42% / 27% lightness.

### Radius & shadows

| Token | Value |
|-------|--------|
| `--radius` | `0.5rem` |
| `--radius-button` | `calc(var(--radius) - 2px)` |
| Shadows | Standard shadcn-style `hsl(0 0% 0% / 0.10)` ladder (`--shadow-sm` … `--shadow-2xl`) |

### Header CTA (from Airo Header.tsx inline styles)

```
background: linear-gradient(135deg, #ff7a26, #e8451c)
boxShadow: 0 0 16px rgba(255, 122, 38, 0.3)
color: #ff7a26  (links)
color: rgba(245, 237, 228, 0.7–0.75)  (muted nav)
letterSpacing: 0.05em–0.06em
```

Footer title string observed:  
`Wizard Productions AI Studio - Forging the future of creative media`

### Tailwind mapping

Airo uses shadcn-style tokens: `bg-background`, `text-foreground`, `bg-primary`, `font-heading`, `font-sans`, `rounded-md` / `rounded-lg`, `lg:grid-cols-12`, `lg:col-span-5/7`, etc.  
Config: `StudioOps\_airo_design\_tailwind.config.js`  
Full compiled CSS: `StudioOps\_airo_design\_src_styles_globals.css` (76KB Vite-wrapped)  
Extracted root: `StudioOps\_airo_design\extracted-root.css`

---

## 4. Asset map (Airo URL → local file)

Base remote: `https://gfdq8jh3bf.preview.c36.airoapp.ai/airo-assets/`  
Local base: `C:\WPAI\Software\StudioOps\site\assets\`

| Airo path | Local file | Dimensions | Bytes | Use |
|-----------|------------|------------|-------|-----|
| `images/logo/horizontal` | `logo-horizontal.png` | 900×350 | 263KB | Header logo |
| `images/pages/home/hero-forge` | `hero-forge.jpg` | 1600×1066 | 176KB | Home hero |
| `images/pages/home/products-bg` | `products-bg.jpg` | 1600×1066 | 362KB | CTA band / products atmosphere |
| `images/pages/products/repoforge-bg` | `repoforge-bg.jpg` | 1400×787 | 188KB | RepoForge card/section |
| `images/pages/products/mixin-bg` | `mixin-bg.jpg` | 1400×787 | 224KB | Mixin card/section |
| `images/pages/studio/music-lane` | `lane-music.jpg` | 1200×800 | 115KB | Studio music |
| `images/pages/studio/software-lane` | `lane-software.jpg` | 1200×675 | 94KB | Studio software |
| `images/pages/studio/games-lane` | `lane-games.jpg` | 1200×675 | 109KB | Studio games |
| `images/pages/about/founder-portrait` | `founder-portrait.jpg` | 400×400 | 23KB | About founder |
| (local brand) | `backdrop.png` | 1200×800 | ~1MB | Body texture wash |
| (local brand) | `brand-mark.jpg` | 512×341 | 31KB | Favicon fallback |
| (local brand) | `brand.jpg` | 1200×1200 | 150KB | OG / square crop |

**Also still present (legacy, optional):** `repoforge.png`, `mfm.png` — original product art before Airo bgs; Airo replica should prefer `*-bg.jpg`.

**Raw unoptimized copies:** `site/assets/airo/*` (original download names).

---

## 5. Content source of truth

Extracted from Airo `virtual:content` into:

```
C:\WPAI\Software\StudioOps\_airo_extract\
  home.json
  products.json
  studio.json
  about.json
  contact.json
```

These are the canonical copy/structure for product prices ($14 / $29), CTAs, Gumroad URLs, lane copy, founder story, contact form labels.

Raw bus-side extract of virtual module was also saved historically as `_airo_content_raw.js` (may be deleted); JSON extract is enough.

---

## 6. Structural notes from Airo React sources

Downloaded for reference under `StudioOps\_airo_design\`:

| File | Size | Notes |
|------|------|--------|
| `_src_styles_globals.css` | 76KB | Full tokens + Tailwind build |
| `_tailwind.config.js` | 12KB | colors → hsl(var(--…)), fontFamily |
| `_src_layouts_parts_Header.tsx` | 32KB | Sticky header, mobile menu, CTA gradient |
| `_src_layouts_parts_Footer.tsx` | 16KB | Footer links + disclosure |
| `_src_layouts_Website.tsx` | 6.7KB | Shell |
| `_src_layouts_RootLayout.tsx` | 7KB | Root |
| `_src_pages_index.tsx` | 150KB | Home with motion, content keys |
| `_src_components_ui_button.tsx` | 8.5KB | shadcn button cva |
| `_src_lib_utils.ts` | 846B | cn() helper |

### Layout patterns observed

- Sticky blurred header; scrolls → border + stronger bg  
- Hero: split grid (copy + media), Cinzel headline, gradient accent word  
- Product cards: 16:9 media, pills (Live / category), price gold, dual CTAs  
- Studio: alternating lane sections with image + attributes grid  
- “Lava” horizontal gradient dividers between sections  
- CTA bands with background image + dark scrim  
- Motion library (`motion/react`) for fade-in / hover scale — optional for static  
- Contact form topics: General, Sync/Licensing, Collaboration, Product question, Other  
- Meta: Helmet titles per page; OG/Twitter patterns  

### Content key examples (Home)

`home.hero.badge`, `home.hero.headline_start`, `home.hero.headline_accent`, `home.hero.lede`, product items, studio lanes, about blurb, contact block.

---

## 7. Our recreation state (for QA)

| Path | Status |
|------|--------|
| `site/css/styles.css` | Rewritten to Airo tokens + Cinzel/Inter (Grok visual pass; **Claude owns CSS now**) |
| `site/js/site.js` | Mobile nav, sticky header, mailto form, active nav |
| `site/*.html` | 5 pages; image hooks for Airo assets; **Claude owns structure/a11y** |
| `site/assets/*` | Airo art imported + optimized (**Grok owns; stable**) |
| `ASSETS.md` | Short asset manifest |
| `scripts/Self-Check.ps1` | Validates pages + new asset names |
| `scripts/Pack-Site.ps1` | Zip for GoDaddy (excludes `_` dirs) |

**Locked (graphics):** asset filenames + token set above.  
**WIP (Claude):** HTML structure fidelity, a11y, responsive, brand-voice audit vs `_airo_extract`, CSS polish after taking ownership.

---

## 8. Links / commerce (must stay correct)

- Storefront: `https://wpaistudio.gumroad.com`  
- RepoForge: `https://wpaistudio.gumroad.com/l/repoforge` ($14)  
- Lite: `https://github.com/MrWizard94-Compile/repoforge`  
- MFM: `https://wpaistudio.gumroad.com/l/mixin-field-manual` ($29)  
- Sample: `https://wpaistudio.gumroad.com/l/mixin-sample`  
- GitHub org user: `https://github.com/MrWizard94-Compile`  
- Email: `rob@wpaistudio.net`  

---

## 9. How Claude should use this

1. Open Airo share in browser for visual reference.  
2. Diff `site/*.html` against `_airo_extract/*.json` for copy completeness.  
3. Treat `AIRO-DESIGN-HANDOFF.md` + `ASSETS.md` + `_airo_design/*` as the design bible.  
4. Edit HTML/CSS/JS freely; request asset re-exports from Grok if dimensions/crops wrong.  
5. Re-run `scripts/Self-Check.ps1` + `Pack-Site.ps1` before Director deploy.

---

## 10. Quick CSS copy-paste (canonical tokens)

```css
:root {
  --background: 15 25% 3%;
  --foreground: 0 0% 96%;
  --card: 30 13% 6%;
  --card-foreground: 32 46% 93%;
  --primary: 23 100% 57%;
  --primary-foreground: 0 0% 100%;
  --secondary: 53 100% 57%;
  --secondary-foreground: 0 0% 39%;
  --muted: 23 18% 9%;
  --muted-foreground: 24 19% 58%;
  --accent: 12 82% 51%;
  --accent-foreground: 0 0% 100%;
  --border: 23 27% 13%;
  --input: 23 27% 13%;
  --ring: 23 100% 57%;
  --font-sans: "Inter", -apple-system, BlinkMacSystemFont, sans-serif;
  --font-heading: "Cinzel", Georgia, serif;
  --radius: 0.5rem;
  --radius-button: calc(var(--radius) - 2px);
}
```

Header CTA gradient: `linear-gradient(135deg, #ff7a26, #e8451c)`  
Ember glow: `0 0 16px rgba(255, 122, 38, 0.3)`

---

*AI is in the name; the wizard is in the work.*  
Handoff complete — Grok standing by for graphic re-exports.
