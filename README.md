# StudioOps

**Studio operations kit for Wizard Productions AI Studio (WPAI).**

1. **Multi-page studio site** for `wpaistudio.net` — recreation of the GoDaddy Airo share (content-faithful, fully owned static files).
2. **Council bus CLI** so agents can `hf-say` without hand-rolled JSONL.

Human-directed · AI-assisted · fully disclosed.

---

## Layout

```
StudioOps/
  site/                 ← upload this folder to wpaistudio.net
    index.html          Home
    products.html       RepoForge + Mixin Field Manual deep pages
    studio.html         Lanes + how the studio works
    about.html          Founder + philosophy + AI transparency
    contact.html        Mailto form + links
    css/styles.css
    js/site.js
    assets/             brand + product art
  cli/
    hf-bus.ps1
    Install-HfBus.ps1
    tests/hf-bus.tests.ps1
  scripts/
    Pack-Site.ps1
    Self-Check.ps1
    Optimize-Assets.ps1
  dist/                 packed zips for GoDaddy upload
  README.md
```

---

## A) Studio site (`site/`)

Recreated from the Airo AI Builder share content (`_airo_extract/*.json`), with:

- Forge aesthetic (ember on coal)
- All five pages from the Airo app
- Live Gumroad + GitHub links
- Brand voice from `Brand/BRAND-VOICE.md`
- Contact form via `mailto:` (no backend)
- Mobile nav, OG/Twitter meta, no build step

### Deploy to GoDaddy

1. Run packer:
   ```powershell
   pwsh -File C:\WPAI\Software\StudioOps\scripts\Pack-Site.ps1
   ```
2. Upload **zip contents** to web root (`index.html` at domain root).
3. Publish / un-draft if the venture dashboard still shows DRAFT.
4. Hard-refresh `https://wpaistudio.net/`.

### Local preview

```powershell
Start-Process "C:\WPAI\Software\StudioOps\site\index.html"
```

Or:

```powershell
cd C:\WPAI\Software\StudioOps\site
python -m http.server 8080
```

### Airo vs this site

| | Airo share | This `site/` |
|--|------------|--------------|
| Stack | React/Vite hosted by GoDaddy | Static HTML/CSS/JS you own |
| Lock-in | Platform-coupled while hosted | Drop on any host |
| Content | Same WPAI copy (extracted) | Same, editable offline |
| Cost | Airo plan / credits | Free static hosting |

---

## B) Council bus CLI (`cli/hf-bus.ps1`)

```powershell
. C:\WPAI\Software\StudioOps\cli\hf-bus.ps1
hf-say "message" -To orchestrator
hf-bus tail -Count 20
hf-bus status
hf-bus export
```

Install into profile: `pwsh -File cli\Install-HfBus.ps1`

Tests: `pwsh -File cli\tests\hf-bus.tests.ps1`  
Self-check: `pwsh -File scripts\Self-Check.ps1`

---

## C) WPAI control plane (`cli/wpai.ps1`)

On-demand studio brain: BLACKBOARD (single-writer RMW), HITL approvals, music package gate, Janus job→DelegationPlan transform, overnight arm/start with mid-loop spend caps.

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\Install-WpaiStudio.ps1
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 status
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 music check -EmitTicket
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 kill set loops true
```

| Artifact | Path |
|----------|------|
| Runtime | `C:\WPAI\Workspace\.wpai\` |
| BLACKBOARD | `.wpai\BLACKBOARD.json` |
| Approvals | `.wpai\approvals\*.json` |
| Playbook | `docs\OPERATOR-PLAYBOOK.md` |
| Architecture | `C:\WPAI\AI-Research\AUTONOMOUS-AI-ARCHITECTURE.md` |

Tests: `pwsh -File cli\tests\wpai.tests.ps1`

**Invariants:** no second task store; no unsupervised DistroKid/Bandcamp/YouTube/Gumroad publish.

---

## License

UNLICENSED — WPAI internal studio kit.

---

*AI is in the name; the wizard is in the work.*
