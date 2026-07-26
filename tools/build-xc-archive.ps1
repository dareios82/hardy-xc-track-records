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

# A DNS or DNF is the absence of a result, not a result - keep it in the data
# (it's what the source says) but don't let it pad a runner's card.
function IsResult([object]$mark) {
  $m = "$mark".Trim()
  if (-not $m) { return $false }
  return $m -notmatch '^(DNS|DNF|DQ|DNC|SCR|SCRATCH|-+)$'
}

$cards = New-Object System.Collections.ArrayList
$totalMarks = 0

foreach ($m in $meets) {
  $when = [datetime]::Parse($m.date)
  foreach ($r in $m.results) {
    if (-not (IsResult $r.time)) { continue }
    $totalMarks++
    [void]$cards.Add([pscustomobject]@{
      sortDate = $when; athlete = $r.athlete; gender = $r.gender; grade = $r.grade
      meet = $m.meet; date = $when.ToString("MMMM d, yyyy"); location = $m.location
      url = $m.source.meet_url; time = $r.time; place = $r.place; distance = $r.distance
    })
  }
}

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
                <a href="xc_record_wall.html">Cross Country</a>
                <a href="xc-results-archive.html" aria-current="page">XC Results</a>
                <a href="trackwall_indoor.html">Indoor</a>
                <a href="trackwall_outdoor.html">Outdoor</a>
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
            <p>Missing a meet, or spotted a mistake? Email
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
