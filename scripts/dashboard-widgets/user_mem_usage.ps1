# user_mem_usage.ps1 - Memory usage grouped by user (HTML output for Zabbix)
# Deploy to: C:\Zabbix\Scripts\user_mem_usage.ps1

$ramByOwner = @{}
$cpuByOwner = @{}
$procCount = @{}

Get-Process -IncludeUserName -ErrorAction SilentlyContinue | Where-Object { $_.UserName } | ForEach-Object {
    $user = $_.UserName
    if (-not $ramByOwner.ContainsKey($user)) {
        $ramByOwner[$user] = 0
        $cpuByOwner[$user] = 0
        $procCount[$user] = 0
    }
    $ramByOwner[$user] += $_.WorkingSet64
    $cpuByOwner[$user] += $_.CPU
    $procCount[$user]++
}

$sorted = $ramByOwner.GetEnumerator() |
    Sort-Object Value -Descending |
    Select-Object -First 10

$maxRAM = ($sorted | Measure-Object -Property Value -Maximum).Maximum
if ($maxRAM -eq 0) { $maxRAM = 1 }

$hostname = $env:COMPUTERNAME
$rows = ""
foreach ($entry in $sorted) {
    $user = $entry.Key
    $ramMB = [math]::Round($entry.Value / 1MB, 0)
    $cpuVal = [math]::Round($cpuByOwner[$user], 1)
    $procs = $procCount[$user]

    if ($ramMB -ge 1024) { $color = "#e66767" }
    elseif ($ramMB -ge 512) { $color = "#d95926" }
    elseif ($ramMB -ge 256) { $color = "#c98500" }
    else { $color = "#199e70" }

    $barW = [math]::Min([math]::Round(($entry.Value / $maxRAM) * 100), 100)
    if ($barW -lt 2 -and $ramMB -gt 0) { $barW = 2 }

    # Shorten username
    $shortUser = $user
    if ($user.Length -gt 25 -and $user.Contains('\')) {
        $parts = $user.Split('\')
        $shortUser = $parts[0].Substring(0, [math]::Min(3, $parts[0].Length)) + '\' + $parts[1]
    }

    $rows += "<tr>"
    $rows += "<td style='padding:2px 6px;color:#f0efec;font-size:12px;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;'>$shortUser</td>"
    $rows += "<td style='padding:2px 4px;width:110px;'><div style='background:$color;height:14px;width:${barW}px;border-radius:3px;'></div></td>"
    $rows += "<td style='padding:2px 6px;color:$color;font-size:12px;font-weight:600;text-align:right;'>$ramMB MB</td>"
    $rows += "<td style='padding:2px 6px;color:#c3c2b7;font-size:11px;text-align:right;'>$cpuVal</td>"
    $rows += "<td style='padding:2px 6px;color:#c3c2b7;font-size:11px;text-align:right;'>$procs</td>"
    $rows += "</tr>"
}

$html = @"
<div style='font-size:13px;font-weight:600;color:#3987e5;margin-bottom:4px;font-family:system-ui,sans-serif;'>&#128100; $hostname &mdash; Memory Usage by User</div>
<table style='border-collapse:collapse;width:100%;font-family:system-ui,sans-serif;'>
<tr style='border-bottom:1px solid #2c2c2a;'>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:left;'>User</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:left;'>Memory</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>Value</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>CPU</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>Procs</th>
</tr>
$rows
</table>
"@

Write-Output $html