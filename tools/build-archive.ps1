# Generates results-archive.html from every meet file in data/meets/.
# Re-run after adding a meet; the page is output, never edited by hand.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$meets = @()

foreach ($f in Get-ChildItem "$root\data\meets\*.json" | Sort-Object Name) {
  $meets += (Get-Content -Raw -Encoding UTF8 $f.FullName | ConvertFrom-Json)
}

function SchoolYear([string]$date) {
  $d = [datetime]::Parse($date)
  if ($d.Month -ge 8) { return "{0}/{1}" -f $d.Year, ($d.Year + 1).ToString().Substring(2) }
  return "{0}/{1}" -f ($d.Year - 1), $d.Year.ToString().Substring(2)
}

function Esc([string]$s) { return [System.Net.WebUtility]::HtmlEncode($s) }

function RankClass([object]$place) {
  switch ("$place") { "1" { "rank gold" } "2" { "rank silver" } "3" { "rank bronze" } default { "rank" } }
}

$sb = New-Object System.Text.StringBuilder
$total = 0

# Group meets by school year, newest first.
$byYear = $meets | Group-Object { SchoolYear $_.date } | Sort-Object Name -Descending

$jump = ($byYear | ForEach-Object {
  '            <a href="#y{0}">{1}</a>' -f ($_.Name -replace '/', '-'), $_.Name
}) -join "`n"

foreach ($yr in $byYear) {
  $anchor = "y" + ($yr.Name -replace '/', '-')
  [void]$sb.AppendLine('        <h2 class="year-head" id="' + $anchor + '">' + $yr.Name + '</h2>')

  foreach ($m in ($yr.Group | Sort-Object date -Descending)) {
    $rows = New-Object System.Collections.ArrayList

    foreach ($r in $m.individual) {
      $label = (Get-Culture).TextInfo.ToTitleCase($r.gender) + " " + $r.event
      $mark = if ($r.metric) { "$($r.mark) ($($r.metric))" } else { "$($r.mark)" }
      [void]$rows.Add([pscustomobject]@{
        sort = "$($r.gender)|$($r.event)|$('{0:d3}' -f [int]($(if ($r.place) { $r.place } else { 999 })))"
        place = $r.place; who = $r.athlete; label = $label; mark = $mark
        grade = $r.grade; pts = $r.points
      })
    }
    foreach ($r in $m.relays) {
      $label = (Get-Culture).TextInfo.ToTitleCase($r.gender) + " " + $r.event
      [void]$rows.Add([pscustomobject]@{
        sort = "$($r.gender)|zz$($r.event)|$('{0:d3}' -f [int]($(if ($r.place) { $r.place } else { 999 })))"
        place = $r.place; who = ($r.athletes -join ", "); label = $label; mark = "$($r.mark)"
        grade = ""; pts = $r.points
      })
    }

    $total += $rows.Count
    $when = [datetime]::Parse($m.date).ToString("MMMM d, yyyy")
    $src = if ($m.source.meet_url) { $m.source.meet_url } else { "" }

    [void]$sb.AppendLine('        <section class="section">')
    [void]$sb.AppendLine('            <h3 class="meet-head">' + (Esc $m.meet) + '</h3>')
    [void]$sb.AppendLine('            <p class="meet-meta">' + $when +
      $(if ($m.location) { ' &middot; ' + (Esc $m.location) } else { '' }) +
      $(if ($src) { ' &middot; <a href="' + $src + '">original results</a>' } else { '' }) + '</p>')
    [void]$sb.AppendLine('            <div class="table-wrap">')
    [void]$sb.AppendLine('                <table class="record-table">')
    [void]$sb.AppendLine('                    <thead><tr><th>Place</th><th>Athlete</th><th>Event</th><th>Mark</th><th>Yr</th><th>Pts</th></tr></thead>')
    [void]$sb.AppendLine('                    <tbody>')

    foreach ($r in ($rows | Sort-Object sort)) {
      $placeCell = if ($r.place) { '<span class="' + (RankClass $r.place) + '">' + $r.place + '</span>' } else { '<span class="rank">&ndash;</span>' }
      $pts = if ("$($r.pts)" -and "$($r.pts)" -ne "0") { "$($r.pts)" } else { "" }
      [void]$sb.AppendLine('                        <tr>' +
        '<td data-label="Place">' + $placeCell + '</td>' +
        '<td data-label="Athlete" class="cell-athlete"><span class="athlete">' + (Esc $r.who) + '</span></td>' +
        '<td data-label="Event" class="meet">' + (Esc $r.label) + '</td>' +
        '<td data-label="Mark" class="cell-perf"><span class="perf">' + (Esc $r.mark) + '</span></td>' +
        '<td data-label="Yr" class="date">' + (Esc "$($r.grade)") + '</td>' +
        '<td data-label="Pts" class="date">' + (Esc $pts) + '</td>' +
        '</tr>')
    }

    [void]$sb.AppendLine('                    </tbody>')
    [void]$sb.AppendLine('                </table>')
    [void]$sb.AppendLine('            </div>')
    [void]$sb.AppendLine('            <p class="to-top"><a href="#top">&uarr; Back to top</a></p>')
    [void]$sb.AppendLine('        </section>')
  }
}

$meetWord = if ($meets.Count -eq 1) { "meet" } else { "meets" }

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hardy Middle School Results Archive</title>
    <meta name="description" content="Every Hardy Middle School track and cross country result we have on file, searchable by athlete name.">
    <meta property="og:title" content="Hardy Middle School Results Archive">
    <meta property="og:description" content="Every Hardy Middle School result we have on file, searchable by athlete name.">
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
                <a href="trackwall_indoor.html">Indoor</a>
                <a href="trackwall_outdoor.html">Outdoor</a>
                <a href="results-archive.html" aria-current="page">Results</a>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="page-head" id="top">
            <h1>Find Your Results</h1>
            <p>Every Hardy result we have on file &mdash; not just the records. Type your name.</p>
        </div>

        <div class="search">
            <label class="is-hidden" for="q">Search by athlete name</label>
            <input id="q" type="search" data-search placeholder="Search for an athlete, event or meet&hellip;" autocomplete="off">
        </div>
        <p class="search-status" data-search-status role="status"></p>

        <div class="no-results is-hidden" data-search-empty>
            No results match your search. Try a last name, an event, or a year.
        </div>

        <nav class="jump" data-hide-on-search aria-label="Jump to a school year">
$jump
        </nav>

$($sb.ToString())
        <div class="footer">
            <p>$total results from $($meets.Count) $meetWord. Missing a meet? Email
               <a href="mailto:dario.caldara@gmail.com">dario.caldara@gmail.com</a>.</p>
            <p>&copy; 2026 Hardy Middle School. All rights reserved.</p>
        </div>
    </div>

    <script src="site.js"></script>
</body>
</html>
"@

$html | Out-File -Encoding utf8 "$root\results-archive.html"
"built results-archive.html : $($meets.Count) $meetWord, $total rows"
