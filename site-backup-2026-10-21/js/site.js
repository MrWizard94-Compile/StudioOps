/* WPAI captured-site enhancements — re-adds the interactivity stripped with
   React: mobile nav, contact-form mailto, and scroll-reveal. Self-contained
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

  // ---- contact form → mailto (no backend needed) ----
  var form = document.querySelector("form");
  if (form && form.querySelector('[name="message"]')) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      if (form.elements._gotcha && form.elements._gotcha.value) return; // spam honeypot
      var topic = (form.elements.topic && form.elements.topic.value) || "General";
      var name = (form.elements.name && form.elements.name.value) || "";
      var email = (form.elements.email && form.elements.email.value) || "";
      var message = (form.elements.message && form.elements.message.value) || "";
      if (!message.trim()) return;
      var subject = encodeURIComponent("[WPAI] " + topic + (name ? " — " + name : ""));
      var body = encodeURIComponent(
        message + "\n\n—\n" + (name ? "Name: " + name + "\n" : "") + (email ? "Email: " + email + "\n" : "")
      );
      window.location.href = "mailto:rob@wpaistudio.net?subject=" + subject + "&body=" + body;
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
