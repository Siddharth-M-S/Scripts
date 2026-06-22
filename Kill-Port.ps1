# =============================================================================
# Kill-Port.ps1
# Author: Siddharth
# Find what is using a port and kill it.
#
# Usage:
#   .\Kill-Port.ps1              <- interactive: prompts you for a port
#   .\Kill-Port.ps1 -Port 3000   <- directly target port 3000
#   .\Kill-Port.ps1 -List        <- show all listening ports (no kill)
#
# What it does:
#   - Finds processes listening on the given port (TCP + UDP)
#   - Shows process name, PID, and full executable path
#   - Asks for confirmation before killing
#   - Supports killing multiple processes if more than one is on the port
# =============================================================================

param(
    [int]    $Port,
    [switch] $List
)

# =============================================================================
# HELPERS
# =============================================================================

function Write-Header($title) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  $title"
    Write-Host "  Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Write-Host "========================================"
    Write-Host ""
}

# Loaded once at startup - hashtable of PID -> CommandLine for fast lookup
$script:CimCmdMap = @{}
function Load-CimMap {
    try {
        Get-CimInstance Win32_Process -Property ProcessId, Name, CommandLine -ErrorAction Stop |
            ForEach-Object { $script:CimCmdMap[$_.ProcessId] = $_ }
    } catch {}
}

function Get-AppLabel($procId) {
    if ($procId -eq 0 -or $procId -eq $null) { return '' }
    $cim = $script:CimCmdMap[$procId]
    if (-not $cim) { return '' }
    $cmd = $cim.CommandLine
    if (-not $cmd) { return '' }

    if ($cmd -match '@angular[/\\]cli|ng\.js.*(serve|s )|ng serve')         { return 'Angular (ng serve)' }
    if ($cmd -match 'react-scripts\s+start')                                  { return 'React (CRA)' }
    if ($cmd -match '[/\\]vite[/\\]|vite\.js|"vite"')                        { return 'Vite dev server' }
    if ($cmd -match '[/\\]next[/\\]dist[/\\]|next\s+(dev|start)')            { return 'Next.js' }
    if ($cmd -match '@nestjs[/\\]|nest\s+start|nest\.js')                    { return 'NestJS' }
    if ($cmd -match 'webpack(\.js)?.*--(serve|watch|hot)')                   { return 'Webpack dev server' }
    if ($cmd -match 'vue-cli-service\s+serve')                               { return 'Vue CLI dev server' }
    if ($cmd -match 'nuxt\s+(dev|start)|nuxt\.js')                          { return 'Nuxt.js' }
    if ($cmd -match 'uvicorn|gunicorn|flask\s+run')                          { return 'Python web server' }
    if ($cmd -match 'java\s+')                                               { return 'Java app' }
    if ($cmd -match 'mysqld')                                                 { return 'MySQL Database' }
    if ($cmd -match 'postgres')                                               { return 'PostgreSQL Database' }

    # For node processes with no match, show a short hint from the command line
    if ($cim.Name -match '^node') {
        $short = $cmd -replace '^.*node(\.exe)?\s+',''
        if ($short.Length -gt 60) { $short = $short.Substring(0,57) + '...' }
        return $short
    }

    return ''
}

function Get-ProcInfo($procId) {
    if ($procId -eq 0 -or $procId -eq $null) {
        return [PSCustomObject]@{ Name = 'System'; Path = 'N/A' }
    }
    try {
        $p = Get-Process -Id $procId -ErrorAction Stop
        return [PSCustomObject]@{
            Name = $p.Name
            Path = if ($p.Path) { $p.Path } else { '(path unavailable - run as admin for full details)' }
        }
    } catch {
        return [PSCustomObject]@{ Name = '(unknown)'; Path = '(process ended or access denied)' }
    }
}

function Get-AllListening {
    $rows = [System.Collections.Generic.List[object]]::new()

    # TCP
    try {
        $tcpConns = Get-NetTCPConnection -State Listen -ErrorAction Stop
        foreach ($c in $tcpConns) {
            $info = Get-ProcInfo $c.OwningProcess
            $rows.Add([PSCustomObject]@{
                Port    = $c.LocalPort
                Proto   = 'TCP'
                PID     = $c.OwningProcess
                Process = $info.Name
                App     = Get-AppLabel $c.OwningProcess
                Path    = $info.Path
            })
        }
    } catch {
        Write-Host "  [WARN] Could not read TCP connections: $_"
    }

    # UDP
    try {
        $udpConns = Get-NetUDPEndpoint -ErrorAction Stop
        foreach ($c in $udpConns) {
            $info = Get-ProcInfo $c.OwningProcess
            $rows.Add([PSCustomObject]@{
                Port    = $c.LocalPort
                Proto   = 'UDP'
                PID     = $c.OwningProcess
                Process = $info.Name
                App     = Get-AppLabel $c.OwningProcess
                Path    = $info.Path
            })
        }
    } catch {
        Write-Host "  [WARN] Could not read UDP endpoints: $_"
    }

    return $rows
}

function Get-OnPort($portNum) {
    $rows = [System.Collections.Generic.List[object]]::new()

    try {
        $tcpConns = Get-NetTCPConnection -LocalPort $portNum -State Listen -ErrorAction SilentlyContinue
        foreach ($c in $tcpConns) {
            $rows.Add([PSCustomObject]@{ Proto = 'TCP'; PID = $c.OwningProcess })
        }
    } catch {}

    try {
        $udpConns = Get-NetUDPEndpoint -LocalPort $portNum -ErrorAction SilentlyContinue
        foreach ($c in $udpConns) {
            $rows.Add([PSCustomObject]@{ Proto = 'UDP'; PID = $c.OwningProcess })
        }
    } catch {}

    # Also check ESTABLISHED TCP (dev servers often show as ESTABLISHED, not LISTEN)
    try {
        $estConns = Get-NetTCPConnection -LocalPort $portNum -ErrorAction SilentlyContinue |
                    Where-Object { $_.State -ne 'Listen' }
        foreach ($c in $estConns) {
            $rows.Add([PSCustomObject]@{ Proto = 'TCP'; PID = $c.OwningProcess })
        }
    } catch {}

    return $rows
}

# =============================================================================
# LIST MODE  (-List)
# =============================================================================

if ($List) {
    Write-Header "Listening Ports"
    Load-CimMap

    $all = Get-AllListening | Sort-Object Port, Proto

    if (-not $all -or $all.Count -eq 0) {
        Write-Host "  No listening ports found."
        Write-Host ""
        exit 0
    }

    # Dedupe by Port+Proto+PID
    $unique = $all | Sort-Object Port, Proto, PID -Unique
    $unique | Format-Table Port, Proto, PID, Process, App, Path -AutoSize
    Write-Host "  Total: $($unique.Count) listening endpoint(s)"
    Write-Host ""
    exit 0
}

# =============================================================================
# KILL MODE
# =============================================================================

Write-Header "Port Killer"

# If no port given, prompt
if (-not $Port) {
    $rawInput = Read-Host "  Enter port number to kill"
    if ($rawInput -notmatch '^\d+$') {
        Write-Host "  [ERROR] Invalid port: '$rawInput'"
        Write-Host ""
        exit 1
    }
    $Port = [int]$rawInput
}

Write-Host "  Searching for processes on port $Port ..."
Load-CimMap
Write-Host ""

$conns = Get-OnPort $Port

if (-not $conns -or $conns.Count -eq 0) {
    Write-Host "  [INFO] Nothing is using port $Port."
    Write-Host ""
    exit 0
}

# Deduplicate by PID
$uniqueProcIds = $conns | Select-Object -ExpandProperty PID -Unique

$found = foreach ($procId in $uniqueProcIds) {
    $info  = Get-ProcInfo $procId
    $proto = ($conns | Where-Object { $_.PID -eq $procId } | Select-Object -First 1).Proto
    [PSCustomObject]@{
        PID     = $procId
        Process = $info.Name
        Proto   = $proto
        Path    = $info.Path
    }
}

# Show what was found
Write-Host "  Found $($found.Count) process(es) on port $Port :"
Write-Host ""
$found | Format-Table PID, Process, Proto, Path -AutoSize

# Confirm
$confirm = Read-Host "  Kill the above process(es)? [y/N]"
if ($confirm -notmatch '^[yY]$') {
    Write-Host ""
    Write-Host "  [CANCELLED] Nothing was killed."
    Write-Host ""
    exit 0
}

Write-Host ""

$killed = 0
$failed = 0

foreach ($item in $found) {
    try {
        Stop-Process -Id $item.PID -Force -ErrorAction Stop
        Write-Host "  [OK]   Killed '$($item.Process)' (PID $($item.PID))"
        $killed++
    } catch {
        Write-Host "  [FAIL] Could not kill '$($item.Process)' (PID $($item.PID)): $_"
        $failed++
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "  DONE  -  Port $Port"
Write-Host "  Killed : $killed"
Write-Host "  Failed : $failed"
Write-Host "========================================"
Write-Host ""
