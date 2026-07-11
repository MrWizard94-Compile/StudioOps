# Airo visual asset manifest (Executor — Grok)
# Path base: C:\WPAI\Software\StudioOps\site\assets\

| File | Purpose | Intended use / size |
|------|---------|---------------------|
| logo-horizontal.png | Airo horizontal logo lockup | Header (h≈36px, natural ~900×350) |
| hero-forge.jpg | Home hero forge scene | Home hero visual (~1600×1066) |
| products-bg.jpg | Products atmosphere | CTA band background (~1600×1066) |
| repoforge-bg.jpg | RepoForge product art | Home card + products page (~1400×787) |
| mixin-bg.jpg | Mixin Field Manual art | Home card + products page (~1400×787) |
| lane-music.jpg | Music lane | Studio page (~1200×800) |
| lane-software.jpg | Software lane | Studio page (~1200×675) |
| lane-games.jpg | Games & research lane | Studio page (~1200×675) |
| founder-portrait.jpg | Founder portrait | About page (~400×400) |
| backdrop.png | Atmospheric texture | Body fixed wash (subtle) |
| brand-mark.jpg | Square crest (fallback favicon) | favicon |
| brand.jpg | Square brand crop (legacy) | optional OG fallback |

## Design tokens applied (from Airo globals.css)
- Fonts: Cinzel (headings) + Inter (body) via Google Fonts
- --primary: hsl(23 100% 57%) ember
- --accent: hsl(12 82% 51%) deep ember
- --secondary: hsl(53 100% 57%) gold
- --background: hsl(15 25% 3%)
- --card: hsl(30 13% 6%)
- --card-foreground: hsl(32 46% 93%)
- --muted-foreground: hsl(24 19% 58%)
- --border: hsl(23 27% 13%)
- --radius: 0.5rem

## LOCKED vs WIP
LOCKED (visual batch V1):
- All assets listed above pulled from Airo preview and optimized
- css/styles.css rewritten to Airo tokens + Cinzel/Inter (Grok temporary drive for visual fidelity — Claude owns CSS going forward per lane split; please adopt/adjust)
- HTML image hooks: logo, hero-forge, product bgs, three lanes, founder portrait, products-bg band

WIP / Claude lane:
- Structural HTML a11y, responsive polish, brand-voice copy audit vs _airo_extract
- Any markup refinements for Airo section layout parity (12-col grids, motion, etc.)
- Fidelity QA vs live Airo share

## Dist
C:\WPAI\Software\StudioOps\dist\wpaistudio-net-site-20260710-152037.zip (re-pack after Claude HTML pass if he edits)

## Note on clobber
Grok updated css/styles.css + HTML image refs to land the visual system. Claude: take CSS/HTML ownership from here; assets/* are stable unless you request re-exports.
