# Cross country meet capture queue

Mirrors `data/capture-queue.md`, the same working list for the track &
field archive, but for cross country. `xc_record_wall.html` was originally
a hand-built top-N list plus team-championship summaries with no per-meet
data behind it; as of 2026-07-27 the 2024 and 2025 seasons, the 2022 and
2023 DCSAA Cross Country Championships, and twelve older meets spanning
2009-2023 have been captured as real per-meet data too, so the record
wall and the archive now draw from the same source for all of these.
What's left of 2011-2023 is still only reflected in the record wall's
hand-built rows - see Open issues, below.

## Needs manual capture (none remaining for 2024 or 2025; several older meets also captured)

Both full seasons, plus several older meets, are captured with results and source links:

| ✓ | Date | Meet | Link | File |
|---|------|------|------|------|
| ☑ | 2024-09-18 | 19th Annual Lafayette XC Invitational | [athletic.net/247102](https://www.athletic.net/CrossCountry/meet/247102/info) | `data/xc-meets/2024-09-18-lafayette-xc-invitational.json` |
| ☑ | 2024-10-02 | DCIAA ES+MS Developmental Meet | [athletic.net/249440](https://www.athletic.net/CrossCountry/meet/249440/info) | `data/xc-meets/2024-10-02-dciaa-es-ms-developmental.json` |
| ☑ | 2024-10-17 | GP Middle School Challenge | [athletic.net/240296](https://www.athletic.net/CrossCountry/meet/240296) | `data/xc-meets/2024-10-17-gp-middle-school-challenge.json` |
| ☑ | 2024-10-22 | DCIAA Cross Country Championships | [athletic.net/250009](https://www.athletic.net/CrossCountry/meet/250009/info) | `data/xc-meets/2024-10-22-dciaa-cross-country-championships.json` |
| ☑ | 2024-11-02 | DCSAA Cross Country Championships | [athletic.net/246524](https://www.athletic.net/CrossCountry/meet/246524/info) | `data/xc-meets/2024-11-02-dcsaa-cross-country-championships.json` |
| ☑ | 2025-09-17 | Bob Thurston Lafayette Invitational | [athletic.net/262494](https://www.athletic.net/CrossCountry/meet/262494/info) | `data/xc-meets/2025-09-17-bob-thurston-lafayette-invitational.json` |
| ☑ | 2025-10-17 | DCIAA XC ES/MS Challenge | [athletic.net/262497](https://www.athletic.net/CrossCountry/meet/262497/info) | `data/xc-meets/2025-10-17-dciaa-xc-es-ms-challenge.json` |
| ☑ | 2025-10-22 | DCIAA Cross Country Championships | [athletic.net/269060](https://www.athletic.net/CrossCountry/meet/269060/info) | `data/xc-meets/2025-10-22-dciaa-cross-country-championships.json` |
| ☑ | 2025-11-01 | DCSAA Cross Country Championships | [athletic.net/260003](https://www.athletic.net/CrossCountry/meet/260003/info) | `data/xc-meets/2025-11-01-dcsaa-cross-country-championships.json` |
| ☑ | 2023-11-04 | DCSAA Cross Country Championships | [athletic.net/235268](https://www.athletic.net/CrossCountry/meet/235268/info) | `data/xc-meets/2023-11-04-dcsaa-cross-country-championships.json` |
| ☑ | 2022-11-05 | DCSAA Cross Country Championships | [athletic.net/220733](https://www.athletic.net/CrossCountry/meet/220733/info) | `data/xc-meets/2022-11-05-dcsaa-cross-country-championships.json` |
| ☑ | 2021-04-25 | St. Anselm's XC #2 | [athletic.net/190945](https://www.athletic.net/CrossCountry/meet/190945/info) | `data/xc-meets/2021-04-25-st-anselms-xc-2.json` |
| ☑ | 2018-09-20 | Lafayette Invitational Cross Country Meet | [athletic.net/151503](https://www.athletic.net/CrossCountry/meet/151503/info) | `data/xc-meets/2018-09-20-lafayette-invitational.json` |
| ☑ | 2015-10-06 | DCIAA Elementary/Middle Developmental #1 | [athletic.net/115664](https://www.athletic.net/CrossCountry/meet/115664/info) | `data/xc-meets/2015-10-06-dciaa-es-ms-developmental.json` |
| ☑ | 2010-10-30 | DCIAA Cross Country East/West Championship | [athletic.net/42842](https://www.athletic.net/CrossCountry/meet/42842/info) | `data/xc-meets/2010-10-30-dciaa-cross-country-east-west-championship.json` |
| ☑ | 2009-10-31 | DCIAA East/West Championships | [athletic.net/29393](https://www.athletic.net/CrossCountry/meet/29393/info) | `data/xc-meets/2009-10-31-dciaa-east-west-championships.json` |
| ☑ | 2023-10-04 | DCIAA Elementary & Middle School Developmental | [milesplit/574904](https://md.milesplit.com/meets/574904-dciaa-elementary-and-middle-school-developmental-2023) | `data/xc-meets/2023-10-04-dciaa-es-ms-developmental.json` |
| ☑ | 2023-09-20 | 18th Annual Lafayette Invitational | [milesplit/568152](https://md.milesplit.com/meets/568152-18th-annual-lafayette-invitational-2023/results?type=formatted) | `data/xc-meets/2023-09-20-lafayette-invitational.json` |
| ☑ | 2022-10-05 | DCIAA Elementary & Middle School Developmental | [milesplit/503103](https://md.milesplit.com/meets/503103-dciaa-elementary-and-middle-school-developmental-2022/results) | `data/xc-meets/2022-10-05-dciaa-es-ms-developmental.json` |
| ☑ | 2021-09-22 | 16th Annual Lafayette Invitational | [milesplit/444621](https://md.milesplit.com/meets/444621-16th-annual-lafayette-invitational-2021) | `data/xc-meets/2021-09-22-lafayette-invitational.json` |
| ☑ | 2019-10-05 | DCIAA Elementary & Middle School Developmental | [milesplit/369268](https://dc.milesplit.com/meets/369268-dciaa-elementary-and-middle-school-developmental-2019/results) | `data/xc-meets/2019-10-05-dciaa-es-ms-developmental.json` |
| ☑ | 2014-10-25 | DCIAA Elementary and MS Championships | [milesplit/187969](https://md.milesplit.com/meets/187969-dciaa-elementary-and-ms-championships-2014/results) | `data/xc-meets/2014-10-25-dciaa-es-ms-championships.json` |
| ☑ | 2014-10-04 | DCIAA Developmental Meet #1 | [milesplit/185695](https://dc.milesplit.com/meets/185695-dciaa-developmental-meet-1-2014/results/328714?type=formatted) | `data/xc-meets/2014-10-04-dciaa-developmental-meet-1.json` |

The 2024-10-22 and 2024-11-02 championship results matched
`xc_record_wall.html`'s pre-existing hand-built rows for those meets
exactly - no individual or team rows needed to change, this just gave
them real per-meet backing data. The 2024-09-18 and 2024-10-02 meets
didn't change any record either (every time was slower than what was
already the fastest on file for that athlete).

The 2024-10-17 GP Middle School Challenge is a special case: it's run over
2 miles, not the usual 4100m course, so none of its individual times are
comparable to the record wall's lists - `data/xc-meets/2024-10-17-gp-middle-school-challenge.json`
notes this explicitly and its results were excluded from the individual
record check. Dario asked for the team result to be included anyway, so
both team tables on `xc_record_wall.html` got a new row for it, labeled
"GP Middle School Challenge (2 mi course)" so it reads as distinct from
the 4100m results around it.

The 2023-11-04 and 2022-11-05 DCSAA Cross Country Championships also
matched `xc_record_wall.html`'s pre-existing rows exactly - no individual
or team rows needed to change. Neither meet's paste stated a course
distance, so `distance` was set to 4100m to match the same Kenilworth Park
DCSAA course used in adjacent years (noted in each file's `source.note`).
The 2022 meet's boys race had no official team score (only 4 finishers,
below the 5 needed), matching the wall's lack of a 2022 DCSAA boys team
row.

Five older meets (2009-2021) were also added: the 2021-04-25 St. Anselm's
XC #2 (boys only, run over 1.8 miles, explicitly excluded from the
individual comparison since it's not the usual ~4100m course); the
2018-09-20 Lafayette Invitational and 2015-10-06 DCIAA Developmental
meets, neither of which changed any record (every qualifying time was
already beaten by a later mark from the same athlete, or fell outside the
sub-19:00 / sub-21:00 cutoffs); and two "Partial Results" meets from the
DCIAA East/West Championship era, 2010-10-30 and 2009-10-31. The 2010 meet
added one new row to `xc_record_wall.html`'s girls individual table -
Alexis Coates, 20:39.00, inserted between Rohini Kieffer and Josephine
Caplan (now rank 20, pushing the Caplan sisters to 21/22) - since she
wasn't previously listed and her time beats the sub-21:00 cutoff. None of
these five meets' pastes stated a course distance, so all were set to
4100m matching the Fort Dupont Park / Colmar Manor courses used in
adjacent years; the 2009 meet's times were printed with a period instead
of a colon (e.g. "22.20") and read as M:SS.

What's left of 2011-2023 still has no links or per-meet data at all - see
Open issues, below.

Seven more meets (2014-2023) were added from `data/rawdataxc.txt`, a
mix of milesplit.com pages Dario pasted in either already Hardy-filtered
or as the full mixed-school field. None changed any wall record - every
qualifying time was already beaten by a later mark from the same athlete,
or fell outside the sub-19:00 / sub-21:00 cutoffs:
- 2023-10-04 and 2022-10-05 DCIAA Elementary & Middle School Developmental,
  2023-09-20 (18th) and 2021-09-22 (16th) Lafayette Invitational - all at
  Colmar Manor, distance set to 4100m to match.
- 2019-10-05 DCIAA Elementary & Middle School Developmental (Kenilworth
  Park) - names reformatted from the source's "Last, First" order. "Ma
  Andersson-Potterveld" is printed that way in the source and matches the
  wall's existing (also truncated) form - may be short for Mats
  Andersson-Potterveld, the fuller name already resolved in the track
  archive, but left as printed pending confirmation.
- 2014-10-25 DCIAA Elementary and MS Championships (Colmar Manor) - no
  team score total was given, only per-athlete scoring positions, so no
  `team_scores` entry.
- 2014-10-04 DCIAA Developmental Meet #1 (Dunbar HS) - explicitly a
  2-mile race, excluded from the individual comparison like the GP
  Middle School Challenge and St. Anselm's XC #2.

Two more meets from that file have no results available anywhere yet -
see "Needs a source", below.

## Needs a source

These meets are known to have happened (Dario has the date/location) but
no results page has been found:

| Date | Meet | Location |
|------|------|----------|
| 2022-09-21 | 17th Annual Lafayette Invitational | Colmar Manor Community Park, MD |
| 2020-10-05 | DCIAA Elementary & Middle School Developmental | Colmar Manor Community Park, MD |

Dario's note: could try contacting M&D Timing Services, LLC, who appear to
run timing for the Colmar Manor meets.

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

- The 2024 and 2025 seasons (nine meets), the 2022 and 2023 DCSAA Cross
  Country Championships, and twelve older meets from 2009-2023 (twenty-three
  meets total) have been captured as real per-meet data. Everything else
  from 2011-2023 exists only as the hand-built rows already on
  `xc_record_wall.html`, sourced from whatever Dario originally compiled
  them from - there's no `data/xc-meets/*.json` backing those years, and
  no way to search an individual athlete's 2019 race, for example, the way
  the archive lets you for the meets already captured.
- Two meets (2022 17th Lafayette Invitational, 2020 ES/MS Developmental)
  are known to have happened but have no results page found yet - see
  "Needs a source", above.
