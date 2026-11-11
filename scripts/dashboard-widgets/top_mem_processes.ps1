# top_mem_processes.ps1 - Top 10 processes by Memory usage (HTML output for Zabbix)
# Deploy to: C:\Zabbix\Scripts\top_mem_processes.ps1

$procs = Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 10 |
    ForEach-Object {
        $ramMB  = [math]::Round($_.WorkingSet64 / 1MB, 0)
        $pid_   = $_.Id
        $name   = $_.ProcessName
        # Color severity by RAM
        if ($ramMB -ge 1024) { $color = "#e66767" }       # critical red (>1GB)
        elseif ($ramMB -ge 512) { $color = "#d95926" }     # orange
        elseif ($ramMB -ge 256) { $color = "#c98500" }     # yellow
        else { $color = "#199e70" }                         # green
        # Bar width proportional (max 100px)
        $maxRAM = 2048
        $barW = [math]::Min([math]::Round(($ramMB / $maxRAM) * 100), 100)
        [PSCustomObject]@{
            Name  = $name
            PID   = $pid_
            RAM   = $ramMB
            Color = $color
            BarW  = $barW
        }
    }

$hostname = $env:COMPUTERNAME
$rows = ""
foreach ($p in $procs) {
    $rows += "<tr>"
    $rows += "<td style='padding:2px 6px;color:#f0efec;font-size:12px;'>$($p.Name)</td>"
    $rows += "<td style='padding:2px 6px;color:#c3c2b7;font-size:11px;text-align:right;'>$($p.PID)</td>"
    $rows += "<td style='padding:2px 4px;width:110px;'><div style='background:$($p.Color);height:14px;width:$($p.BarW)px;border-radius:3px;'></div></td>"
    $rows += "<td style='padding:2px 6px;color:$($p.Color);font-size:12px;font-weight:600;text-align:right;'>$($p.RAM) MB</td>"
    $rows += "</tr>"
}

$html = @"
<div style='font-size:13px;font-weight:600;color:#3987e5;margin-bottom:4px;font-family:system-ui,sans-serif;'>&#128202; $hostname &mdash; Top Memory Processes</div>
<table style='border-collapse:collapse;width:100%;font-family:system-ui,sans-serif;'>
<tr style='border-bottom:1px solid #2c2c2a;'>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:left;'>Process</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>PID</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:left;'>Memory</th>
<th style='padding:3px 6px;color:#898781;font-size:11px;font-weight:400;text-align:right;'>Value</th>
</tr>
$rows
</table>
"@

Write-Output $html