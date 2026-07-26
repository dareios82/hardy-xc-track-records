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

## Needs manual capture (none remaining)

Every outdoor/indoor T&F source link on the site has now either been
automated (below) or manually captured. The list below is kept for the
record of how each meet was sourced.

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
| ☑ | Outdoor | 2023-05-02 | DCIAA MS Developmental Meet 2 | `data/meets/2023-05-02-dciaa-ms-developmental.json` |
| ☑ | Outdoor | 2024-05-20 | DCIAA MS Developmental Meet 3 | `data/meets/2024-05-20-dciaa-ms-developmental.json` |
| ☑ | Outdoor | 2024-05-30 | DCIAA MS Championship | `data/meets/2024-05-30-dciaa-ms-championship.json` |
| ☑ | Outdoor | 2025-05-19 | DCIAA MS Championship | `data/meets/2025-05-19-dciaa-ms-championship.json` |
| ☑ | Indoor | 2025-01-15 | DCIAA MS/HS Developmental #2 | `data/meets/2025-01-15-dciaa-ms-hs-developmental.json` |
| ☑ | Outdoor | 2025-05-09 | DCIAA MS Challenge | `data/meets/2025-05-09-dciaa-ms-developmental.json` |
| ☑ | Outdoor | 2025-05-15 | St Albans / National Cathedral | `data/meets/2025-05-15-st-albans-national-cathedral.json` |
| ☑ | Outdoor | 2026-03-24 | DCIAA HS/MS Developmental #1 | `data/meets/2026-03-24-dciaa-hs-ms-developmental.json` |
| ☑ | Outdoor | 2026-05-02 | DCIAA MS/HS Developmental #2 | `data/meets/2026-05-02-dciaa-ms-hs-developmental.json` |
| ☑ | Outdoor | 2026-05-04 | Quakers Mini Invite | `data/meets/2026-05-04-quakers-mini-invite.json` |
| ☑ | Outdoor | 2026-05-13 | DCIAA MS Championship | `data/meets/2026-05-13-dciaa-ms-championship.json` |
| ☑ | Outdoor | 2026-05-21 | Carlos Parson Invitational | `data/meets/2026-05-21-carlos-parson-invitational.json` |
| ☑ | Indoor | 2026-01-05 | DCIAA ES/MS Developmental #1 | `data/meets/2026-01-05-dciaa-es-ms-developmental.json` |
| ☑ | Indoor | 2026-01-14 | DCIAA ES/MS Developmental #2 | `data/meets/2026-01-14-dciaa-es-ms-developmental.json` |
| ☑ | Indoor | 2026-02-24 | DCIAA ES/MS Championship | `data/meets/2026-02-24-dciaa-es-ms-championship.json` |
| ☑ | Indoor | 2015-01-28 | DCIAA MS Championship | `data/meets/2015-01-28-dciaa-ms-championship.json` |
| ☑ | Indoor | 2016-01-27 | DCIAA MS Championship | `data/meets/2016-01-27-dciaa-ms-championship.json` |

These eight complete the entire 2025/26 school year, both indoor and
outdoor - the school year that was previously missing from the site (see
Open Issues, below). The 2015-01-28 meet is the first one pulled from
TFRRS rather than a Hy-Tek/athletic.net source - see the Automated section
below for why that host needed a different approach.

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

**TFRRS (`tfrrs.org`):** hosted the 2015 and 2016 indoor championships - now
both fully captured by hand, one event page pasted at a time, both girls and
boys sections (see the manual-capture entries above). It's a genuinely
different shape from every other source in the archive — an event-index page
linking out to one HTML page per event, rather than one flat dump — so no
parser was built; wasn't worth it for two meets. None of the 2016 marks beat
any current record on either wall. This closes out TFRRS entirely.

## Data-quality findings from the harvest

- ~~Samiah Bucey-Onyekwere's 100m/200m records attributed to the wrong
  meet~~ — **fixed.** `trackwall_outdoor.html` credited her 12.80/26.30 to the
  5/24/2022 championship, but that meet's raw results show her running
  13.36/26.61 there; 12.80/26.30 sit in the *Seed* column of that same row,
  not Finals, and actually belong to the 5/10/2022 developmental meet
  (`data/meets/2022-05-10-dciaa-ms-developmental.json`). Date corrected on
  both rows; the 400m row was already right (1:01.79 finals there, matching
  the site's 1:01.8) and was left alone.
- ~~Sayum Iddamalagoda's indoor 55m record reads 7.6 on the site; the
  harvested 2023-01-11 results say 7.69~~ — **fixed.** Same meet, same
  athlete, no other explanation than the site rounding to one decimal place.
  Updated to 7.69.
- ~~The site's boys 4x400m indoor record may be wrong~~ — **not a conflict,
  confirmed correct.** `trackwall_indoor.html` credits Leen/Munzer/Consentino/
  Stewart Torres with 4:28.2 at the 2025-01-15 DCIAA MS/HS Developmental #2 -
  that's a different meet from the 2025-02-25 championship (where the same
  four legs ran 4:30.30, a separate real result, not a duplicate of the
  record). The team view for the January meet, now captured in
  `data/meets/2025-01-15-dciaa-ms-hs-developmental.json`, gives 4:28.20 for
  that exact squad, matching the site to the hundredth. The earlier note in
  this file mis-attributed the record to the wrong meet before that source
  was in hand; the site itself was right all along.
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
- ~~All four 2025 athletic.net meets truncate long names with "..."~~ —
  **resolved.** Most were resolved against spellings already confirmed
  elsewhere in the archive (Ulyses Stewart-Torres, Felipe Sebastian Mesa
  McGovern, Vanina Mazzei-Paterni). "Samantha Kirschenba..." had no prior
  match anywhere in the archive when first transcribed; confirmed correct by
  Dario as "Samantha Kirschenbaum" across all three meets where it appears
  (2025-05-09, 2025-05-15, 2025-05-19).
- **Full record-wall cross-check against the archive (2026-07-25).** Every
  mark on `trackwall_indoor.html` and `trackwall_outdoor.html` was checked
  against the best matching mark across all of `data/meets/`. Results:
  - Four small same-meet, same-athlete rounding gaps, fixed to the archive's
    more precise value: indoor boys 55m Dash (Iddamalagoda, above), indoor
    girls Shot Put (Laura McEwen, 22-05 → 22-05.25), indoor girls Triple Jump
    (Taylor McMahan, 31-04 → 31-04.5), indoor boys Long Jump (Cole Mandaza,
    14-01 → 14-01.25).
  - Three cases where the record was attributed to the wrong meet - the same
    athlete or squad ran faster at a different meet already in the archive:
    outdoor girls 100 Hurdles (Kymia Bridgett, 18.26 at the 5/2/2019
    championship → 18.05 at the 4/3/2019 developmental), outdoor girls
    4x100m (same four legs, 54.26 at the 5/19/2025 championship → 54.05 four
    days earlier at St Albans/NCS), outdoor boys 200m (Aaron Jones, 25.22 at
    the 5/12/2017 championship → 24.79 at the 4/11/2017 developmental).
    Fixed on both walls.
  - **A real parser bug found along the way:** the automated harvest of the
    2025-04-03 meet (`data/meets/2025-04-03-dciaa-ms-developmental.json`)
    had mislabeled two Discus results as "Shot Put" - James Crino's 78-4 and
    Ulyses Stewart Torres's 55-1, both physically impossible shot put
    distances. Re-fetched the source page directly to confirm both are
    genuine Discus marks and relabeled them. This was the only file found
    with this bug.
  - **Two large discrepancies, flagged for Dario to review - both confirmed
    and applied 2026-07-25:**
    - ~~Outdoor boys Discus: the wall credited Ulyses Stewart Torres with
      72-10 (5/9/2025)~~ — updated to James Crino, 80-00, 5/15/2025 at St
      Albans/NCS - his best of three, after the parser fix above also
      surfaced a 78-4 at an even earlier meet (4/3/2025).
    - ~~Outdoor boys Triple Jump: the wall credited George Sipher with 32-02
      (5/2/2023)~~ — updated to James Crino, 34-02.50, 5/19/2025 championship
      (marked PB in the source).
  - One wall entry had no matching source meet anywhere in the archive:
    indoor boys 4x200m (credited to "2017" with no meet named - no indoor
    2017 file exists). Still unverifiable; left untouched.
  - Everything else on both walls matched the archive exactly.
- ~~Indoor girls Long Jump record unverifiable (Nyla Ward, 1/28/2015 - no
  source meet existed)~~ — **confirmed correct (2026-07-26).** The 2015
  DCIAA MS Championship, captured from TFRRS, gives Nyla Ward 17-00 (5.18m),
  1st place - matching the wall exactly. Added the metric conversion to the
  wall's display since the source provides it.
- **2025/26 outdoor season captured and cross-checked (2026-07-26).** Five
  meets (DCIAA HS/MS Developmental #1 3/24, DCIAA MS/HS Developmental #2
  5/2, Quakers Mini Invite 5/4, DCIAA MS Championship 5/13, Carlos Parson
  Invitational 5/21) transcribed from athletic.net team-results pages and
  cross-checked against both outdoor record boards. No boys record fell.
  Girls results:
  - ~~Outdoor girls 1600m: Maja Caldara's own 5:35.75 (5/15/2025)~~ —
    updated to 5:29.03 (5/2/2026, DCIAA MS/HS Developmental #2). Same
    athlete beating her own mark a year later - no review needed.
  - **Three large discrepancies, flagged for Dario to review - each swaps in
    a different athlete or squad - all confirmed and applied 2026-07-26:**
    - ~~Outdoor girls 400m: the wall credited Samiah Bucey-Onyekwere with
      1:01.8 (5/24/2022)~~ — updated to Vanina Mazzei-Paterni, 1:00.42,
      5/13/2026 DCIAA MS Championship.
    - ~~Outdoor girls 800m: the wall credited Symbul Logan with 2:37.0
      (5/30/2024)~~ — updated to Vanina Mazzei-Paterni, 2:25.42, 5/13/2026
      DCIAA MS Championship - an 11.6-second improvement.
    - ~~Outdoor girls 4x400m: the wall credited Migliaccio/Pessey/Kravitz/
      Mazzei Paterni with 4:31.81 (5/9/2025)~~ — updated to a mostly
      different squad, Teresa Ljung, Maja Caldara, Isabel Gardiner, Vanina
      Mazzei-Paterni (only Mazzei-Paterni carries over), 4:25.62, 5/21/2026
      Carlos Parson Invitational. The third leg was originally transcribed
      as Seynabou Samba, who did not run this race - corrected to Isabel
      Gardiner after Dario caught it against the source.
  - ~~One name was truncated in the athletic.net view with no prior match
    anywhere in the archive to confirm against: "Piper Cudworth-MacG..."~~
    — **resolved.** Confirmed by Dario as Piper Cudworth-MacGillis; corrected
    in both the 2026-01-05 and 2026-05-02 files (originally guessed as
    "Cudworth-MacGregor").
  - `tools/build-archive.ps1`'s non-result filter didn't recognize "NT" (no
    time), printed by athletic.net for Seynabou Samba's scratched 200m at
    the 2026 championship. Added to the filter alongside DNS/DNF/etc.
- **2025/26 indoor season captured and cross-checked (2026-07-26).** Three
  meets (DCIAA ES/MS Developmental #1 1/5, DCIAA ES/MS Developmental #2
  1/14, DCIAA ES/MS Championship 2/24) transcribed from athletic.net
  team-results pages and cross-checked against the indoor record board.
  Unlike the outdoor sweep, this one turned up several real changes:
  - ~~Indoor girls 1600m: Maja Caldara's own 5:51.6 (1/15/2025)~~ — updated
    to 5:37.15 (1/14/2026, DCIAA ES/MS Developmental #2). Same athlete
    beating her own mark a year later - no review needed.
  - **Five large discrepancies, flagged for Dario to review - each swaps in
    a different athlete or squad - all confirmed and applied 2026-07-26:**
    - ~~Indoor girls 800m: the wall credited Julia Migliaccio with 2:47.1
      (2/25/2025)~~ — updated to Vanina Mazzei-Paterni, 2:33.64, 2/24/2026
      DCIAA ES/MS Championship - a 13.5-second improvement.
    - ~~Indoor boys 55m Dash: the wall credited Sayum Iddamalagoda with
      7.69 (1/11/2023)~~ — updated to Heyab Robel, 7.53, 2/24/2026
      championship (a Prelims time; Hardy had no finalist that round).
    - ~~Indoor boys 800m: the wall credited Pierce Leen with 2:30.1
      (2/25/2025)~~ — updated to Nico Schoenbauer, 2:26.77, 2/24/2026
      championship.
    - ~~Indoor girls 4x200m: the wall credited Hanson/Luna/Mazzei-Paterni/
      McMahan with 2:00.9 (2/25/2025)~~ — updated to an entirely different
      squad, Samba/Patterson/Consentino/Johnson, 2:00.58, 2/24/2026
      championship.
    - ~~Indoor girls 4x400m: the wall credited Migliaccio/Sullivan/Ljung/
      Mazzei-Paterni with 4:48.9 (2/25/2025)~~ — updated to a mostly
      different squad, Ljung/Caldara/Samba/Mazzei-Paterni, 4:40.56,
      2/24/2026 championship.
  - "FelipeSebastion Mes..." recurred garbled and truncated across all
    three new meets, same as previously seen; expanded to Felipe Sebastian
    Mesa McGovern each time. "Saila Faud" (transposed letters) corrected to
    Saila Fuad, matching her spelling in every outdoor 2026 meet already in
    the archive.
  - "Vanina Mazzei" (without "-Paterni") was how this data source printed
    her name throughout all three new indoor meets, plus one older entry in
    the 2024-01-18 file - same athlete as Vanina Mazzei-Paterni elsewhere in
    the archive. Normalized all eight occurrences to "Vanina Mazzei-Paterni"
    per Dario's instruction to keep her name consistent across the
    database.

## Open issues

- Cross country has no sources table at all yet, so no XC meets are listed
  here or captured as data. As of 2026-07-26 the presentation side is ready
  (`xc-results-archive.html`, generated by `tools/build-xc-archive.ps1` from
  `data/xc-meets/*.json`) - see `data/xc-capture-queue.md` for the schema.
  It just has nothing to search yet.

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
