/* WPAI captured-site enhancements — re-adds the interactivity stripped with
   React: mobile nav, contact form (mailto + copy fallback, or a form endpoint),
   and scroll-reveal. Self-contained
   (injects its own CSS). Progressive: with JS off, desktop still works fully. */
(function () {
  "use strict";

  // ---- inject enhancement styles ----
  var css = document.createElement("style");
  css.textContent = [
    ".wpai-mnav{position:fixed;inset:0;z-index:9999;background:rgba(10,7,6,.975);",
    "display:none;flex-direction:column;align-items:center;justify-content:center;",
    "gap:1.5rem;backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px)}",
    ".wpai-mnav.open{display:flex}",
    ".wpai-mnav a{color:#f5eee0;font-family:Cinzel,Georgia,serif;font-size:1.6rem;",
    "text-decoration:none;letter-spacing:.06em;text-transform:uppercase}",
    ".wpai-mnav a:hover{color:#ff7a26}",
    ".wpai-mnav .wpai-close{position:absolute;top:1rem;right:1.3rem;font-size:2.2rem;",
    "line-height:1;color:#ff7a26;background:none;border:none;cursor:pointer}",
  ].join("");
  document.head.appendChild(css);

  // ---- mobile nav (hijack Airo's hamburger; build a menu React never rendered) ----
  var toggle = document.querySelector('button[aria-label="Toggle menu"]');
  var raw = [].slice.call(document.querySelectorAll("header nav a, header a"));
  var seen = {},
    links = [];
  raw.forEach(function (a) {
    var t = a.textContent.trim();
    var k = (a.getAttribute("href") || "") + "|" + t;
    if (t && !seen[k]) {
      seen[k] = 1;
      links.push(a);
    }
  });
  if (toggle && links.length) {
    var menu = document.createElement("div");
    menu.className = "wpai-mnav";
    var closeBtn = document.createElement("button");
    closeBtn.className = "wpai-close";
    closeBtn.setAttribute("aria-label", "Close menu");
    closeBtn.innerHTML = "&times;";
    menu.appendChild(closeBtn);
    links.forEach(function (a) {
      var l = document.createElement("a");
      l.href = a.getAttribute("href");
      l.textContent = a.textContent.trim();
      if (a.getAttribute("rel")) l.setAttribute("rel", a.getAttribute("rel"));
      menu.appendChild(l);
    });
    document.body.appendChild(menu);
    var close = function () {
      menu.classList.remove("open");
      toggle.setAttribute("aria-expanded", "false");
      document.body.style.overflow = "";
    };
    var open = function () {
      menu.classList.add("open");
      toggle.setAttribute("aria-expanded", "true");
      document.body.style.overflow = "hidden";
    };
    toggle.addEventListener("click", function (e) {
      e.preventDefault();
      menu.classList.contains("open") ? close() : open();
    });
    closeBtn.addEventListener("click", close);
    menu.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", close);
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") close();
    });
  }

  // ---- contact form ----
  // FORM_ENDPOINT: leave "" to use the visitor's email app (mailto).
  // To switch to a form service later, paste its URL here, e.g.
  //   var FORM_ENDPOINT = "https://formspree.io/f/xxxxxxxx";
  // That is the only change needed: the form then POSTs there and shows a
  // thank-you, falling back to the copy-and-email panel if the request fails.
  var FORM_ENDPOINT = "";
  var CONTACT_EMAIL = "rob@wpaistudio.net";

  var form = document.querySelector("form");
  if (form && form.querySelector('[name="message"]')) {
    var field = function (n) {
      return (form.elements[n] && form.elements[n].value) || "";
    };
    var compose = function () {
      var topic = field("topic") || "General";
      var name = field("name").trim();
      var email = field("email").trim();
      var message = field("message");
      return {
        subject: "[WPAI] " + topic + (name ? " — " + name : ""),
        text:
          message + "\n\n—\n" + (name ? "Name: " + name + "\n" : "") + (email ? "Email: " + email + "\n" : ""),
      };
    };

    var copyText = function (text, btn) {
      var fallback = function () {
        var ta = document.createElement("textarea");
        ta.value = text;
        ta.setAttribute("readonly", "");
        ta.style.cssText = "position:fixed;top:-1000px;opacity:0";
        document.body.appendChild(ta);
        ta.select();
        var ok = false;
        try { ok = document.execCommand("copy"); } catch (err) {}
        document.body.removeChild(ta);
        return ok;
      };
      var done = function (ok) {
        var label = btn.getAttribute("data-label");
        btn.textContent = ok ? "Copied ✓" : "Press Ctrl+C to copy";
        setTimeout(function () { btn.textContent = label; }, 2200);
      };
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(function () { done(true); }, function () { done(fallback()); });
      } else {
        done(fallback());
      }
    };

    var panel = document.createElement("div");
    panel.className = "wpai-form-panel";
    panel.setAttribute("role", "status");
    panel.setAttribute("aria-live", "polite");
    panel.hidden = true;
    form.parentNode.insertBefore(panel, form.nextSibling);

    var btnCss =
      "display:inline-flex;align-items:center;padding:.6rem 1.1rem;border:1px solid rgba(255,122,38,.45);" +
      "border-radius:2px;background:transparent;color:#f5ede4;font:600 .85rem var(--font-sans);" +
      "letter-spacing:.04em;cursor:pointer";
    var showPanel = function (kind, msg) {
      panel.innerHTML = "";
      panel.style.cssText =
        "margin-top:1.5rem;padding:1.25rem 1.4rem;border:1px solid rgba(255,122,38,.35);border-radius:2px;" +
        "background:rgba(255,122,38,.06);font-family:var(--font-sans);color:rgba(245,237,228,.8);line-height:1.6";
      var p = document.createElement("p");
      p.style.margin = "0 0 .9rem";
      panel.appendChild(p);
      if (kind === "sent") {
        p.style.margin = "0";
        p.textContent = "Message sent. Thanks — I'll get back to you soon.";
      } else {
        p.appendChild(document.createTextNode(
          kind === "failed" ? "That didn't go through. Please email " : "If your email app didn't open, email "
        ));
        var strong = document.createElement("strong");
        strong.style.color = "#ff7a26";
        strong.textContent = CONTACT_EMAIL;
        p.appendChild(strong);
        p.appendChild(document.createTextNode(" — your message is ready to paste."));
        var row = document.createElement("div");
        row.style.cssText = "display:flex;flex-wrap:wrap;gap:.75rem";
        [
          ["Copy email address", CONTACT_EMAIL],
          ["Copy message text", "Subject: " + msg.subject + "\n\n" + msg.text],
        ].forEach(function (b) {
          var btn = document.createElement("button");
          btn.type = "button";
          btn.textContent = b[0];
          btn.setAttribute("data-label", b[0]);
          btn.style.cssText = btnCss;
          btn.addEventListener("click", function () { copyText(b[1], btn); });
          row.appendChild(btn);
        });
        panel.appendChild(row);
      }
      panel.hidden = false;
    };

    form.addEventListener("submit", function (e) {
      e.preventDefault();
      if (form.elements._gotcha && form.elements._gotcha.value) return; // spam honeypot
      if (!field("message").trim() || (form.checkValidity && !form.checkValidity())) {
        if (form.reportValidity) form.reportValidity();
        return;
      }
      var msg = compose();
      if (FORM_ENDPOINT) {
        var data = new FormData(form);
        data.append("_subject", msg.subject);
        fetch(FORM_ENDPOINT, { method: "POST", body: data, headers: { Accept: "application/json" } })
          .then(function (r) {
            if (!r.ok) throw new Error("HTTP " + r.status);
            form.reset();
            showPanel("sent", msg);
          })
          .catch(function () { showPanel("failed", msg); });
        return;
      }
      window.location.href =
        "mailto:" + CONTACT_EMAIL + "?subject=" + encodeURIComponent(msg.subject) + "&body=" + encodeURIComponent(msg.text);
      // There's no way to know whether an email app opened, so always offer the fallback.
      setTimeout(function () { showPanel("mailto", msg); }, 400);
    });
  }

  // ---- scroll-reveal (re-add Airo's Framer Motion whileInView) ----
  // The React capture froze every section wrapper in its initial hidden state
  // (opacity:0; transform:translateY(28-32px)) and dropped the motion runtime
  // that revealed them on scroll — so everything below the hero stayed invisible.
  // Reveal each wrapper as it scrolls into view (or immediately if it is already
  // on screen). Selector matches only those frozen wrappers: inline opacity is
  // exactly "0" and not !important, which excludes decorative low-opacity layers
  // (opacity:0.x) and the hidden ad iframes (opacity:0 !important).
  var revealTargets = [].slice
    .call(document.querySelectorAll("div[style]"))
    .filter(function (el) {
      return (
        el.style.opacity === "0" &&
        el.style.getPropertyPriority("opacity") !== "important"
      );
    });
  if (revealTargets.length) {
    var reveal = function (el) {
      el.style.opacity = "1";
      el.style.transform = "none";
    };
    var reduceMotion =
      window.matchMedia &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduceMotion || !("IntersectionObserver" in window)) {
      // Content first: show everything at once, skip the animation.
      revealTargets.forEach(reveal);
    } else {
      revealTargets.forEach(function (el) {
        el.style.transition = "opacity .6s ease, transform .6s ease";
      });
      var io = new IntersectionObserver(
        function (entries, obs) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              reveal(entry.target);
              obs.unobserve(entry.target);
            }
          });
        },
        { rootMargin: "0px 0px -8%", threshold: 0.1 }
      );
      revealTargets.forEach(function (el) {
        io.observe(el);
      });
    }
  }

})();
