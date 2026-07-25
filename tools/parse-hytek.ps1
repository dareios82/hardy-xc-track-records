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

$event = $null; $division = $null; $cols = $null
$individual = @(); $relays = @(); $pending = $null

# Slice a fixed-width row using offsets taken from the block's header line.
# Hy-Tek prints "Last, First"; the site uses "First Last" everywhere else.
function Flip([string]$n) {
  # Some exports carry a bib number after the given name ("Jones, Aaron 56").
  $n = $n -replace '\s+\d+\s*$', ''
  if ($n -match '^\s*([^,]+),\s*(.+?)\s*$') { return ($Matches[2] + " " + $Matches[1]).Trim() }
  return $n.Trim()
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

  # Per-event files prefix the title with "Event 17".
  if ($line -match '^(?:Event\s+\S+\s+)?(Girls|Boys)\s+(.+?)(\s+(Middle School|High School))?\s*$') {
    # Capture before testing anything else: -match overwrites $Matches.
    $g = $Matches[1]
    $ev = $Matches[2].Trim()
    $dv = if ($Matches[4]) { $Matches[4] } else { "" }
    if ($ev -match '\d|Jump|Put|Throw|Relay|Dash|Run|Hurdles|Walk') {
      $gender = $g; $event = $ev; $division = $dv
      $cols = $null; $pending = $null
    }
    continue
  }

  # Column header for the current block.
  # Seed is not always present, and some exports say "Team" instead of
  # "School", so key off Finals plus any name/team column.
  if ($line -match '\bFinals\b' -and ($line -match '\bName\b' -or $line -match '\bSchool\b' -or $line -match '\bTeam\b')) {
    $hIdx = $line.IndexOf("H#")
    $pIdx = $line.IndexOf("Points")
    $schoolIdx = $line.IndexOf("School")
    if ($schoolIdx -lt 0) { $schoolIdx = $line.IndexOf("Team") }
    # Marks are right-aligned and can be wider than the "Finals" header
    # (2:54.99 vs Finals), so start the slice left of the header and stop it
    # at whatever column comes next, otherwise the heat number bleeds in.
    $finalsEnd = if ($hIdx -ge 0) { $hIdx } elseif ($pIdx -ge 0) { $pIdx } else { $line.Length }
    $cols = @{
      Name       = $line.IndexOf("Name")
      School     = $schoolIdx
      Seed       = $line.IndexOf("Seed")
      Finals     = $line.IndexOf("Finals")
      FinalsFrom = [Math]::Max(0, $line.IndexOf("Finals") - 5)
      FinalsTo   = $finalsEnd
      Points     = $pIdx
      Year       = $line.IndexOf("Year")
    }
    continue
  }

  # Filter by school, not division: at combined developmental meets Hardy's
  # middle schoolers are listed under the "High School" event headers.
  if (-not $cols) { continue }

  # Relay legs belong to the relay row immediately above.
  if ($pending -and $line -match '^\s+\d\)') {
    foreach ($m in [regex]::Matches($line, '\d\)\s*([^0-9]+?)\s+\d{1,2}(?=\s|$)')) {
      $pending.athletes += (Flip $m.Groups[1].Value)
    }
    continue
  }

  # Case-sensitive: "hardy, desirae" of Capitol Hill is a different person.
  if (-not ($line -cmatch [regex]::Escape($School))) { $pending = $null; continue }
  if (-not $gender) { continue }

  $place = if ($line -match '^\s*(\d+)\s') { [int]$Matches[1] } else { $null }

  if ($line -match "'(\w)'") {
    # Relay entry
    $squad = $Matches[1]
    $pending = [pscustomobject]@{
      place = $place; gender = $gender.ToLower(); event = $event
      mark = (Slice $line $cols.FinalsFrom $cols.FinalsTo)
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
      mark   = (Slice $line $cols.FinalsFrom $cols.FinalsTo)
      points = (Slice $line $cols.Points ($cols.Points + 8))
    }
  }
}

[pscustomobject]@{
  source = $Url
  individual = $individual
  relays = $relays
} | ConvertTo-Json -Depth 6
