param([string]$Url, [string]$School = "Hardy")

$ErrorActionPreference = "Stop"
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126.0 Safari/537.36"

function Get-Text([string]$u) {
  $h = (Invoke-WebRequest -Uri $u -UserAgent $UA -TimeoutSec 40 -UseBasicParsing).Content
  $t = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($h, '<[^>]*>', "`n"))
  return @{ html = $h; text = $t }
}

$base = $Url.TrimEnd('/') + "/"
$r = Get-Text $Url

# Older exports are framesets whose results live in one file per event,
# listed in evtindex.htm. Follow and concatenate them.
if ($r.html -match '(?i)<frame[^>]*src="evtindex\.htm"') {
  $idx = (Get-Text ($base + "evtindex.htm")).html
  $parts = @()
  foreach ($m in [regex]::Matches($idx, '(?i)href="([^"]+\.htm)"')) {
    $f = $m.Groups[1].Value
    if ($f -match 'index|lastheat|lastevt') { continue }
    try { $parts += (Get-Text ($base + $f)).text } catch { }
  }
  $text = $parts -join "`n"
} else {
  $text = $r.text
}

$lines = $text -split "`r?`n"

$event = $null; $division = $null; $cols = $null; $relayLetter = 0
$individual = @(); $relays = @(); $pending = $null

# Slice a fixed-width row using offsets taken from the block's header line.
# Hy-Tek prints "Last, First"; the site uses "First Last" everywhere else.
function Flip([string]$n) {
  # Some exports carry a bib number before the surname ("34 Jones, Aaron", or
  # MileSplit's "# 1005 McEwen, Laura") - it sits inside the Name column's
  # character range, ahead of the name - and occasionally after the given
  # name too ("Jones, Aaron 56"). Strip all of it.
  $n = $n -replace '^\s*#?\s*\d+\s+', '' -replace '\s+\d+\s*$', ''
  if ($n -match '^\s*([^,]+),\s*(.+?)\s*$') { return ($Matches[2] + " " + $Matches[1]).Trim() }
  return $n.Trim()
}

# Some exports annotate every time with a trailing "a" (fully automatic
# timing), e.g. "14.10a" - not present anywhere else on the site, so drop it
# for consistency. DNS/DQ/NH/FOUL never end in digit+a, so this is safe.
function CleanMark([string]$m) {
  return $m -replace '(?<=\d)a$', ''
}

function Slice([string]$line, [int]$start, [int]$end) {
  if ($start -lt 0 -or $start -ge $line.Length) { return "" }
  if ($end -lt 0 -or $end -gt $line.Length) { $end = $line.Length }
  if ($end -le $start) { return "" }
  return $line.Substring($start, $end - $start).Trim()
}

foreach ($raw in $lines) {
  $line = $raw.TrimEnd()
  if (-not $line) { continue }

  # Per-event files each end with a cumulative standings table ("Women - Team
  # Rankings - 15 Events Scored", two entries per line: "7) McKinley Middle
  # School  37   8) Hardy Middle School  36"). "Hardy" matches the school
  # filter, and with no relay quote it falls to the individual branch, sliced
  # at the still-active results-table offsets - garbage in, not a result.
  # Blind the parser until the next event's own header resets $cols.
  if ($line -match '(?i)Team Rankings') {
    $cols = $null; $pending = $null
    continue
  }

  # Per-event files prefix the title with "Event 17". The division marker
  # can sit before the event name ("Boys Middle School 100 Meters Finals")
  # or after it ("Girls 100 Meter Dash High School") depending on export.
  if ($line -match '^(?:Event\s+\S+\s+)?(Girls|Boys)\s+(.+)$') {
    $g = $Matches[1]
    $ev = $Matches[2].Trim()
    $ev = $ev -replace '^(Middle School|High School)\s+', ''
    $ev = $ev -replace '\s+(Middle School|High School)$', ''
    $ev = $ev -replace '\s+Finals$', ''
    if ($ev -match '\d|Jump|Put|Throw|Relay|Dash|Run|Hurdles|Walk|Meter') {
      $gender = $g; $event = $ev.Trim()
      $cols = $null; $pending = $null; $relayLetter = 0
    }
    continue
  }

  # Column header for the current block.
  # Seed is not always present. Some exports say "Team" instead of "School",
  # "Athlete" instead of "Name", and "Mark" instead of "Finals" - key off
  # whichever result-column label is present, plus any name/team column.
  $finalsLabel = if ($line -match '\bFinals\b') { "Finals" } elseif ($line -match '\bMark\b') { "Mark" } elseif ($line -match '\bTime\b') { "Time" } else { $null }
  if ($finalsLabel -and ($line -match '\bName\b' -or $line -match '\bAthlete\b' -or $line -match '\bSchool\b' -or $line -match '\bTeam\b')) {
    $hIdx = $line.IndexOf("H#")
    $pIdx = $line.IndexOf("Points")
    $schoolIdx = $line.IndexOf("School")
    if ($schoolIdx -lt 0) { $schoolIdx = $line.IndexOf("Team") }
    $nameIdx = $line.IndexOf("Name")
    if ($nameIdx -lt 0) { $nameIdx = $line.IndexOf("Athlete") }
    # A block with a Team column but no Name/Athlete column is relay-only:
    # every row is a relay, even when (as in some exports) it carries no
    # 'A'/'B' squad-letter quote at all.
    $relayOnlyBlock = ($nameIdx -lt 0) -and ($schoolIdx -ge 0)
    # Marks are right-aligned and can be wider than the header word itself
    # (2:54.99 vs Finals), so start the slice left of the header and stop it
    # at whatever column comes next, otherwise the heat number bleeds in.
    $finalsIdx = $line.IndexOf($finalsLabel)
    $finalsEnd = if ($hIdx -ge 0) { $hIdx } elseif ($pIdx -ge 0) { $pIdx } else { $line.Length }
    $cols = @{
      Name       = $nameIdx
      School     = $schoolIdx
      Seed       = $line.IndexOf("Seed")
      Finals     = $finalsIdx
      FinalsFrom = [Math]::Max(0, $finalsIdx - 5)
      FinalsTo   = $finalsEnd
      Points     = $pIdx
      Year       = $line.IndexOf("Yr")
      YearAlt    = $line.IndexOf("Year")
      RelayOnly  = $relayOnlyBlock
    }
    if ($cols.Year -lt 0) { $cols.Year = $cols.YearAlt }
    continue
  }

  # Filter by school, not division: at combined developmental meets Hardy's
  # middle schoolers are listed under the "High School" event headers.
  if (-not $cols) { continue }

  # Relay legs belong to the relay row immediately above. A leg-shaped line
  # ("1) Name   2) Name") is never a new result row on its own - if there's
  # no relay to attach it to (e.g. the preceding team was a different
  # school), skip it outright. Otherwise a leg naming an athlete who just
  # happens to share the target school's name on a DIFFERENT team (seen:
  # "Rivas, Kevin 8    4) Hardy, Ricardo 7" for Raymond Education Campus)
  # would fall through and get misread as a new Hardy team result.
  if ($line -match '^\s+\d\)') {
    if ($pending) {
      # Some exports trail each name with a grade digit ("McEwen, Laura 6"),
      # others lead it with a bib number instead ("232 Mcalpine, Nathan") and
      # have no trailing digit at all - so a leg can't be delimited by
      # requiring one particular digit position. Instead take everything
      # between one "N)" marker and the next (or end of line); Flip cleans up
      # whichever stray digit is actually present.
      foreach ($m in [regex]::Matches($line, '\d\)\s*(?:#?\s*\d+\s+)?([A-Za-z][^)]*?)(?=\s{2,}\d\)|\s*$)')) {
        $pending.athletes += (Flip $m.Groups[1].Value)
      }
    }
    continue
  }

  # Case-sensitive: "hardy, desirae" of Capitol Hill is a different person.
  if (-not ($line -cmatch [regex]::Escape($School))) { $pending = $null; continue }
  if (-not $gender) { continue }

  $place = if ($line -match '^\s*(\d+)\s') { [int]$Matches[1] } else { $null }

  $quoteMatch = [regex]::Match($line, "'(\w)'")
  if ($quoteMatch.Success -or $cols.RelayOnly) {
    # Relay entry. Some exports never print a squad letter at all - infer it
    # from how many times this school has already appeared in this event.
    $squad = if ($quoteMatch.Success) { $quoteMatch.Groups[1].Value } else { $null }
    if (-not $squad) {
      $relayLetter++
      $squad = [char](64 + $relayLetter)
    }
    $pending = [pscustomobject]@{
      place = $place; gender = $gender.ToLower(); event = $event
      mark = (CleanMark (Slice $line $cols.FinalsFrom $cols.FinalsTo))
      squad = $squad
      points = (Slice $line $cols.Points ($cols.Points + 8))
      athletes = @()
    }
    $relays += $pending
  }
  else {
    $pending = $null
    $individual += [pscustomobject]@{
      place  = $place
      athlete = (Flip (Slice $line $cols.Name $cols.Year))
      gender = $gender.ToLower()
      event  = $event
      grade  = (Slice $line $cols.Year ($cols.School))
      mark   = (CleanMark (Slice $line $cols.FinalsFrom $cols.FinalsTo))
      points = (Slice $line $cols.Points ($cols.Points + 8))
    }
  }
}

[pscustomobject]@{
  source = $Url
  individual = $individual
  relays = $relays
} | ConvertTo-Json -Depth 6
