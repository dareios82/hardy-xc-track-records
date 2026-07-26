# Cross country meet capture queue

Mirrors `data/capture-queue.md`, the same working list for the track &
field archive, but for cross country. Nothing has been captured here yet -
`xc_record_wall.html` today is a hand-built top-N list plus team-championship
summaries, not full per-meet results, so there's no per-athlete archive to
search the way `results-archive.html` lets you search every track mark.

## Needs manual capture (none listed yet)

No meet links have been gathered for cross country yet. When they are, list
them here the same way `data/capture-queue.md` does for track, then paste
the team results into a session the same way.

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
  ]
}
```

- `place`: overall finishing place, or `null` if the source doesn't give one.
- `time`: as printed by the source (`M:SS.ss` or `H:MM:SS.ss`).
- `distance`: the course distance if known (courses have varied over the
  years - `xc_record_wall.html` notes "about 4.1 km (2.55 miles)" for most
  of Hardy's history, but don't assume that's always right).
- Non-results (DNF, DNS, DQ) should still be listed with that value in
  `time`, matching how `data/meets/*.json` keeps DNS/DNF rows rather than
  dropping them - `tools/build-xc-archive.ps1` filters them from display,
  same as the track build script.

## Archive design

Same two-layer approach as track:

1. **Data** — one JSON per meet in `data/xc-meets/`, depends on nothing
   external.
2. **Pages** — generated via `tools/build-xc-archive.ps1`, producing
   `xc-results-archive.html`. Never hand-edit that file. Search-first, one
   card per athlete per meet, same UI conventions as `results-archive.html`
   (see `data/capture-queue.md`'s Archive design section for the shared
   details - search modes, card grid, etc).

Until meets are captured, `tools/build-xc-archive.ps1` runs over zero
files and produces a valid, empty-state archive page - the search box and
navigation are all live, it just has nothing to find yet.
