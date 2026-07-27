# Generates xc-results-archive.html from every meet file in data/xc-meets/.
# Mirrors tools/build-archive.ps1's approach for track, but simpler: cross
# country has one race per gender, no events and no relays to fold in, so
# each result is already its own card - no bucketing-by-athlete needed.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$meetsDir = "$root\data\xc-meets"
$meets = @()

if (Test-Path $meetsDir) {
  foreach ($f in Get-ChildItem "$meetsDir\*.json" -ErrorAction SilentlyContinue | Sort-Object Name) {
    $meets += (Get-Content -Raw -Encoding UTF8 $f.FullName | ConvertFrom-Json)
  }
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

# The "titleholder" span is invisible (see .sr-only in style.css) but still
# part of the card's text, so searching that word finds every champion
# without cluttering the badge itself - and without colliding with "DCIAA
# ... Championship" meet names, which every card at a championship meet
# would otherwise match regardless of whether that athlete actually won.
function BadgeHtml([object]$badges) {
  $html = ""
  foreach ($b in $badges) {
    switch ($b) {
      "dciaa-indiv" { $html += '<span class="title-badge dciaa" title="DCIAA individual champion">&#127942; DCIAA<span class="sr-only"> titleholder</span></span>' }
      "dcsaa-indiv" { $html += '<span class="title-badge dcsaa" title="DCSAA individual champion">&#127942; DCSAA<span class="sr-only"> titleholder</span></span>' }
      "dciaa-team"  { $html += '<span class="title-badge dciaa team" title="DCIAA team champion">&#129351; DCIAA<span class="sr-only"> titleholder</span></span>' }
      "dcsaa-team"  { $html += '<span class="title-badge dcsaa team" title="DCSAA team champion">&#129351; DCSAA<span class="sr-only"> titleholder</span></span>' }
    }
  }
  return $html
}

# A DNS or DNF is the absence of a result, not a result - keep it in the data
# (it's what the source says) but don't let it pad a runner's card.
function IsResult([object]$mark) {
  $m = "$mark".Trim()
  if (-not $m) { return $false }
  return $m -notmatch '^(DNS|DNF|DQ|DNC|SCR|SCRATCH|-+)$'
}

$cards = New-Object System.Collections.ArrayList
$totalMarks = 0

# DCIAA/DCSAA titles are only awarded at their own championship meets - a
# "DCIAA ES+MS Developmental Meet" mentions the league but isn't one.
foreach ($m in $meets) {
  $when = [datetime]::Parse($m.date)
  $isChamp = $m.meet -match 'Championship'
  $league = if ($m.meet -match 'DCIAA') { 'dciaa' } elseif ($m.meet -match 'DCSAA') { 'dcsaa' } else { $null }
  $teamChampScorers = @{}
  if ($isChamp -and $league -and $m.team_scores) {
    foreach ($ts in $m.team_scores) {
      if ("$($ts.place)" -eq '1') { $teamChampScorers[$ts.gender] = @($ts.scorers) }
    }
  }

  foreach ($r in $m.results) {
    if (-not (IsResult $r.time)) { continue }
    $totalMarks++
    $badges = New-Object System.Collections.ArrayList
    if ($isChamp -and $league -and "$($r.place)" -eq '1') { [void]$badges.Add("$league-indiv") }
    if ($teamChampScorers.ContainsKey($r.gender) -and $teamChampScorers[$r.gender] -contains $r.athlete) {
      [void]$badges.Add("$league-team")
    }
    [void]$cards.Add([pscustomobject]@{
      sortDate = $when; athlete = $r.athlete; gender = $r.gender; grade = $r.grade
      meet = $m.meet; date = $when.ToString("MMMM d, yyyy"); location = $m.location
      url = $m.source.meet_url; time = $r.time; place = $r.place; distance = $r.distance
      badges = $badges
    })
  }
}

$ordered = $cards | Sort-Object @{e = { $_.sortDate }; Descending = $true }, athlete

$sb = New-Object System.Text.StringBuilder
foreach ($c in $ordered) {
  [void]$sb.AppendLine('            <article class="result-card is-hidden">')
  [void]$sb.AppendLine('                <div class="card-head">')
  [void]$sb.AppendLine('                    <span class="card-athlete">' + (Esc $c.athlete) + '</span>' + (BadgeHtml $c.badges))
  $bits = @()
  if ($c.grade) { $bits += "Yr " + (Esc "$($c.grade)") }
  if ($c.gender) { $bits += (Get-Culture).TextInfo.ToTitleCase($c.gender) }
  if ($bits.Count) { [void]$sb.AppendLine('                    <span class="card-sub">' + ($bits -join ' &middot; ') + '</span>') }
  [void]$sb.AppendLine('                </div>')
  $meetLine = (Esc $c.meet)
  if ($c.url) { $meetLine = '<a href="' + $c.url + '">' + $meetLine + '</a>' }
  [void]$sb.AppendLine('                <p class="card-meet">' + $meetLine + '</p>')
  [void]$sb.AppendLine('                <p class="card-date">' + $c.date + $(if ($c.location) { ' &middot; ' + (Esc $c.location) } else { '' }) + '</p>')
  [void]$sb.AppendLine('                <ul class="card-marks">')
  $distLabel = if ($c.distance) { " (" + (Esc "$($c.distance)") + ")" } else { "" }
  $pl = if ($c.place) { '<span class="' + (PlaceClass $c.place) + '">' + (Ordinal $c.place) + '</span>' } else { '<span class="pl none">&ndash;</span>' }
  [void]$sb.AppendLine('                    <li><span class="ev">Race' + $distLabel + '</span><span class="mk">' + (Esc $c.time) + '</span>' + $pl + '</li>')
  [void]$sb.AppendLine('                </ul>')
  [void]$sb.AppendLine('            </article>')
}

$namedAthletes = @($ordered | ForEach-Object { $_.athlete } | Where-Object { $_ } | Sort-Object -Unique)
$athleteCount = $namedAthletes.Count
$surnames = @($namedAthletes | ForEach-Object { ($_ -split '\s+')[-1] } | Where-Object { $_ } | Sort-Object -Unique)
$examples = @(if ($surnames.Count -gt 0) { $surnames | Get-Random -Count ([Math]::Min(3, $surnames.Count)) })
$exHtml = ($examples | ForEach-Object { '<button type="button" class="example" data-example="' + (Esc $_) + '">' + (Esc $_) + '</button>' }) -join " "
$exHtml += ' <button type="button" class="example" data-example="titleholder">&#127942; Champions</button>'

$meetWord = if ($meets.Count -eq 1) { "meet" } else { "meets" }
$athleteWord = if ($athleteCount -eq 1) { "athlete" } else { "athletes" }

$emptyState = if ($meets.Count -eq 0) {
@"

        <div class="search-prompt">
            <p class="prompt-lead">No cross country meets are on file yet.</p>
            <p class="prompt-note">This page is ready to go the moment results are captured &mdash; check back soon.</p>
        </div>
"@
} else {
@"

        <div class="search-prompt" data-search-prompt>
            <p class="prompt-lead">Search for an athlete to see every race they ran.</p>
            <p class="prompt-eg">Try $exHtml</p>
            <p class="prompt-note">$athleteCount $athleteWord &middot; $($meets.Count) $meetWord &middot; $totalMarks marks on file.</p>
            <p class="prompt-note"><span class="title-badge dciaa">&#127942; DCIAA</span> <span class="title-badge dcsaa">&#127942; DCSAA</span> mark individual champions; <span class="title-badge dciaa team">&#129351; DCIAA</span> <span class="title-badge dcsaa team">&#129351; DCSAA</span> mark team champions.</p>
        </div>

        <div class="no-results is-hidden" data-search-empty>
            Nothing found. Try a surname on its own, or check the spelling.
        </div>
"@
}

$searchBox = if ($meets.Count -eq 0) { "" } else {
@"

        <div class="search">
            <label class="is-hidden" for="q">Search by athlete name</label>
            <input id="q" type="search" data-search data-search-mode="reveal"
                   placeholder="Type an athlete's name&hellip;" autocomplete="off" autofocus>
        </div>
        <p class="search-status" data-search-status role="status"></p>
"@
}

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hardy Middle School XC Results</title>
    <meta name="description" content="Search every Hardy Middle School cross country result we have on file, by athlete name.">
    <meta property="og:title" content="Hardy Middle School XC Results">
    <meta property="og:description" content="Search every Hardy Middle School cross country result we have on file, by athlete name.">
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
                <a href="xc-results-archive.html" aria-current="page">XC Results</a>
                <a href="trackwall_indoor.html">Indoor Records</a>
                <a href="trackwall_outdoor.html">Outdoor Records</a>
                <a href="results-archive.html">T&amp;F Results</a>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="page-head" id="top">
            <h1>XC Results</h1>
            <p>Every cross country result we have on file &mdash; not just the records.</p>
        </div>
$searchBox
$emptyState

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

$html | Out-File -Encoding utf8 "$root\xc-results-archive.html"
"built xc-results-archive.html : $($meets.Count) $meetWord, $($ordered.Count) cards, $totalMarks marks, $athleteCount $athleteWord"
