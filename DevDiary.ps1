# =============================================================================
# DevDiary.ps1
# Author: Siddharth
# Your personal work black box. Run it at the end of each day.
#
# Usage:
#   DevDiary.ps1              <- log today (interactive)
#   DevDiary.ps1 -Week        <- view last 7 days summary
#   DevDiary.ps1 -Search "auth" <- find all days you worked on something
#   DevDiary.ps1 -Today       <- view today's entry (no prompts)
#
# What it records automatically:
#   - Meetings from Outlook calendar (today)
#   - Teams calls accepted today (from local MSTeams logs)
#   - Git activity from your project folder (set $projectPath below before first run)
#   - "What I Did" auto-filled from today's commit messages (bullet list)
#   - Active dev servers (ports)
#
# What it asks you:
#   - Commit any dirty repos? (popup if uncommitted changes exist)
#   - Any wins?
#   - Any blockers?
#   - What's first tomorrow?
#
# Output:
#   Documents\DevDiary\daily\YYYY-MM-DD.md   <- full entry
#   Documents\DevDiary\DevDiary.xlsx         <- one row per day
#   Documents\DevDiary\dashboard.html        <- visual overview
# =============================================================================

param(
    [switch] $Week,
    [switch] $ShowToday,
    [string] $Search
)

$diaryRoot  = "$env:USERPROFILE\Documents\DevDiary"
$dailyDir   = "$diaryRoot\daily"
$excelFile  = "$diaryRoot\DevDiary.xlsx"
$htmlFile   = "$diaryRoot\dashboard.html"
$now        = Get-Date
$todayStr   = $now.ToString('yyyy-MM-dd')
$todayFile  = "$dailyDir\$todayStr.md"

# =============================================================================
# HELPERS
# =============================================================================

function Write-Header($title) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  $title"
    Write-Host "  $($now.ToString('dddd, dd MMM yyyy'))"
    Write-Host "========================================"
    Write-Host ""
}

function Write-Section($label) {
    Write-Host ""
    Write-Host "  [ $label ]"
    Write-Host "  $('-' * 36)"
}

function Ensure-Dir($path) {
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

function Ask($prompt, $default = '') {
    $ans = Read-Host "  $prompt"
    if ([string]::IsNullOrWhiteSpace($ans)) { return $default }
    return $ans.Trim()
}

# =============================================================================
# DATA COLLECTORS
# =============================================================================

function Get-TodaysMeetings {
    $meetings = @()
    $outlookWasStartedByUs = $false
    try {
        # Try to get a running Outlook instance first; if none, launch it and wait for sync.
        $outlook = $null
        try {
            $outlook = [System.Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application')
        } catch {
            # Outlook not running - launch it visibly so it can authenticate and sync Exchange
            Write-Host "  [INFO] Launching Outlook to sync calendar..."
            Start-Process "C:\Program Files\Microsoft Office\Root\Office16\OUTLOOK.EXE"
            $outlookWasStartedByUs = $true

            # Poll until Outlook registers as a COM server (up to 45 s)
            $outlook = $null
            for ($i = 0; $i -lt 9; $i++) {
                Start-Sleep -Seconds 5
                try {
                    $outlook = [System.Runtime.InteropServices.Marshal]::GetActiveObject('Outlook.Application')
                    break
                } catch {}
            }
            if (-not $outlook) { throw "Outlook did not start in time." }

            # Give Exchange a moment to sync after login
            Start-Sleep -Seconds 15
            Write-Host "  [INFO] Outlook ready."
        }

        $ns       = $outlook.GetNamespace('MAPI')
        try { $ns.Logon('Outlook', [System.Reflection.Missing]::Value, $false, $false) } catch {}

        $today = $now.Date
        $end   = $today.AddDays(1)

        # Collect calendar items from every store (handles shared/delegate calendars too)
        foreach ($store in $ns.Stores) {
            try {
                $cal   = $store.GetDefaultFolder(9)  # 9 = olFolderCalendar
                $items = $cal.Items
                $items.IncludeRecurrences = $true
                $items.Sort('[Start]')

                # NOTE: Outlook's Restrict filter silently fails (returns max-int count) when
                # the store hasn't fully synced. We filter in PowerShell instead — safe and
                # works regardless of sync state or system locale.
                foreach ($item in $items) {
                    try {
                        if ($item.Start -ge $today -and $item.Start -lt $end) {
                            $durationMins = [int](($item.End - $item.Start).TotalMinutes)
                            $meetings += [PSCustomObject]@{
                                Time     = $item.Start.ToString('HH:mm')
                                Subject  = $item.Subject
                                Duration = $durationMins
                                Status   = switch ($item.MeetingStatus) {
                                    0 { 'Appointment' }
                                    1 { 'Meeting' }
                                    3 { 'Accepted' }
                                    5 { 'Tentative' }
                                    default { 'Meeting' }
                                }
                            }
                        }
                    } catch {}
                }
            } catch {}
        }

        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ns) | Out-Null
        # Do NOT quit Outlook if the user had it open already
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook) | Out-Null
    } catch {
        Write-Host "  [WARN] Could not read Outlook: $_"
    }
    return $meetings | Sort-Object Time
}

function Get-TeamsCallsToday {
    # Teams 2.0 (New Teams) stores call events in MSTeams_*.log under LocalCache.
    # Contact names are NOT stored locally (server-side only in Teams 2.0).
    # We track unique call IDs that were accepted today, compute duration from reportCallEnded.
    $calls = @()
    $logDir = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Logs"
    if (-not (Test-Path -LiteralPath $logDir)) { return $calls }

    # FIX: Use filename date prefix, NOT LastWriteTime.
    # Teams rolls log files mid-day - a log named 2026-06-19_xx can have LastWriteTime of 2026-06-20.
    # We include any log whose filename starts with today's date, plus yesterday to catch overnight sessions.
    $todayPrefix     = $now.ToString('yyyy-MM-dd')
    $yesterdayPrefix = $now.Date.AddDays(-1).ToString('yyyy-MM-dd')

    $logFiles = Get-ChildItem -Path $logDir -Filter 'MSTeams_*.log' -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match "^MSTeams_($todayPrefix|$yesterdayPrefix)" } |
                Sort-Object Name

    # callId -> [datetime] start  (covers both incoming accepted + outgoing connected)
    $startedIds = @{}
    # callId -> [datetime] end
    $endedIds   = @{}
    # callId -> direction label
    $directions = @{}

    foreach ($f in $logFiles) {
        try {
            $lines = [System.IO.File]::ReadAllLines($f.FullName)
            foreach ($line in $lines) {
                # Only process lines from today
                if (-not $line.StartsWith($todayPrefix)) { continue }

                # Parse ISO timestamp from log line
                $lineTime = $null
                if ($line -match '^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})') {
                    try { $lineTime = [datetime]::Parse($Matches[1]) } catch {}
                }

                # Incoming call answered
                if ($line -match 'reportCallAccepted for callId:\s*([\w-]+)') {
                    $callId = $Matches[1]
                    if (-not $startedIds.ContainsKey($callId)) {
                        $startedIds[$callId]  = $lineTime
                        $directions[$callId]  = 'incoming'
                    }
                }

                # Outgoing call connected (other end picked up)
                if ($line -match 'ReportOutgoingCallConnected for callId:\s*([\w-]+)') {
                    $callId = $Matches[1]
                    if (-not $startedIds.ContainsKey($callId)) {
                        $startedIds[$callId]  = $lineTime
                        $directions[$callId]  = 'outgoing'
                    }
                }

                # Call ended — used to compute duration for both directions
                if ($line -match 'reportCallEnded for callId:\s*([\w-]+)') {
                    $callId = $Matches[1]
                    if (-not $endedIds.ContainsKey($callId)) {
                        $endedIds[$callId] = $lineTime
                    }
                }
            }
        } catch {}
    }

    # Build call objects with duration and direction
    foreach ($callId in $startedIds.Keys) {
        $start     = $startedIds[$callId]
        $timeStr   = if ($start) { $start.ToString('HH:mm') } else { '' }
        $direction = $directions[$callId]
        $duration  = 0
        if ($start -and $endedIds.ContainsKey($callId) -and $endedIds[$callId]) {
            $duration = [int](($endedIds[$callId] - $start).TotalMinutes)
            if ($duration -lt 0) { $duration = 0 }
        }
        $calls += [PSCustomObject]@{
            Time     = $timeStr
            Subject  = "Teams call ($direction)"
            Duration = $duration
            Status   = 'Teams'
        }
    }

    return $calls | Sort-Object Time
}

function Get-GitActivity($repoPath) {
    $results = @()

    if ([string]::IsNullOrWhiteSpace($repoPath)) { return $results }
    if (-not (Test-Path -LiteralPath $repoPath)) {
        Write-Host "  [WARN] Path not found: $repoPath"
        return $results
    }

    # Verify it is a git repo
    $gitDir = Join-Path $repoPath '.git'
    if (-not (Test-Path -LiteralPath $gitDir)) {
        Write-Host "  [WARN] Not a git repo: $repoPath"
        return $results
    }

    $repoName = Split-Path $repoPath -Leaf

    try {
        $statusLines  = & git -C $repoPath status --porcelain 2>$null
        $uncommitted  = @($statusLines | Where-Object { $_ }).Count

        $todayCommits = & git -C $repoPath log --oneline --since="$todayStr 00:00" --until="$todayStr 23:59" 2>$null
        $commitCount  = @($todayCommits | Where-Object { $_ }).Count

        $branch = (& git -C $repoPath rev-parse --abbrev-ref HEAD 2>$null) -join ''

        $results += [PSCustomObject]@{
            Name        = $repoName
            Path        = $repoPath
            Branch      = $branch
            Uncommitted = $uncommitted
            Commits     = $commitCount
            CommitMsgs  = $todayCommits | Where-Object { $_ }
        }
    } catch {
        Write-Host "  [WARN] Git error on $repoName : $_"
    }

    return $results
}

function Get-ActiveDevServers {
    $devPorts = @()
    try {
        $conns = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
                 Where-Object { $_.LocalPort -ge 3000 -and $_.LocalPort -le 10000 }

        foreach ($c in $conns) {
            try {
                $proc = Get-Process -Id $c.OwningProcess -ErrorAction Stop
                $devPorts += [PSCustomObject]@{
                    Port    = $c.LocalPort
                    Process = $proc.Name
                }
            } catch {}
        }
    } catch {}

    return $devPorts | Sort-Object Port -Unique
}


# =============================================================================
# EXCEL OPEN/CLOSE HELPERS
# =============================================================================

# Holds the Excel COM instance used by Update-Excel so Open-ExcelVisible
# can make it visible at the end without opening a second instance.
$script:excelInstance = $null
$script:diaryWorkbook = $null

function Open-ExcelVisible {
    # Make the workbook visible after the script finishes.
    # Reuses $script:excelInstance written by Update-Excel.
    try {
        if ($script:excelInstance -and $script:diaryWorkbook) {
            $script:excelInstance.Visible = $true
            $script:excelInstance.WindowState = -4137   # xlMaximized
            $script:diaryWorkbook.Worksheets.Item('Diary').Activate()
            Write-Host "  [OK] Excel opened: $excelFile"
        } else {
            # Update-Excel did not run or failed - just shell-open the file
            Start-Process $excelFile
            Write-Host "  [OK] Excel launched: $excelFile"
        }
    } catch {
        try { Start-Process $excelFile } catch {}
        Write-Host "  [OK] Excel launched: $excelFile"
    }
}

# =============================================================================
# COMMIT HELPER
# =============================================================================

function Invoke-CommitHelper($dirtyRepos) {
    $committed = @()
    foreach ($repo in $dirtyRepos) {
        if ($repo.Uncommitted -eq 0) { continue }

        Write-Host ""
        Write-Host "  Repo: $($repo.Name)  ($($repo.Uncommitted) uncommitted change(s))"
        Write-Host "  Path: $($repo.Path)"
        Write-Host ""

        # Show what's changed
        $status = & git -C $repo.Path status --short 2>$null
        foreach ($line in $status) { Write-Host "    $line" }
        Write-Host ""

        $ans = Ask "Commit these changes? [y/N]"
        if ($ans -match '^[yY]$') {
            $msg = Ask "Commit message"
            if ([string]::IsNullOrWhiteSpace($msg)) {
                Write-Host "  [SKIP] No message given, skipping."
                continue
            }
            & git -C $repo.Path add -A 2>$null
            $result = & git -C $repo.Path commit -m $msg 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] Committed: `"$msg`""
                $committed += "$($repo.Name): `"$msg`""
                $repo.Uncommitted = 0
                $repo.Commits++
                if (-not $repo.CommitMsgs) { $repo.CommitMsgs = @() }
                $repo.CommitMsgs += $msg
            } else {
                Write-Host "  [FAIL] $result"
            }
        }
    }
    return $committed
}

# =============================================================================
# MARKDOWN WRITER
# =============================================================================

function Write-DailyMd($data) {
    $lines = @()
    $lines += "# $($now.ToString('dddd, dd MMMM yyyy'))"
    $lines += ""

    # Meetings
    $lines += "## Meetings"
    if ($data.Meetings.Count -gt 0) {
        foreach ($m in $data.Meetings) {
            $lines += "- **$($m.Time)** - $($m.Subject) ($($m.Duration) min)"
        }
    } else {
        $lines += "- No meetings recorded"
    }
    $lines += ""

    # Git
    $lines += "## Git Activity"
    if ($data.Git.Count -gt 0) {
        foreach ($r in $data.Git) {
            $lines += "### $($r.Name)  `[$($r.Branch)`]"
            if ($r.CommitMsgs -and @($r.CommitMsgs).Count -gt 0) {
                foreach ($c in $r.CommitMsgs) {
                    $lines += "- commit: `"$c`""
                }
            }
            if ($r.Uncommitted -gt 0) {
                $lines += "- $($r.Uncommitted) uncommitted change(s) remaining"
            }
        }
    } else {
        $lines += "- No git activity today"
    }
    $lines += ""

    # Dev Servers
    $lines += "## Dev Servers"
    if ($data.DevServers.Count -gt 0) {
        foreach ($s in $data.DevServers) {
            $lines += "- :$($s.Port)  ($($s.Process))"
        }
    } else {
        $lines += "- None detected"
    }
    $lines += ""

    # Your words
    $lines += "## What I Did"
    $lines += $data.WhatIDid
    $lines += ""

    $lines += "## Wins"
    $lines += if ($data.Wins) { $data.Wins } else { "-" }
    $lines += ""

    $lines += "## Blockers"
    $lines += if ($data.Blockers) { $data.Blockers } else { "-" }
    $lines += ""

    $lines += "## Tomorrow"
    $lines += if ($data.Tomorrow) { $data.Tomorrow } else { "-" }
    $lines += ""

    $lines += "---"
    $lines += "*Logged at $($now.ToString('HH:mm'))*"
    $lines += ""

    # Append or create
    if (Test-Path $todayFile) {
        Add-Content -Path $todayFile -Value ""
        Add-Content -Path $todayFile -Value "---"
        Add-Content -Path $todayFile -Value "*(Updated at $($now.ToString('HH:mm')))*"
        Add-Content -Path $todayFile -Value ""
        Add-Content -Path $todayFile -Value ($lines -join "`n")
    } else {
        Set-Content -Path $todayFile -Value ($lines -join "`n")
    }
}

# =============================================================================
# EXCEL UPDATER
# =============================================================================

function Update-Excel($data) {
    try {
        $excel = $null
        $wb    = $null
        $isNewInstance = $false

        # Check if DevDiary.xlsx is already open in a running Excel instance.
        # If so, write into that instance directly - no file lock conflict.
        $excelProcs = Get-Process -Name EXCEL -ErrorAction SilentlyContinue
        if ($excelProcs) {
            try {
                $runningXl = [System.Runtime.InteropServices.Marshal]::GetActiveObject('Excel.Application')
                foreach ($openWb in @($runningXl.Workbooks)) {
                    if ($openWb.FullName -ieq $excelFile) {
                        Write-Host "  [INFO] DevDiary.xlsx is already open - writing into the live workbook..."
                        $excel = $runningXl
                        $wb    = $openWb
                        break
                    }
                }
            } catch {}
        }

        # If not already open, spin up a hidden Excel instance
        if (-not $excel) {
            $excel = New-Object -ComObject Excel.Application -ErrorAction Stop
            $excel.Visible = $false
            $excel.DisplayAlerts = $false
            $isNewInstance = $true
        }

        $headers = @('Date','Day','Meetings','Meeting Count','Git Repo','Commits','Dev Servers','What I Did','Wins','Blockers','Tomorrow')

        if (-not $wb) {
            if (Test-Path $excelFile) {
                $wb = $excel.Workbooks.Open($excelFile)
            } else {
                $wb = $excel.Workbooks.Add()
                $ws = $wb.Worksheets.Item(1)
                $ws.Name = 'Diary'

                # Write headers
                for ($i = 0; $i -lt $headers.Count; $i++) {
                    $ws.Cells.Item(1, $i+1) = $headers[$i]
                    $ws.Cells.Item(1, $i+1).Font.Bold = $true
                    $ws.Cells.Item(1, $i+1).Interior.Color = 0x2D6A4F  # dark green
                    $ws.Cells.Item(1, $i+1).Font.Color = 0xFFFFFF
                }

                # Add a Dashboard sheet
                $dash = $wb.Worksheets.Add()
                $dash.Name = 'Dashboard'
                $dash.Cells.Item(1,1) = 'DevDiary Dashboard'
                $dash.Cells.Item(1,1).Font.Size = 18
                $dash.Cells.Item(1,1).Font.Bold = $true
                $dash.Cells.Item(3,1) = 'Open the Diary sheet to see all entries.'
                $dash.Cells.Item(4,1) = 'Use Ctrl+F to search across all your days.'

                $wb.Worksheets.Item('Diary').Activate()
            }
        }

        $ws = $wb.Worksheets.Item('Diary')

        # Find next empty row
        $lastRow = $ws.UsedRange.Rows.Count + 1
        if ($lastRow -lt 2) { $lastRow = 2 }

        # Check if today already has a row - update it instead
        $existingRow = $null
        for ($r = 2; $r -le $ws.UsedRange.Rows.Count; $r++) {
            if ($ws.Cells.Item($r, 1).Text -eq $todayStr) {
                $existingRow = $r
                break
            }
        }
        $row = if ($existingRow) { $existingRow } else { $lastRow }

        $meetingList  = ($data.Meetings | ForEach-Object { "$($_.Time) $($_.Subject)" }) -join ' | '
        $gitList      = ($data.Git | ForEach-Object { $_.Name }) -join ', '
        $commitCount  = ($data.Git | Measure-Object -Property Commits -Sum).Sum
        $serverList   = ($data.DevServers | ForEach-Object { ":$($_.Port)" }) -join ' '

        $ws.Cells.Item($row, 1)  = $todayStr
        $ws.Cells.Item($row, 2)  = $now.ToString('dddd')
        $ws.Cells.Item($row, 3)  = $meetingList
        $ws.Cells.Item($row, 4)  = $data.Meetings.Count
        $ws.Cells.Item($row, 5)  = $gitList
        $ws.Cells.Item($row, 6)  = $commitCount
        $ws.Cells.Item($row, 7)  = $serverList
        $ws.Cells.Item($row, 8)  = $data.WhatIDid
        $ws.Cells.Item($row, 9)  = $data.Wins
        $ws.Cells.Item($row, 10) = $data.Blockers
        $ws.Cells.Item($row, 11) = $data.Tomorrow

        # Zebra stripe
        if ($row % 2 -eq 0) {
            $rowRange = $ws.Range("A${row}:K${row}")
            $rowRange.Interior.Color = 0xE8F5E9
        }

        $ws.Columns.AutoFit() | Out-Null

        # Save: use SaveAs for new files, Save for existing open workbooks
        if ($isNewInstance) {
            $wb.SaveAs($excelFile)
            $wb.Close($false)
            $excel.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
        } else {
            $wb.Save()
            # Keep the instance alive so Open-ExcelVisible can use it
            $script:excelInstance = $excel
            $script:diaryWorkbook = $wb
        }

        Write-Host "  [OK] Excel updated: $excelFile"
    } catch {
        Write-Host "  [WARN] Could not update Excel: $_"
    }
}

# =============================================================================
# HTML DASHBOARD
# =============================================================================

function Update-Html($allEntries) {
    $rows = ''
    $cards = ''

    foreach ($entry in ($allEntries | Sort-Object Date -Descending)) {
        $rows += @"
        <tr>
            <td>$($entry.Date)</td>
            <td>$($entry.Day)</td>
            <td>$($entry.MeetingCount)</td>
            <td>$($entry.GitRepos)</td>
            <td>$($entry.Commits)</td>
            <td class="wrap">$($entry.WhatIDid)</td>
            <td class="wrap">$($entry.Wins)</td>
            <td class="wrap">$($entry.Blockers)</td>
        </tr>
"@
    }

    $totalDays     = $allEntries.Count
    $totalMeetings = ($allEntries | Measure-Object -Property MeetingCount -Sum).Sum
    $totalCommits  = ($allEntries | Measure-Object -Property Commits -Sum).Sum

    # Streak calc
    $streak = 0
    $checkDay = $now.Date
    while ($true) {
        $checkStr = $checkDay.ToString('yyyy-MM-dd')
        if ($allEntries | Where-Object { $_.Date -eq $checkStr }) {
            $streak++
            $checkDay = $checkDay.AddDays(-1)
        } else { break }
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>DevDiary Dashboard</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; color: #1a1a2e; }
  header { background: linear-gradient(135deg, #1a1a2e, #16213e); color: white; padding: 2rem; }
  header h1 { font-size: 2rem; }
  header p  { opacity: 0.7; margin-top: 0.3rem; }
  .stats { display: flex; gap: 1rem; padding: 1.5rem; flex-wrap: wrap; }
  .stat { background: white; border-radius: 12px; padding: 1.2rem 1.8rem; flex: 1; min-width: 140px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.08); text-align: center; }
  .stat .num { font-size: 2.2rem; font-weight: 700; color: #2d6a4f; }
  .stat .lbl { font-size: 0.8rem; color: #666; margin-top: 0.2rem; text-transform: uppercase; letter-spacing: 0.05em; }
  .section { padding: 0 1.5rem 2rem; }
  .section h2 { font-size: 1.1rem; color: #16213e; margin-bottom: 1rem; padding-bottom: 0.5rem;
                border-bottom: 2px solid #2d6a4f; }
  table { width: 100%; border-collapse: collapse; background: white;
          border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
  th { background: #2d6a4f; color: white; padding: 0.8rem 1rem; text-align: left;
       font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.05em; }
  td { padding: 0.75rem 1rem; border-bottom: 1px solid #f0f4f8; font-size: 0.9rem; vertical-align: top; }
  tr:hover td { background: #f0f7f4; }
  td.wrap { max-width: 200px; word-wrap: break-word; }
  .search-box { padding: 1rem 1.5rem; }
  .search-box input { width: 100%; max-width: 400px; padding: 0.6rem 1rem;
                      border: 2px solid #ddd; border-radius: 8px; font-size: 0.95rem; }
  .search-box input:focus { outline: none; border-color: #2d6a4f; }
  .updated { text-align: center; padding: 1rem; color: #999; font-size: 0.8rem; }
</style>
</head>
<body>

<header>
  <h1>DevDiary</h1>
  <p>Your personal work black box</p>
</header>

<div class="stats">
  <div class="stat"><div class="num">$totalDays</div><div class="lbl">Days Logged</div></div>
  <div class="stat"><div class="num">$totalMeetings</div><div class="lbl">Meetings</div></div>
  <div class="stat"><div class="num">$totalCommits</div><div class="lbl">Commits</div></div>
  <div class="stat"><div class="num">$streak</div><div class="lbl">Day Streak</div></div>
</div>

<div class="search-box">
  <input type="text" id="searchInput" placeholder="Search across all days..." onkeyup="filterTable()">
</div>

<div class="section">
  <h2>All Entries</h2>
  <table id="diaryTable">
    <thead>
      <tr>
        <th>Date</th><th>Day</th><th>Meetings</th><th>Git Repos</th>
        <th>Commits</th><th>What I Did</th><th>Wins</th><th>Blockers</th>
      </tr>
    </thead>
    <tbody>
      $rows
    </tbody>
  </table>
</div>

<div class="updated">Last updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')</div>

<script>
function filterTable() {
  var input = document.getElementById('searchInput').value.toLowerCase();
  var rows = document.querySelectorAll('#diaryTable tbody tr');
  rows.forEach(function(row) {
    row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
  });
}
</script>
</body>
</html>
"@

    Set-Content -Path $htmlFile -Value $html -Encoding UTF8
    Write-Host "  [OK] Dashboard updated: $htmlFile"
}

function Get-AllEntries {
    $entries = @()
    $mdFiles = Get-ChildItem -Path $dailyDir -Filter '*.md' -ErrorAction SilentlyContinue

    foreach ($f in $mdFiles) {
        $content  = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
        $dateStr  = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)

        $whatIDid = if ($content -match '(?s)## What I Did\s*\n(.*?)(\n##|\z)') { $Matches[1].Trim() } else { '' }
        $wins     = if ($content -match '(?s)## Wins\s*\n(.*?)(\n##|\z)')       { $Matches[1].Trim() } else { '' }
        $blockers = if ($content -match '(?s)## Blockers\s*\n(.*?)(\n##|\z)')   { $Matches[1].Trim() } else { '' }
        $meetingCount = ([regex]::Matches($content, '^- \*\*\d{2}:\d{2}\*\*', 'Multiline')).Count
        $commits  = ([regex]::Matches($content, 'commit:', 'Multiline')).Count
        $gitRepos = if ($content -match '(?s)## Git Activity\s*\n(.*?)(\n##|\z)') {
            ([regex]::Matches($Matches[1], '### (\S+)', 'Multiline') | ForEach-Object { $_.Groups[1].Value }) -join ', '
        } else { '' }

        try { $dayName = [datetime]::ParseExact($dateStr, 'yyyy-MM-dd', $null).ToString('dddd') } catch { $dayName = '' }

        $entries += [PSCustomObject]@{
            Date         = $dateStr
            Day          = $dayName
            MeetingCount = $meetingCount
            GitRepos     = $gitRepos
            Commits      = $commits
            WhatIDid     = $whatIDid -replace '<[^>]+>', '' -replace "`n", ' '
            Wins         = $wins     -replace '<[^>]+>', '' -replace "`n", ' '
            Blockers     = $blockers -replace '<[^>]+>', '' -replace "`n", ' '
        }
    }
    return $entries
}

# =============================================================================
# -Search FLAG
# =============================================================================

if ($Search) {
    Write-Header "Search: `"$Search`""
    $entries = Get-AllEntries
    $hits = $entries | Where-Object {
        $_.WhatIDid -match $Search -or $_.Wins -match $Search -or
        $_.Blockers -match $Search -or $_.GitRepos -match $Search
    }
    if ($hits) {
        $hits | Format-Table Date, Day, GitRepos, WhatIDid -AutoSize
        Write-Host "  $($hits.Count) result(s) found."
    } else {
        Write-Host "  No entries match `"$Search`"."
    }
    Write-Host ""
    exit 0
}

# =============================================================================
# -Week FLAG
# =============================================================================

if ($Week) {
    Write-Header "Last 7 Days"
    $entries = Get-AllEntries
    $cutoff  = $now.Date.AddDays(-7)
    $recent  = $entries | Where-Object {
        try { [datetime]::ParseExact($_.Date, 'yyyy-MM-dd', $null) -ge $cutoff } catch { $false }
    } | Sort-Object Date -Descending

    if ($recent) {
        $recent | Format-Table Date, Day, MeetingCount, GitRepos, Commits, WhatIDid -AutoSize
    } else {
        Write-Host "  No entries in the last 7 days."
    }
    Write-Host ""
    exit 0
}

# =============================================================================
# -Today FLAG
# =============================================================================

if ($ShowToday) {
    if (Test-Path $todayFile) {
        Get-Content $todayFile | Write-Host
    } else {
        Write-Host "  No entry for today yet. Run DevDiary.ps1 to create one."
    }
    exit 0
}

# =============================================================================
# MAIN: LOG TODAY
# =============================================================================

Ensure-Dir $diaryRoot
Ensure-Dir $dailyDir

Write-Header "DevDiary - End of Day Log"

# --- Collect auto data ---
# TODO: Set this to your local project/repo folder before first run
# Example: "C:\Users\YourName\Projects\my-app"
$projectPath = "C:\path\to\your\project"

Write-Section "Scanning your day..."
Write-Host "  Reading Outlook calendar..."
$meetings = Get-TodaysMeetings

Write-Host "  Reading Teams call history..."
$teamsCalls = Get-TeamsCallsToday
# Merge Teams calls into the meetings list for unified display and logging
$allMeetings = @($meetings) + @($teamsCalls) | Sort-Object Time

Write-Host "  Checking dev servers..."
$devServers = Get-ActiveDevServers

Write-Host "  Reading git activity from: $projectPath"
$gitActivity = @(Get-GitActivity $projectPath)

# --- Show what was found ---
$outlookCount = $meetings.Count
$teamsCount   = $teamsCalls.Count
Write-Section "MEETINGS TODAY (Outlook: $outlookCount  |  Teams calls: $teamsCount)"
if ($allMeetings.Count -gt 0) {
    foreach ($m in $allMeetings) {
        if ($m.Status -eq 'Teams') {
            Write-Host "  $($m.Time)  [Teams] $($m.Subject)"
        } else {
            Write-Host "  $($m.Time)  $($m.Subject)  ($($m.Duration) min)"
        }
    }
} else {
    Write-Host "  None found"
}

Write-Section "GIT ACTIVITY"
if ($gitActivity.Count -gt 0) {
    foreach ($r in $gitActivity) {
        $commitStr = if ($r.Commits -gt 0) { "$($r.Commits) commit(s)" } else { "0 commits" }
        $dirtyStr  = if ($r.Uncommitted -gt 0) { ", $($r.Uncommitted) uncommitted" } else { "" }
        Write-Host "  $($r.Name)  [$($r.Branch)]  -  $commitStr$dirtyStr"
        foreach ($c in $r.CommitMsgs) { Write-Host "    - `"$c`"" }
    }
} else {
    Write-Host "  No git activity / no path given"
}

Write-Section "DEV SERVERS"
if ($devServers.Count -gt 0) {
    foreach ($s in $devServers) { Write-Host "  :$($s.Port)  ($($s.Process))" }
} else {
    Write-Host "  None detected"
}

# --- Commit helper ---
$dirtyRepos = $gitActivity | Where-Object { $_.Uncommitted -gt 0 }
$newCommits = @()
if ($dirtyRepos.Count -gt 0) {
    Write-Host ""
    Write-Host "  You have uncommitted changes in $($dirtyRepos.Count) repo(s)."
    $doCommit = Ask "Handle commits now? [y/N]"
    if ($doCommit -match '^[yY]$') {
        $newCommits = Invoke-CommitHelper $dirtyRepos
    }
}

# --- Auto-build "What I Did" from today's commit messages ---
$allCommitMsgs = @()
foreach ($r in $gitActivity) {
    if ($r.CommitMsgs -and @($r.CommitMsgs).Count -gt 0) {
        foreach ($c in $r.CommitMsgs) {
            $allCommitMsgs += "- $c"
        }
    }
}
# Also include any commits just made via the helper above
foreach ($nc in $newCommits) {
    # format is "reponame: "msg"" - extract the message part
    if ($nc -match ':\s*"(.+)"$') {
        $msg = $Matches[1]
        if ($allCommitMsgs -notcontains "- $msg") {
            $allCommitMsgs += "- $msg"
        }
    }
}
$commitSummary = if ($allCommitMsgs.Count -gt 0) { $allCommitMsgs -join "`n" } else { '' }

# --- Your words ---
Write-Section "YOUR WORDS"
Write-Host ""

# Show the auto-filled commits so the user knows what was scraped
if ($commitSummary) {
    Write-Host "  Auto-filled from commits:"
    foreach ($line in ($commitSummary -split "`n")) { Write-Host "    $line" }
    Write-Host ""
    Write-Host "  Add anything extra below, or press Enter to keep only the commits above."
} else {
    Write-Host "  No commits found today."
}
$extra = Ask "What did you work on today? (press Enter to use commits only)"

# Merge: commits first, then any extra text the user typed
if ($commitSummary -and $extra) {
    $whatIDid = "$commitSummary`n$extra"
} elseif ($commitSummary) {
    $whatIDid = $commitSummary
} else {
    $whatIDid = $extra
}

$wins     = Ask "Any wins today? (or press Enter to skip)"
$blockers = Ask "Any blockers? (or press Enter to skip)"
$tomorrow = Ask "What's the first thing tomorrow?"

# --- Save ---
Write-Host ""
Write-Section "Saving..."

$data = [PSCustomObject]@{
    Meetings   = $allMeetings
    Git        = $gitActivity
    DevServers = $devServers
    WhatIDid   = $whatIDid
    Wins       = $wins
    Blockers   = $blockers
    Tomorrow   = $tomorrow
}

Write-DailyMd $data
Write-Host "  [OK] Daily entry: $todayFile"

Update-Excel $data

$allEntries = @(Get-AllEntries)
Update-Html $allEntries

# --- Summary ---
Write-Host ""
Write-Host "========================================"
Write-Host "  ALL DONE"
Write-Host "  Meetings logged    : $($allMeetings.Count) (Outlook: $outlookCount, Teams: $teamsCount)"
Write-Host "  Repos with activity: $($gitActivity.Count)"
if ($newCommits.Count -gt 0) {
    Write-Host "  Commits made now   : $($newCommits.Count)"
}
Write-Host "  Days logged total  : $($allEntries.Count)"
Write-Host ""
Write-Host "  Diary  -> $todayFile"
Write-Host "  Excel  -> $excelFile"
Write-Host "  Dashboard -> $htmlFile"
Write-Host "========================================"
Write-Host ""

# --- Open Excel so the user can see the updated workbook ---
Write-Host "  Opening DevDiary.xlsx..."
Open-ExcelVisible
Write-Host ""
