# Meet capture queue

Working list for building the results archive. Tick items off as they land in
`data/meets/`.

## Why this list exists

Meets hosted on `results.mdtimingllc.com` and `athletic.net` are JavaScript
applications that load their results from Firebase. A crawler sees an empty
page shell, so the Wayback Machine cannot preserve them, and the Firebase REST
endpoint refuses unauthenticated reads (`Permission denied`); `edge.athletic.net`
returns 403 on every path. There is no way to pull these from the link alone.

Verified 2026-07-25 across all 39 source links: 12 are genuinely archived, 19
are empty shells, 7 were never archived. The only durable copy is the one we
hold ourselves, in `data/meets/`.

## Needs manual capture (16 remaining)

Open the link, click **Hardy**, copy the whole team result, paste it into a
Claude Code session. The `/teams` suffix goes straight to the team picker.

| ✓ | Season | Date | Meet | Link |
|---|--------|------|------|------|
| ☐ | Indoor | 2018-01-03 | DCIAA Developmental | https://results.mdtimingllc.com/meets/642/teams |
| ☐ | Indoor | 2018-01-24 | DCIAA MS/HS Championship | https://results.mdtimingllc.com/meets/699/teams |
| ☐ | Indoor | 2024-01-18 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/29702/teams |
| ☐ | Indoor | 2025-01-15 | DCIAA MS/HS Developmental | https://www.athletic.net/TrackAndField/meet/575023/results |
| ☐ | Indoor | 2025-02-25 | DCIAA MS Championship | https://results.mdtimingllc.com/meets/42558/teams/1081719 |
| ☐ | Outdoor | 2018-04-12 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/974/teams |
| ☐ | Outdoor | 2018-04-19 | DCIAA ES/MS Dual – Eastern | https://results.mdtimingllc.com/meets/989/teams/28959 |
| ☐ | Outdoor | 2018-05-22 | DCIAA MS Championship | https://results.mdtimingllc.com/meets/1219/teams |
| ☐ | Outdoor | 2019-04-03 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/2798/teams |
| ☐ | Outdoor | 2021-05-18 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/9872/teams |
| ☐ | Outdoor | 2023-05-02 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/24466/teams |
| ☐ | Outdoor | 2024-05-20 | DCIAA MS Developmental | https://results.mdtimingllc.com/meets/38240/teams |
| ☐ | Outdoor | 2024-05-30 | DCIAA MS Championship | https://results.mdtimingllc.com/meets/38470/teams |
| ☐ | Outdoor | 2025-05-09 | DCIAA MS Developmental | https://www.athletic.net/TrackAndField/meet/607132/results |
| ☐ | Outdoor | 2025-05-15 | St Albans / National Cathedral | https://www.athletic.net/TrackAndField/meet/610090/results |
| ☐ | Outdoor | 2025-05-19 | DCIAA MS Championship | https://www.athletic.net/TrackAndField/meet/613581/results |

Done:

| ✓ | Season | Date | Meet | File |
|---|--------|------|------|------|
| ☑ | Outdoor | 2023-05-23 | DCIAA MS Championship | `data/meets/2023-05-23-dciaa-es-ms-champs.json` |

## Automated (no action needed from you)

Static Hy-Tek pages on `results2.mdtimingllc.com` are parsed by
`tools/parse-hytek.ps1`. Twelve meets, of which two (2016-12-07 and 2017-01-25)
genuinely contain no Hardy athletes — your own source notes say "DCIAA but no
Deal and Hardy", so empty is the correct result there.

Not yet built: a second parser for the MileSplit and TFRRS pages, which use a
different layout.

## Open issues

- The 2017 exports carry a bib number into the athlete name ("Aaron 56 Jones").
  Must be fixed before that batch is committed.
- Sayum Iddamalagoda's indoor 55m record reads 7.6 on the site; the 2023-01-11
  results say 7.69. Needs a decision, not a silent overwrite.
- Cross country has no sources table at all yet, so no XC meets are listed here.
- The 2025/26 season is missing entirely from the site.

## Archive design

Two layers, so presentation stays cheap to change:

1. **Data** — one JSON per meet in `data/meets/`, holding the full Hardy team
   result: place, athlete, gender, event, mark, metric conversion, points,
   heat/flight, grade year, plus relay squads. Schema is set by the 2023 file.
   This is the archive, and it depends on nothing external.
2. **Pages** — generated from that data. A single searchable results archive
   grouped by school year, so a kid types their name and sees every mark they
   ever ran at Hardy. Later, the same data drives record progressions, deep
   all-time lists, and eventually the record boards themselves.
