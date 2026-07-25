# Harvests every meet on a static Hy-Tek export (results2.mdtimingllc.com and
# milesplit.com both use this format) into data/meets/*.json. Firebase-backed
# meets (results.mdtimingllc.com, athletic.net) cannot be reached this way -
# see data/capture-queue.md.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$meets = @(
  # -- results2.mdtimingllc.com (indoor) --
  @{u="https://results2.mdtimingllc.com/indoor_2017/dciaa1/";          d="2016-12-07"; n="DCIAA ES/MS Developmental";  s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/indoor_2017/dciaahs/";         d="2017-01-25"; n="DCIAA MS/HS Championship";   s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/indoor_2019/dciaaesms/";       d="2018-12-05"; n="DCIAA ES/MS Developmental";  s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/indoor_2019/dciaamshs/";       d="2019-01-09"; n="DCIAA MS/HS Developmental";  s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/indoor_2019/dciaamshschamps/"; d="2019-01-24"; n="DCIAA MS/HS Championship";   s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/indoor_2020/esms/";            d="2019-12-04"; n="DCIAA ES/MS Developmental";  s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/indoor_2020/dciaamshs/";       d="2019-12-12"; n="DCIAA MS/HS Developmental";  s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/indoor_2020/dcchamps/";        d="2020-01-29"; n="DCIAA MS/HS Championship";   s="indoor"; loc=""},
  @{u="https://results2.mdtimingllc.com/itf_23/dciaa1/";               d="2023-01-11"; n="DCIAA MS/HS Developmental";  s="indoor"; loc=""},
  # -- results2.mdtimingllc.com (outdoor) --
  @{u="https://results2.mdtimingllc.com/outdoor_2017/msdev/";          d="2017-04-11"; n="DCIAA MS Developmental";     s="outdoor"; loc="Spingarn, DC"},
  @{u="https://results2.mdtimingllc.com/outdoor_2017/esmsrelays/";     d="2017-05-01"; n="DCIAA MS Relays & Field";    s="outdoor"; loc="Spingarn, DC"},
  @{u="https://results2.mdtimingllc.com/outdoor_2017/mschamps/";       d="2017-05-12"; n="DCIAA MS Championship";      s="outdoor"; loc="Spingarn, DC"},
  # -- milesplit.com (same Hy-Tek format under a different host) --
  @{u="https://dc.milesplit.com/meets/351456-dciaa-elementary-and-middle-school-relay-meet-2019/results";                        d="2019-04-11"; n="DCIAA MS Relays & Field"; s="outdoor"; loc="Spingarn, DC"},
  @{u="https://dc.milesplit.com/meets/354578-dciaa-middle-school-outdoor-track-and-field-championships-2019/results/653892/raw"; d="2019-05-02"; n="DCIAA MS Championship";   s="outdoor"; loc="Spingarn, DC"},
  @{u="https://www.milesplit.com/meets/476482-dciaa-middle-school-developmental-meet-2022/results/810238?type=raw";              d="2022-04-28"; n="DCIAA MS Developmental";  s="outdoor"; loc="Spingarn, DC"},
  @{u="https://www.milesplit.com/meets/479717-dciaa-middle-school-developmental-meet-2-2022/results";                           d="2022-05-10"; n="DCIAA MS Developmental";  s="outdoor"; loc="Spingarn, DC"},
  @{u="https://www.milesplit.com/meets/483769-dciaa-elementary-and-middle-school-championships-2022/results";                   d="2022-05-24"; n="DCIAA MS Championship";   s="outdoor"; loc="Spingarn, DC"},
  @{u="https://www.milesplit.com/meets/535807-dciaa-middle-school-developmental-meet-2023/results/922993?type=raw";              d="2023-04-12"; n="DCIAA MS Developmental";  s="outdoor"; loc="Spingarn, DC"},
  @{u="https://www.milesplit.com/meets/675779-dciaa-middle-school-outdoor-track-and-field-developmental-meet-2025/results";      d="2025-04-03"; n="DCIAA MS Developmental";  s="outdoor"; loc="Spingarn, DC"}
)

$report = @()
foreach ($m in $meets) {
  $slug = "$($m.d)-" + ($m.n.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
  try {
    $o = (& "$PSScriptRoot\parse-hytek.ps1" -Url $m.u) | ConvertFrom-Json

    $bad = @($o.individual | Where-Object { $_.athlete -match '\d|Rankings|Team' })
    $bad += @($o.relays | ForEach-Object { $_.athletes } | Where-Object { $_ -match '\d' })

    if ($o.individual.Count -eq 0 -and $o.relays.Count -eq 0) {
      $report += [pscustomobject]@{ slug = $slug; indiv = 0; relays = 0; bad = 0; status = "no Hardy entries - not written" }
      continue
    }

    $out = [pscustomobject]@{
      meet = $m.n; date = $m.d; season = $m.s; school = "Hardy Middle School"
      location = $m.loc
      source = @{ meet_url = $m.u; captured = "2026-07-25"; method = "parsed from static Hy-Tek results" }
      individual = $o.individual
      relays = $o.relays
    }
    $out | ConvertTo-Json -Depth 6 | Out-File -Encoding utf8 "$root\data\meets\$slug.json"
    $report += [pscustomobject]@{ slug = $slug; indiv = $o.individual.Count; relays = $o.relays.Count; bad = $bad.Count; status = "written" }
  } catch {
    $report += [pscustomobject]@{ slug = $slug; indiv = -1; relays = -1; bad = -1; status = "FAILED: $($_.Exception.Message)" }
  }
}

$report | ForEach-Object { "{0,-4} {1,-4} bad={2,-3} {3,-10} {4}" -f $_.indiv, $_.relays, $_.bad, $_.status, $_.slug }
"---"
"meets written: $(($report | Where-Object status -eq 'written').Count) of $($meets.Count)"
