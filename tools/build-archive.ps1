# Generates results-archive.html from every meet file in data/meets/.
# Re-run after adding a meet; the page is output, never edited by hand.
#
# One card per athlete per meet, so the meet name, date and season are stated
# once rather than repeated on every mark. Cards are hidden until searched.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$meets = @()

foreach ($f in Get-ChildItem "$root\data\meets\*.json" | Sort-Object Name) {
  $meets += (Get-Content -Raw -Encoding UTF8 $f.FullName | ConvertFrom-Json)
}

function Esc([string]$s) { return [System.Net.WebUtility]::HtmlEncode($s) }

function Ordinal([object]$p) {
  if (-not $p) { return "" }
  $n = [int]$p
  $suffix = switch ($n % 100) {
    { $_ -in 11, 12, 13 } { "th"; break }
    default {
      switch ($n % 10) { 1 { "st" } 2 { "nd" } 3 { "rd" } default { "th" } }
    }
  }
  return "$n$suffix"
}

function PlaceClass([object]$p) {
  switch ("$p") { "1" { "pl gold" } "2" { "pl silver" } "3" { "pl bronze" } default { "pl" } }
}

# A DNS, a foul or a no-height is the absence of a result, not a result. The
# meet files keep them (they are what the results say), but showing them would
# pad an athlete's card with events they have no mark for.
function IsResult([object]$mark) {
  $m = "$mark".Trim()
  if (-not $m) { return $false }
  return $m -notmatch '^(DNS|DNF|DQ|DNC|NT|NH|NM|ND|FOUL|SCR|SCRATCH|X+|-+)$'
}

# "G. Sipher" in a relay squad refers to "George Sipher" in the same meet.
function MatchesAthlete([string]$leg, [string]$full) {
  $leg = ($leg -replace '[.]', '').Trim()
  $full = $full.Trim()
  $lp = $leg -split '\s+'; $fp = $full -split '\s+'
  if ($lp.Count -lt 2 -or $fp.Count -lt 2) { return $false }
  if ($lp[-1] -ne $fp[-1]) { return $false }
  return $lp[0].Substring(0, 1).ToUpper() -eq $fp[0].Substring(0, 1).ToUpper()
}

$cards = New-Object System.Collections.ArrayList
$totalMarks = 0

foreach ($m in $meets) {
  $when = [datetime]::Parse($m.date)
  $season = if ($m.season) { $m.season } else { "outdoor" }

  # Bucket every individual mark under its athlete.
  $byAthlete = @{}
  foreach ($r in $m.individual) {
    if (-not $byAthlete.ContainsKey($r.athlete)) {
      $byAthlete[$r.athlete] = [pscustomobject]@{
        name = $r.athlete; gender = $r.gender; grade = $r.grade
        marks = New-Object System.Collections.ArrayList
      }
    }
    # Register the athlete either way so a relay leg can still be matched to
    # someone whose only individual entry was a DNS; drop the mark itself.
    if (-not (IsResult $r.mark)) { continue }
    [void]$byAthlete[$r.athlete].marks.Add([pscustomobject]@{
      event = $r.event
      mark  = if ($r.metric) { "$($r.mark) ($($r.metric))" } else { "$($r.mark)" }
      place = $r.place
      relay = $false
    })
    $totalMarks++
  }

  # Fold each relay into the cards of the legs we can identify, so a runner's
  # card shows their whole day. Unmatched relays become their own card.
  foreach ($rel in $m.relays) {
    if (-not (IsResult $rel.mark)) { continue }
    $matched = $false
    foreach ($leg in $rel.athletes) {
      foreach ($key in @($byAthlete.Keys)) {
        if (MatchesAthlete $leg $key) {
          [void]$byAthlete[$key].marks.Add([pscustomobject]@{
            event = "$($rel.event) relay"
            mark  = "$($rel.mark)"
            place = $rel.place
            relay = $true
          })
          $matched = $true
          break
        }
      }
    }
    $totalMarks++
    # A relay whose legs are simply unrecorded (some exports omit splits for
    # a lower-placing squad) has no name to attach a card to - nothing to
    # drop but a blank heading, so skip it rather than show one.
    if (-not $matched -and $rel.athletes.Count -gt 0) {
      $label = "$($rel.event) relay squad " + ($rel.athletes -join ", ")
      $byAthlete[$label] = [pscustomobject]@{
        name = ($rel.athletes -join ", "); gender = $rel.gender; grade = ""
        marks = @([pscustomobject]@{ event = "$($rel.event) relay"; mark = "$($rel.mark)"; place = $rel.place; relay = $true })
      }
    }
  }

  foreach ($a in $byAthlete.Values) {
    # An athlete whose whole day was scratches gets no card at all.
    if ($a.marks.Count -eq 0) { continue }
    [void]$cards.Add([pscustomobject]@{
      sortDate = $when; athlete = $a.name; gender = $a.gender; grade = $a.grade
      meet = $m.meet; date = $when.ToString("MMMM d, yyyy"); location = $m.location
      season = $season; url = $m.source.meet_url; marks = $a.marks
    })
  }
}

# Newest first, then alphabetical, so a name's cards read as a career backwards.
$ordered = $cards | Sort-Object @{e = { $_.sortDate }; Descending = $true }, athlete

$sb = New-Object System.Text.StringBuilder
foreach ($c in $ordered) {
  [void]$sb.AppendLine('            <article class="result-card is-hidden">')
  [void]$sb.AppendLine('                <div class="card-head">')
  [void]$sb.AppendLine('                    <span class="card-athlete">' + (Esc $c.athlete) + '</span>')
  $bits = @()
  if ($c.grade) { $bits += "Yr " + (Esc "$($c.grade)") }
  if ($c.gender) { $bits += (Get-Culture).TextInfo.ToTitleCase($c.gender) }
  if ($bits.Count) { [void]$sb.AppendLine('                    <span class="card-sub">' + ($bits -join ' &middot; ') + '</span>') }
  [void]$sb.AppendLine('                    <span class="season-badge ' + $c.season + '">' + (Get-Culture).TextInfo.ToTitleCase($c.season) + '</span>')
  [void]$sb.AppendLine('                </div>')
  $meetLine = (Esc $c.meet)
  if ($c.url) { $meetLine = '<a href="' + $c.url + '">' + $meetLine + '</a>' }
  [void]$sb.AppendLine('                <p class="card-meet">' + $meetLine + '</p>')
  [void]$sb.AppendLine('                <p class="card-date">' + $c.date + $(if ($c.location) { ' &middot; ' + (Esc $c.location) } else { '' }) + '</p>')
  [void]$sb.AppendLine('                <ul class="card-marks">')
  foreach ($mk in ($c.marks | Sort-Object event)) {
    $pl = if ($mk.place) { '<span class="' + (PlaceClass $mk.place) + '">' + (Ordinal $mk.place) + '</span>' } else { '<span class="pl none">&ndash;</span>' }
    [void]$sb.AppendLine('                    <li><span class="ev">' + (Esc $mk.event) + '</span><span class="mk">' + (Esc $mk.mark) + '</span>' + $pl + '</li>')
  }
  [void]$sb.AppendLine('                </ul>')
  [void]$sb.AppendLine('            </article>')
}

# Suggest names that actually exist, so the examples always return something.
# Filter blanks explicitly: Get-Random's -InputObject rejects a null/empty
# pipeline outright, which an all-blank candidate list would otherwise hit.
# The same filtered list (real named athletes, not a comma-joined unmatched
# relay squad standing in for one) also gives us an honest athlete count.
$namedAthletes = @($ordered | Where-Object { $_.athlete -notmatch ',' } | ForEach-Object { $_.athlete } | Sort-Object -Unique)
$athleteCount = $namedAthletes.Count
$surnames = @($namedAthletes | ForEach-Object { ($_ -split '\s+')[-1] } | Where-Object { $_ } | Sort-Object -Unique)
$examples = @(if ($surnames.Count -gt 0) { $surnames | Get-Random -Count ([Math]::Min(3, $surnames.Count)) })
$exHtml = ($examples | ForEach-Object { '<button type="button" class="example" data-example="' + (Esc $_) + '">' + (Esc $_) + '</button>' }) -join " "

$meetWord = if ($meets.Count -eq 1) { "meet" } else { "meets" }
$athleteWord = if ($athleteCount -eq 1) { "athlete" } else { "athletes" }

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hardy Middle School T&amp;F Results</title>
    <meta name="description" content="Search every Hardy Middle School track and field result we have on file, by athlete name.">
    <meta property="og:title" content="Hardy Middle School T&amp;F Results">
    <meta property="og:description" content="Search every Hardy Middle School track and field result we have on file, by athlete name.">
    <meta property="og:type" content="website">
    <meta property="og:image" content="hardylogo.png">
    <link rel="icon" href="hardylogo.png">
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header class="site-header">
        <div class="bar">
            <a class="brand" href="index.html">
                <img src="hardylogo.png" alt="">
                <span>Hardy Records</span>
            </a>
            <nav class="nav">
                <a href="index.html">Home</a>
                <a href="xc_record_wall.html">XC Records</a>
                <a href="xc-results-archive.html">XC Results</a>
                <a href="trackwall_indoor.html">Indoor Records</a>
                <a href="trackwall_outdoor.html">Outdoor Records</a>
                <a href="results-archive.html" aria-current="page">T&amp;F Results</a>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="page-head" id="top">
            <h1>T&amp;F Results</h1>
            <p>Every track and field result we have on file &mdash; not just the records.</p>
        </div>

        <div class="search">
            <label class="is-hidden" for="q">Search by athlete name</label>
            <input id="q" type="search" data-search data-search-mode="reveal"
                   placeholder="Type an athlete's name&hellip;" autocomplete="off" autofocus>
        </div>
        <p class="search-status" data-search-status role="status"></p>

        <div class="search-prompt" data-search-prompt>
            <p class="prompt-lead">Search for an athlete to see every meet they competed in.</p>
            <p class="prompt-eg">Try $exHtml</p>
            <p class="prompt-note">$athleteCount $athleteWord &middot; $($meets.Count) $meetWord &middot; $totalMarks marks on file.</p>
        </div>

        <div class="no-results is-hidden" data-search-empty>
            Nothing found. Try a surname on its own, or check the spelling.
        </div>

        <div class="card-grid">
$($sb.ToString())        </div>

        <div class="footer">
            <p>Every meet these results are drawn from is listed on the <a href="sources.html">Sources</a> page. Missing a meet, or spotted a mistake? Email
               <a href="mailto:dario.caldara@gmail.com">dario.caldara@gmail.com</a>.</p>
            <p>&copy; 2026 Hardy Middle School. All rights reserved.</p>
        </div>
    </div>

    <script src="site.js"></script>
</body>
</html>
"@

$html | Out-File -Encoding utf8 "$root\results-archive.html"
"built results-archive.html : $($meets.Count) $meetWord, $($ordered.Count) cards, $totalMarks marks, $athleteCount $athleteWord"
