/* WPAI studio site chrome — mobile nav, year, contact form (mailto). */
(function () {
  "use strict";

  var yearEl = document.getElementById("y");
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());

  var toggle = document.querySelector("[data-nav-toggle]");
  var panel = document.querySelector("[data-nav-panel]");
  if (toggle && panel) {
    toggle.addEventListener("click", function () {
      var open = panel.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
    panel.querySelectorAll("a").forEach(function (a) {
      a.addEventListener("click", function () {
        panel.classList.remove("is-open");
        toggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // Sticky header shadow
  var header = document.querySelector(".site-header");
  if (header) {
    var onScroll = function () {
      header.classList.toggle("is-scrolled", window.scrollY > 8);
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
  }

  // Contact form → mailto (no backend required)
  var form = document.getElementById("contact-form");
  if (form) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var topic = (form.elements.topic && form.elements.topic.value) || "General";
      var name = (form.elements.name && form.elements.name.value) || "";
      var email = (form.elements.email && form.elements.email.value) || "";
      var message = (form.elements.message && form.elements.message.value) || "";
      if (!message.trim()) return;

      var subject = encodeURIComponent("[WPAI] " + topic + (name ? " — " + name : ""));
      var body = encodeURIComponent(
        message +
          "\n\n—\n" +
          (name ? "Name: " + name + "\n" : "") +
          (email ? "Email: " + email + "\n" : "")
      );
      window.location.href = "mailto:rob@wpaistudio.net?subject=" + subject + "&body=" + body;

      var ok = document.getElementById("contact-success");
      if (ok) {
        ok.hidden = false;
        form.hidden = true;
      }
    });
  }

  // Scroll-reveal (replaces Airo's Motion; progressive enhancement).
  // Below-the-fold only, so hiding never causes an above-fold flash.
  var revealSel = ".section-head, .card, .lane, .panel, .lane-detail, .feature, .pillar, .step, .attr, .contact-card";
  var items = Array.prototype.slice.call(document.querySelectorAll(revealSel));
  if ("IntersectionObserver" in window && items.length) {
    items.forEach(function (el) {
      el.classList.add("reveal");
      var parent = el.parentElement;
      if (parent) {
        var sibs = Array.prototype.slice.call(parent.children).filter(function (c) {
          return items.indexOf(c) !== -1;
        });
        var i = sibs.indexOf(el);
        if (i > 0) el.style.setProperty("--reveal-delay", Math.min(i, 5) * 90 + "ms");
      }
    });
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (e) {
          if (e.isIntersecting) {
            e.target.classList.add("in");
            io.unobserve(e.target);
          }
        });
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.08 }
    );
    items.forEach(function (el) {
      io.observe(el);
    });
  }

  // Active nav link
  var path = (location.pathname.split("/").pop() || "index.html").toLowerCase();
  if (!path || path === "") path = "index.html";
  document.querySelectorAll("[data-nav] a").forEach(function (a) {
    var href = (a.getAttribute("href") || "").toLowerCase();
    if (href === path || (path === "index.html" && (href === "/" || href === "index.html" || href === "./"))) {
      a.classList.add("is-active");
    }
  });
})();
