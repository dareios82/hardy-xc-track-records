// Search for the record boards and the results archive.
//
// Two shapes of content: table rows on the record pages, and result cards on
// the archive. Two modes: "filter" (default, everything visible until you
// narrow it) and "reveal" (nothing visible until you search, for the archive
// where there is far too much to show at once).
//
// Team rosters abbreviate given names ("M. Caldara") while individual lists
// spell them out ("Maja Caldara"), so matching is initial-aware and works in
// both directions without needing the full names on file.
(function () {
  "use strict";

  var input = document.querySelector("[data-search]");
  if (!input) return;

  var mode = input.getAttribute("data-search-mode") === "reveal" ? "reveal" : "filter";
  var status = document.querySelector("[data-search-status]");
  var empty = document.querySelector("[data-search-empty]");
  var prompt = document.querySelector("[data-search-prompt]");
  var asides = toArray(document.querySelectorAll("[data-hide-on-search]"));
  var cards = toArray(document.querySelectorAll(".result-card"));
  var tables = toArray(document.querySelectorAll(".record-table:not(.sources)"));

  function toArray(nodes) { return Array.prototype.slice.call(nodes); }

  // Drop the punctuation that varies between how a name is written in an
  // individual list and in a roster, so "Mazzei-Paterni" and "Mazzei Paterni"
  // compare equal.
  function normalize(s) {
    return s
      .toLowerCase()
      .replace(/[.'’]/g, "")
      .replace(/[-‐-―]/g, " ")
      .replace(/\s+/g, " ")
      .trim();
  }

  function escapeRx(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); }

  function buildMatcher(q) {
    var toks = q.split(" ").filter(Boolean);
    var tests = [function (t) { return t.indexOf(q) !== -1; }];

    if (toks.length >= 2) {
      var first = toks[0];
      var rest = toks.slice(1).map(escapeRx).join("\\s+");

      // "Maja Caldara" -> also match a roster's "M. Caldara".
      tests.push(new RegExp("\\b" + escapeRx(first.charAt(0)) + "\\s+" + rest));

      // "M. Caldara" -> also match the spelled-out "Maja Caldara". Only when
      // an initial was actually typed, so a full given name still has to match
      // in full and won't collide with a different M. Caldara.
      if (first.length === 1) {
        tests.push(new RegExp("\\b" + escapeRx(first) + "[a-z]+\\s+" + rest));
      }
    }

    return function (t) {
      for (var i = 0; i < tests.length; i++) {
        var test = tests[i];
        if (typeof test === "function" ? test(t) : test.test(t)) return true;
      }
      return false;
    };
  }

  // Join cells with a space rather than reading textContent off the row:
  // otherwise the points cell runs into the roster ("...dc 1 28" + "M. Caldara"
  // becomes "dc128m caldara") and the initial no longer starts a word.
  function rowText(row) {
    return normalize(
      Array.prototype.map.call(row.cells, function (c) { return c.textContent; }).join(" ")
    );
  }

  var items = [];
  if (cards.length) {
    cards.forEach(function (el) {
      items.push({ el: el, text: normalize(el.textContent) });
    });
  } else {
    tables.forEach(function (table) {
      Array.prototype.forEach.call(table.tBodies[0].rows, function (row) {
        items.push({ el: row, text: rowText(row) });
      });
    });
  }

  function apply() {
    var q = normalize(input.value);
    var idle = q === "";
    var match = idle ? null : buildMatcher(q);
    var shown = 0;

    items.forEach(function (item) {
      // In reveal mode an empty box means show nothing, not show everything.
      var hit = idle ? (mode === "filter") : match(item.text);
      item.el.classList.toggle("is-hidden", !hit);
      if (hit) shown++;
    });

    // A section disappears once none of its rows survive the filter.
    tables.forEach(function (table) {
      var visible = Array.prototype.some.call(
        table.tBodies[0].rows,
        function (r) { return !r.classList.contains("is-hidden"); }
      );
      var section = table.closest(".section");
      if (section) section.classList.toggle("is-hidden", !visible);
    });

    // The sources list isn't searchable, so it just gets out of the way.
    asides.forEach(function (el) { el.classList.toggle("is-hidden", !idle); });

    if (prompt) prompt.classList.toggle("is-hidden", !idle);
    if (empty) empty.classList.toggle("is-hidden", idle || shown !== 0);

    if (status) {
      if (idle) {
        status.textContent = "";
      } else if (shown === 0) {
        status.textContent = "Nothing matches “" + input.value.trim() + "”.";
      } else {
        var noun = cards.length ? (shown === 1 ? "result card" : "result cards") : "performances";
        status.textContent = cards.length
          ? "Showing " + shown + " " + noun + "."
          : "Showing " + shown + " of " + items.length + " performances.";
      }
    }
  }

  // Example chips on the archive's empty state.
  toArray(document.querySelectorAll("[data-example]")).forEach(function (btn) {
    btn.addEventListener("click", function () {
      input.value = btn.getAttribute("data-example");
      input.focus();
      apply();
    });
  });

  input.addEventListener("input", apply);
  input.addEventListener("search", apply);
  apply();
})();
