# Deploy wpaistudio.net — Cloudflare Pages (free, owned, no lock-in)

The site to deploy is the **`dist/`** folder (5 pages + assets + js, ~5.4 MB).
It is the real Airo design captured as static files — no GoDaddy, no monthly fee.

## 1. Put the site on Cloudflare Pages (free)
1. Create a free account at **dash.cloudflare.com**.
2. **Workers & Pages → Create → Pages → Upload assets** (direct upload, no git needed).
3. Project name: `wpaistudio` (or anything).
4. **Drag the entire `dist/` folder** in. Deploy.
5. You get a live `https://wpaistudio.pages.dev` — open it, click every nav link, check mobile.

## 2. Point wpaistudio.net at it
Recommended (also unlocks free email): **move DNS to Cloudflare.**
1. In Cloudflare: **Add a site** → `wpaistudio.net` → Free plan. It imports your current records.
2. Cloudflare shows two **nameservers**. In **GoDaddy → Domain → Nameservers**, switch to those two. (Propagates in minutes–hours.)
3. Back in the Pages project → **Custom domains → Set up a custom domain** → add `wpaistudio.net` and `www.wpaistudio.net`. Cloudflare wires the DNS + free SSL automatically.

(Alternative without moving nameservers: in GoDaddy DNS add a CNAME `www → wpaistudio.pages.dev` and use Cloudflare's apex instructions — but the nameserver move is cleaner and required for the free email below.)

## 3. Free email rob@wpaistudio.net (Cloudflare Email Routing)
Only works once the domain's nameservers are on Cloudflare (step 2).
1. Cloudflare → your domain → **Email → Email Routing → Enable** (auto-adds MX records).
2. **Destination addresses** → add your Gmail → click the verify link Gmail receives.
3. **Routing rules** → Custom address → `rob@wpaistudio.net` → forward to your Gmail.
Done — mail to rob@ lands in Gmail, $0.

## Recurring cost
Domain renewal only. Hosting $0, email $0.

## To update the site later
Re-upload `dist/` in the Pages project (or connect a git repo for auto-deploys).
