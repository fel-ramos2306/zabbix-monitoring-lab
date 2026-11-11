# user_cpu_usage.ps1 - CPU usage grouped by user (HTML output for Zabbix)
# Deploy to: C:\Zabbix\Scripts\user_cpu_usage.ps1

$owners = @{}
$ramByOwner = @{}
$procCount = @{}

Get-Process -IncludeUserName -ErrorAction SilentlyContinue | Where-Object { $_.UserName } | ForEach-Object {
    $user = $_.UserName
    if (-not $owners.ContainsKey($user)) {
        $owners[$user] = 0
        $ramByOwner[$user] = 0
        $procCount[$user] = 0
    }
    $owners[$user] += $_.CPU
    $ramByOwner[$user] += $_.WorkingSet64
    $procCount[$user]++
}

$sorted = $owners.GetEnumerator() |
    Sort-Object Value -Descending |
    Select-Object -First 10

$maxCpu = ($sorted | Measure-Object -Property Value -Maximum).Maximum
if ($maxCpu -eq 0) { $maxCpu = 1 }

$hostname = $env:COMPUTERNAME
$rows = ""
foreach ($entry in $sorted) {
    $user = $entry.Key
    $cpuVal = [math]::Round($entry.Value, 1)
    $ramMB = [math]::Round($ramByOwner[$user] / 1MB, 0)
    $procs = $procCount[$user]

    if ($cpuVal -ge 200) { $color = "#e66767" }
    elseif ($cpuVal -ge 100) { $color = "#d95926" }
    elseif ($cpuVal -ge 50) { $color = "#c98500" }
    else { $color = "#199e70" }

    $barW = [math]::Min([math]::Round(($cpuVal / $maxCpu) * 100), 100)
    if ($barW -lt 2 -and $cpuVal -gt 0) { $barW = 2 }

    # Shorten username (remove domain prefix if too long)
    $shortUser = $user
    if ($user.Length -gt 25 -and $user.Contains('\')) {
        $parts = $user.Split('\')
        $shortUser = $parts[0].Substring(0, [math]::Min(3, $parts[0].Length)) + '\' + $parts[1]
    }

    $rows += "<tr>"
    $rows += "<td style='padding:2px 6px;color:#f0efec;font-size:12px;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;'>$shortUser</td>"
    $rows += "<td style='padding:2px 4px;width:110px;'><div style='background:$color;height:14px;width:${barW}px;border-radius:3px;'></div></td>"
    $rows += "<td style='padding:2px 6px;color:$color;font-size:12px;font-weight:600;text-align:right;'>$cpuVal</td>"
    $rows += "<td style='padding:2px 6px;color:#c3c2b7;font-size:11px;text-align:right;'>$ramMB MB</td>"
    $rows += "<td style='padding:2px 6px;color:#c3c2b7;font-size:11px;text-align:right;'>$procs</td>"
    $rows += "</tr>"
}

$html = @"
<div style='font-size:13px;font-weight:600;color:#3987e5;margin-bottom:4px;font-family:system-ui,sans-serif;'>&#128100; $hostname &mdash; CPU Usage by User</div>
<table style='border-collapse:collapse;width:100%;font-family:system-ui,sans-serif;'>
<tr style='border-bottom:1px solid #2c2c2a;'>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:left;'>User</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:left;'>CPU</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>Value</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>RAM</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>Procs</th>
</tr>
$rows
</table>
"@

Write-Output $html