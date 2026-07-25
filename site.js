// Name search for the record boards. Filters rows in every table on the page
// except the sources tables, and hides sections that end up empty.
//
// Team rosters abbreviate given names ("M. Caldara") while the individual
// lists spell them out ("Maja Caldara"), so matching is initial-aware and
// works in both directions without needing the full names on file.
(function () {
  "use strict";

  var input = document.querySelector("[data-search]");
  if (!input) return;

  var status = document.querySelector("[data-search-status]");
  var empty = document.querySelector("[data-search-empty]");
  var tables = Array.prototype.slice.call(
    document.querySelectorAll(".record-table:not(.sources)")
  );
  var asides = Array.prototype.slice.call(
    document.querySelectorAll("[data-hide-on-search]")
  );

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

  function escapeRx(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  function buildMatcher(q) {
    var toks = q.split(" ").filter(Boolean);
    var tests = [function (t) { return t.indexOf(q) !== -1; }];

    if (toks.length >= 2) {
      var first = toks[0];
      var rest = toks.slice(1).map(escapeRx).join("\\s+");

      // "Maja Caldara" -> also match a roster's "M. Caldara".
      tests.push(new RegExp("\\b" + escapeRx(first.charAt(0)) + "\\s+" + rest));

      // "M. Caldara" -> also match the individual list's "Maja Caldara".
      // Only when an initial was actually typed, so a full given name still
      // has to match in full and won't collide with a different M. Caldara.
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
      Array.prototype.map
        .call(row.cells, function (c) { return c.textContent; })
        .join(" ")
    );
  }

  var rows = [];
  tables.forEach(function (table) {
    Array.prototype.forEach.call(table.tBodies[0].rows, function (row) {
      rows.push({ el: row, text: rowText(row) });
    });
  });

  function apply() {
    var q = normalize(input.value);
    var match = q === "" ? null : buildMatcher(q);
    var shown = 0;

    rows.forEach(function (row) {
      var hit = !match || match(row.text);
      row.el.classList.toggle("is-hidden", !hit);
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
    asides.forEach(function (el) {
      el.classList.toggle("is-hidden", q !== "");
    });

    if (empty) empty.classList.toggle("is-hidden", shown !== 0);

    if (status) {
      if (q === "") {
        status.textContent = "";
      } else {
        status.textContent =
          shown === 0
            ? "No performances match “" + input.value.trim() + "”."
            : "Showing " + shown + " of " + rows.length + " performances.";
      }
    }
  }

  input.addEventListener("input", apply);
  input.addEventListener("search", apply);
  apply();
})();
