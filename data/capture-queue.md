# Meet capture queue

Working list for building the results archive. Tick items off as they land in
`data/meets/`.

## Why this list exists

Meets hosted on `results.mdtimingllc.com` (the Firebase-backed team pages) and
`athletic.net` are JavaScript applications that load their results from
Firebase. A crawler sees an empty page shell, so the Wayback Machine cannot
preserve them, and the Firebase REST endpoint refuses unauthenticated reads
(`Permission denied`); `edge.athletic.net` returns 403 on every path. There is
no way to pull these from the link alone.

Verified 2026-07-25 across all 39 source links: 12 are genuinely archived, 19
are empty shells, 7 were never archived. The only durable copy is the one we
hold ourselves, in `data/meets/`.

## Needs manual capture (7 remaining)

Open the link, click **Hardy**, copy the whole team result, paste it into a
Claude Code session. The `/teams` suffix goes straight to the team picker.

| ✓ | Season | Date | Meet | Link |
|---|--------|------|------|------|
| ☐ | Indoor | 2025-01-15 | DCIAA MS/HS Developmental | https://www.athletic.net/TrackAndField/meet/575023/results |
| ☐ | Outdoor | 2023-05-02 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/24466/teams |
| ☐ | Outdoor | 2024-05-20 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/38240/teams |
| ☐ | Outdoor | 2024-05-30 | DCIAA MS Championship | https://results.mdtimingllc.com/meets/38470/teams |
| ☐ | Outdoor | 2025-05-09 | DCIAA MS Developmental | https://www.athletic.net/TrackAndField/meet/607132/results |
| ☐ | Outdoor | 2025-05-15 | St Albans / National Cathedral | https://www.athletic.net/TrackAndField/meet/610090/results |
| ☐ | Outdoor | 2025-05-19 | DCIAA MS Championship | https://www.athletic.net/TrackAndField/meet/613581/results |

This is the complete remaining list — every other outdoor/indoor T&F source
link on the site is now either automated (below) or was manually captured.

Done manually:

| ✓ | Season | Date | Meet | File |
|---|--------|------|------|------|
| ☑ | Outdoor | 2023-05-23 | DCIAA MS Championship | `data/meets/2023-05-23-dciaa-es-ms-champs.json` |
| ☑ | Indoor | 2018-01-03 | DCIAA Developmental Meet 4 | `data/meets/2018-01-03-dciaa-developmental.json` |
| ☑ | Indoor | 2018-01-24 | DCIAA MS/HS Championship | `data/meets/2018-01-24-dciaa-ms-hs-championship.json` |
| ☑ | Indoor | 2024-01-18 | DCIAA MS Developmental Meet 1 | `data/meets/2024-01-18-dciaa-ms-developmental.json` |
| ☑ | Indoor | 2025-02-25 | DCIAA MS Championship | `data/meets/2025-02-25-dciaa-es-ms-championship.json` |
| ☑ | Outdoor | 2018-04-12 | DCIAA MS Developmental | `data/meets/2018-04-12-dciaa-ms-developmental.json` |
| ☑ | Outdoor | 2018-04-19 | DCIAA ES/MS Dual – Eastern | `data/meets/2018-04-19-dciaa-es-ms-dual-eastern.json` |
| ☑ | Outdoor | 2018-05-22 | DCIAA MS Championship | `data/meets/2018-05-22-dciaa-ms-championship.json` |
| ☑ | Outdoor | 2019-04-03 | DCIAA MS Developmental | `data/meets/2019-04-03-dciaa-ms-developmental.json` |
| ☑ | Outdoor | 2021-05-18 | DCIAA MS Developmental | `data/meets/2021-05-18-dciaa-ms-developmental.json` |

## Automated — done (18 meets, 802 marks)

`tools/parse-hytek.ps1` reads the static Hy-Tek export format, wherever it's
hosted, and `tools/harvest-static-meets.ps1` runs it over every known static
link and writes straight into `data/meets/`. Re-run after adding a new static
source; it overwrites in place and is safe to run repeatedly.

Two hosts turned out to carry this same format once inspected directly, not
just `results2.mdtimingllc.com`:
- **`results2.mdtimingllc.com`** (12 meets) — the original legacy host.
- **`milesplit.com` / `dc.milesplit.com`** (7 meets) — same underlying export,
  three format variants: classic bib-after-name, a `#`-prefixed bib, and a
  newer "Athlete / Yr / Team / Mark" layout with no squad-letter quotes on
  relay rows at all (letter is inferred from order of appearance).

Two meets on `results2.mdtimingllc.com` genuinely have zero Hardy entries and
are correctly not written: 2016-12-07 and 2017-01-25 — your own source notes
say "DCIAA but no Deal and Hardy" for both.

One meet was found this way that wasn't on anyone's radar: the outdoor
**2025-04-03 developmental** (`milesplit.com/meets/675779`) is now captured —
43 marks including Ulyses Stewart Torres's 400m and the boys 4x100 relay. It
had never been added to the manual list above; this closes that gap.

**Not building for now:** TFRRS (`tfrrs.org`) hosts the 2015 and 2016 indoor
championships. Confirmed static and does contain real Hardy marks, but it's a
genuinely different shape — an event-index page linking out to one HTML page
per event (~25+ fetches per meet) rather than one flat Hy-Tek dump — so it
would need its own parser. Worth doing later; two meets, not urgent.

## Data-quality findings from the harvest

- ~~Samiah Bucey-Onyekwere's 100m/200m records attributed to the wrong
  meet~~ — **fixed.** `trackwall_outdoor.html` credited her 12.80/26.30 to the
  5/24/2022 championship, but that meet's raw results show her running
  13.36/26.61 there; 12.80/26.30 sit in the *Seed* column of that same row,
  not Finals, and actually belong to the 5/10/2022 developmental meet
  (`data/meets/2022-05-10-dciaa-ms-developmental.json`). Date corrected on
  both rows; the 400m row was already right (1:01.79 finals there, matching
  the site's 1:01.8) and was left alone.
- Sayum Iddamalagoda's indoor 55m record reads 7.6 on the site; the harvested
  2023-01-11 results say 7.69. Still unresolved — a decision, not a silent
  overwrite.
- **The site's boys 4x400m indoor record may be wrong.** `trackwall_indoor.html`
  credits Leen/Munzer/Consentino/Stewart Torres with 4:28.2 at the 2025-02-25
  DCIAA MS Championship, but the team view for that exact meet, with the same
  four legs in the same order, gives 4:30.30. Everything else pulled from this
  meet matches the site exactly (McMahan's 7.59, Consentino's 5:21.62, both
  girls relays), so this isn't a transcription slip on our end - it's a real
  conflict between the site and the meet's own results. Unresolved; see
  `data/meets/2025-02-25-dciaa-es-ms-championship.json`.
- ~~Two misspellings propagated from the automated harvest~~ — **fixed.**
  "Sayum Iddamlagoda" (missing the second a) in the 2022-04-28, 2022-05-10 and
  2022-05-24 meets, and "Zo Antczak-Chung" (missing the e) in 2019-04-11 -
  both are simply how those specific meets' raw results printed the names.
  Corrected to match the spelling used consistently everywhere else in the
  archive (Iddamalagoda, Zoe Antczak-Chung).
- Two more athlete names in the 2019-04-03 meet arrived from the team view
  garbled - surname printed twice, given name dropped ("Andersson-Potterv
  Andersson-Potterv", "Taliaferro Brunn Taliaferro Brunn"). Resolved to Mats
  Andersson-Potterveld and Amirah Taliaferro Brunn, matching their spelling in
  meets already in the archive. A third, "L Rosales Rivera", couldn't be
  resolved against anything on file and is kept as shown.

## Open issues

- Cross country has no sources table at all yet, so no XC meets are listed
  here or captured as data.
- The 2025/26 school year is missing entirely from every page.

## Archive design

Two layers, so presentation stays cheap to change:

1. **Data** — one JSON per meet in `data/meets/`, holding the full Hardy team
   result: place, athlete, gender, event, mark, metric conversion, points,
   heat/flight, grade year, plus relay squads. Schema is set by the 2023 file.
   This is the archive, and it depends on nothing external.
2. **Pages** — generated from that data via `tools/build-archive.ps1`, which
   produces `results-archive.html`. Never hand-edit that file; rerun the
   script after any change under `data/meets/`. It's search-first (nothing
   shows until you type), one card per athlete per meet, with relay legs
   folded into the runner's own card wherever the leg name can be matched
   back to a known athlete in the same meet. Later, the same data can drive
   record progressions and deep all-time lists on the record boards too.
