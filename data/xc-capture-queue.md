# Cross country meet capture queue

Mirrors `data/capture-queue.md`, the same working list for the track &
field archive, but for cross country. `xc_record_wall.html` was originally
a hand-built top-N list plus team-championship summaries with no per-meet
data behind it; as of 2026-07-27 the entire 2025 season has been captured
as real per-meet data too, so both the record wall and the archive now
draw from the same source for that season. Earlier seasons (2011-2024) are
still only reflected in the record wall's hand-built rows - see Open
issues, below.

## Needs manual capture

No meet links (URLs) have been gathered for cross country - the 2025
season was transcribed from pasted results with no source URL given. If
Dario has the athletic.net (or other) links for these, add them to
`data/xc-meets/*.json`'s `source.meet_url` field:

| ✓ | Date | Meet | File |
|---|------|------|------|
| ☑ | 2025-09-17 | Bob Thurston Lafayette Invitational | `data/xc-meets/2025-09-17-bob-thurston-lafayette-invitational.json` |
| ☑ | 2025-10-17 | DCIAA XC ES/MS Challenge | `data/xc-meets/2025-10-17-dciaa-xc-es-ms-challenge.json` |
| ☑ | 2025-10-22 | DCIAA Cross Country Championships | `data/xc-meets/2025-10-22-dciaa-cross-country-championships.json` |
| ☑ | 2025-11-01 | DCSAA Cross Country Championships | `data/xc-meets/2025-11-01-dcsaa-cross-country-championships.json` |

Captured (✓) means the results are transcribed and in the archive, not
that a source URL is on file - the "Needs manual capture" heading here
refers to the missing links, not the data itself.

## Schema

One JSON file per meet in `data/xc-meets/`, read by
`tools/build-xc-archive.ps1` to produce `xc-results-archive.html`. Simpler
than the track schema (`data/meets/*.json`) because cross country has no
multiple events and no relays - just one race per gender:

```json
{
  "meet": "DCIAA XC Championship",
  "date": "2024-10-22",
  "location": "Colmar Manor, MD",
  "school": "Hardy Middle School",
  "source": {
    "meet_url": "...",
    "captured": "YYYY-MM-DD",
    "method": "manual copy from ...",
    "note": "optional"
  },
  "results": [
    { "place": 1, "athlete": "First Last", "gender": "girls|boys", "grade": 8, "time": "16:45.81", "distance": "4.1km" }
  ],
  "team_scores": [
    { "gender": "girls", "place": 1, "points": 30, "scorers": ["First Last", "..."] }
  ]
}
```

- `place`: overall finishing place, or `null` if the source doesn't give one.
- `time`: as printed by the source (`M:SS.ss` or `H:MM:SS.ss`).
- `distance`: the course distance if known (courses have varied over the
  years - `xc_record_wall.html` notes "about 4.1 km (2.55 miles)" for most
  of Hardy's history, but don't assume that's always right; leave `null`
  if the specific meet's paste didn't state it).
- Non-results (DNF, DNS, DQ) should still be listed with that value in
  `time`, matching how `data/meets/*.json` keeps DNS/DNF rows rather than
  dropping them - `tools/build-xc-archive.ps1` filters them from display,
  same as the track build script.
- `team_scores` is optional - only present for meets that reported an
  official team score. `scorers` is the top 5 or top 7 finishers (whichever
  the meet's own listing gave), matching the convention already used in
  `xc_record_wall.html`'s hand-built team tables. This field isn't read by
  `tools/build-xc-archive.ps1` (the archive is about individual results);
  it exists purely as backing data for hand-updating the team tables on
  `xc_record_wall.html` when a new championship result comes in.

## Archive design

Same two-layer approach as track:

1. **Data** — one JSON per meet in `data/xc-meets/`, depends on nothing
   external.
2. **Pages** — generated via `tools/build-xc-archive.ps1`, producing
   `xc-results-archive.html`. Never hand-edit that file. Search-first, one
   card per athlete per meet, same UI conventions as `results-archive.html`
   (see `data/capture-queue.md`'s Archive design section for the shared
   details - search modes, card grid, etc).
3. **Record wall** — `xc_record_wall.html` is still hand-built, not
   generated. After adding a meet, check whether any Hardy time now beats
   an existing entry in the individual top-N tables (girls sub-21:00, boys
   sub-19:00) or changes a team-championship row, and hand-edit that page
   too. Unlike track, there's no script doing this reconciliation
   automatically - each new meet needs a manual "does this change a record"
   pass.

## Open issues

- Only the 2025 season (four meets) has been captured as real per-meet
  data. Everything from 2011-2024 exists only as the hand-built rows
  already on `xc_record_wall.html`, sourced from whatever Dario originally
  compiled them from - there's no `data/xc-meets/*.json` backing those
  years, and no way to search an individual athlete's 2019 race, for
  example, the way the archive lets you for 2025.
- No source URLs are on file for any of the four 2025 meets.
