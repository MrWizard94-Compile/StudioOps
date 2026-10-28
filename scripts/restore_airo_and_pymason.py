#!/usr/bin/env python3
"""Fix restored Airo pages: unstick opacity, strengthen hero, add PyMason bands."""
from pathlib import Path

site = Path(__file__).resolve().parents[1] / "site"

for name in ["index.html", "products.html", "studio.html", "about.html", "contact.html"]:
    p = site / name
    if not p.exists():
        print("missing", name)
        continue
    t = p.read_text(encoding="utf-8")
    orig = t
    t = t.replace(
        'style="opacity: 0; transform: translateY(32px);"',
        'style="opacity: 1; transform: none;"',
    )
    t = t.replace(
        'style="opacity: 0; transform: translateY(24px);"',
        'style="opacity: 1; transform: none;"',
    )
    # Stronger full-bleed lava (Airo capture used 0.18 — too faint vs Jul 11)
    if name == "index.html" and 'style="opacity: 0.18;"' in t:
        t = t.replace('style="opacity: 0.18;"', 'style="opacity: 0.45;"', 1)
    t = t.replace(">c 2026 Wizard", ">© 2026 Wizard")
    t = t.replace(">c 2026 ", ">© 2026 ")
    if t != orig:
        p.write_text(t, encoding="utf-8")
        print("fixed", name)
    else:
        print("no change", name)

band = """
<!-- PyMason free feedback trial -->
<section id="pymason" class="relative py-16" style="background: rgb(10, 7, 6);">
  <div class="container mx-auto px-6">
    <div class="max-w-4xl mx-auto p-8" style="border: 1px solid rgba(255, 122, 38, 0.28); border-radius: 2px; background: rgba(18, 16, 14, 0.9);">
      <div class="text-xs uppercase tracking-widest mb-3" style="color: rgb(255, 122, 38); letter-spacing: 0.2em; font-family: var(--font-sans);">Beta · Free feedback trial</div>
      <h2 class="mb-3" style="font-family: var(--font-heading); font-size: clamp(1.75rem, 3vw, 2.4rem); font-weight: 700; color: rgb(245, 237, 228);">PyMason</h2>
      <p class="mb-4" style="font-family: var(--font-sans); color: rgba(245, 237, 228, 0.7); line-height: 1.7; max-width: 40rem;">Visual block-based Python studio — dual edit, run in browser, debugger, stage. Limited free trial. By participating you agree to provide thoughtful feedback after using it.</p>
      <div class="flex flex-wrap gap-3">
        <a href="pymason.html" class="inline-flex items-center px-6 py-3 font-semibold text-white" style="background: linear-gradient(135deg, rgb(255, 122, 38), rgb(232, 69, 28)); border-radius: 2px; font-family: var(--font-sans); box-shadow: rgba(255, 122, 38, 0.35) 0px 0px 20px;">PyMason page</a>
        <a href="/pymason/" class="inline-flex items-center px-6 py-3 font-semibold" style="border: 1px solid rgba(255, 122, 38, 0.4); color: rgb(245, 237, 228); border-radius: 2px; font-family: var(--font-sans);">Start free trial</a>
      </div>
    </div>
  </div>
</section>
"""

idx = site / "index.html"
t = idx.read_text(encoding="utf-8")
if 'id="pymason"' not in t:
    inserted = False
    for anchor in ['id="studio"', "Music funds the rest", 'id="about"']:
        ap = t.find(anchor)
        if ap <= 0:
            continue
        sec = t.rfind("<section", 0, ap)
        if sec < 0:
            sec = t.rfind('<div class="relative w-full overflow-hidden"', 0, ap)
        if sec > 0:
            t = t[:sec] + band + t[sec:]
            print("inserted pymason band before", anchor)
            inserted = True
            break
    if not inserted:
        fp = t.find("<footer")
        if fp > 0:
            t = t[:fp] + band + t[fp:]
            print("inserted pymason before footer")
    idx.write_text(t, encoding="utf-8")
else:
    print("pymason already in index")

pp = site / "products.html"
pt = pp.read_text(encoding="utf-8")
if "pymason.html" not in pt:
    main = pt.find("<main")
    if main > 0:
        end_main_open = pt.find(">", main) + 1
        inject = """
<section class="relative py-12" style="background: rgb(10, 7, 6);"><div class="container mx-auto px-6">
  <div class="p-6" style="border: 1px solid rgba(255, 122, 38, 0.28); border-radius: 2px;">
    <div class="text-xs uppercase tracking-widest mb-2" style="color: rgb(255, 122, 38); letter-spacing: 0.15em;">Also available</div>
    <h2 style="font-family: var(--font-heading); color: rgb(245, 237, 228); font-size: 1.6rem; margin: 0 0 0.5rem;">PyMason — free feedback trial</h2>
    <p style="color: rgba(245,237,228,0.7); font-family: var(--font-sans); margin: 0 0 1rem;">Visual Python studio. Thoughtful feedback expected after use.</p>
    <a href="pymason.html" style="color: rgb(255, 122, 38); font-family: var(--font-sans);">Open PyMason page →</a>
    &nbsp;·&nbsp;
    <a href="/pymason/" style="color: rgb(255, 122, 38); font-family: var(--font-sans);">Start trial →</a>
  </div>
</div></section>
"""
        pt = pt[:end_main_open] + inject + pt[end_main_open:]
        pp.write_text(pt, encoding="utf-8")
        print("products.html pymason banner added")
else:
    print("products already links pymason")

# Restyle pymason.html to match Airo dark page more closely — keep as-is if ok
print("done")
