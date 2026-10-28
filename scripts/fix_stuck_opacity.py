#!/usr/bin/env python3
import re
from pathlib import Path

site = Path(__file__).resolve().parents[1] / "site"
for p in site.glob("*.html"):
    if p.name == "pymason.html":
        continue
    t = p.read_text(encoding="utf-8")
    n = re.sub(
        r'style="opacity:\s*0;\s*transform:\s*translateY\([^)]+\);"',
        'style="opacity: 1; transform: none;"',
        t,
    )
    n = re.sub(
        r"style='opacity:\s*0;\s*transform:\s*translateY\([^)]+\);'",
        "style='opacity: 1; transform: none;'",
        n,
    )
    stuck = len(re.findall(r"opacity:\s*0;\s*transform:\s*translateY", n))
    if n != t:
        p.write_text(n, encoding="utf-8")
        print("rewrote", p.name, "stuck left", stuck)
    else:
        print(p.name, "stuck", stuck)
