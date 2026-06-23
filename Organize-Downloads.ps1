# =============================================================================
# Organize-Downloads.ps1
# Author: Siddharth
# Run this script monthly to organize your Downloads folder.
# Scheduled to run daily; only acts on the first Monday of each month.
#
# What it does:
#   - Moves FILES older than 30 days into type-based folders (Images, Videos, etc.)
#   - Moves FOLDERS older than 30 days into a "Folders\" subfolder
#   - Files/folders with no or unusual extensions go into "Others\"
#   - Skips the Scripts\ folder and all type folders created by this script
#   - Handles duplicate name conflicts automatically
#
# Type folders:
#   Images    - jpg, jpeg, png, gif, bmp, webp, svg, ico, tiff, avif, heic, raw
#   Videos    - mp4, mkv, avi, mov, wmv, flv, webm, m4v, mpeg, mpg
#   Audio     - mp3, m4a, wav, ogg, flac, aac, wma, opus
#   Documents - pdf, docx, doc, xlsx, xls, pptx, ppt, txt, md, epub, one, csv
#   Archives  - zip, rar, tar, gz, 7z, bz2, xz, iso, img, dmg, pkg, deb, rpm
#   Code      - py, js, ts, css, html, htm, php, java, class, rb, go, rs, cpp,
#               c, h, sql, xml, json, yaml, yml, toml, ini, cfg, ps1, bat, sh
#   Executables - exe, msi, vsix, vsixpackage, apk, rdp
#   Data      - db, sqlite, dat, log, tmp, eml, ics, jar
#   Others    - everything else
# =============================================================================

param(
    [switch]$Force   # Use -Force to run manually on any day, skipping the guard
)

$downloads = "$env:USERPROFILE\Downloads"
$cutoff    = (Get-Date).AddDays(-30)

# Monthly guard: run on the first Monday on or after the 1st of the month.
# This ensures it never falls on a weekend and is never missed if the 1st is Sat/Sun.
if (-not $Force) {
    $today = Get-Date
    # Find the first Monday >= the 1st of this month
    $firstOfMonth = Get-Date -Year $today.Year -Month $today.Month -Day 1
    $daysUntilMonday = (8 - [int]$firstOfMonth.DayOfWeek) % 7   # 0=Sun,1=Mon,...
    $targetDay = $firstOfMonth.AddDays($daysUntilMonday).Day
    if ($today.Day -ne $targetDay) {
        exit 0
    }
}

# Map each extension (lowercase, no dot) to a type folder name
$extensionMap = @{
    # Images
    'jpg'='Images'; 'jpeg'='Images'; 'png'='Images'; 'gif'='Images'
    'bmp'='Images'; 'webp'='Images'; 'svg'='Images'; 'ico'='Images'
    'tiff'='Images'; 'tif'='Images'; 'avif'='Images'; 'heic'='Images'
    'heif'='Images'; 'raw'='Images'; 'cr2'='Images'; 'nef'='Images'
    # Videos
    'mp4'='Videos'; 'mkv'='Videos'; 'avi'='Videos'; 'mov'='Videos'
    'wmv'='Videos'; 'flv'='Videos'; 'webm'='Videos'; 'm4v'='Videos'
    'mpeg'='Videos'; 'mpg'='Videos'; '3gp'='Videos'
    # Audio
    'mp3'='Audio'; 'm4a'='Audio'; 'wav'='Audio'; 'ogg'='Audio'
    'flac'='Audio'; 'aac'='Audio'; 'wma'='Audio'; 'opus'='Audio'
    # Documents
    'pdf'='Documents'; 'docx'='Documents'; 'doc'='Documents'
    'xlsx'='Documents'; 'xls'='Documents'; 'pptx'='Documents'; 'ppt'='Documents'
    'txt'='Documents'; 'md'='Documents'; 'epub'='Documents'; 'one'='Documents'
    'csv'='Documents'; 'rtf'='Documents'; 'odt'='Documents'; 'ods'='Documents'
    # Archives
    'zip'='Archives'; 'rar'='Archives'; 'tar'='Archives'; 'gz'='Archives'
    '7z'='Archives'; 'bz2'='Archives'; 'xz'='Archives'; 'iso'='Archives'
    'img'='Archives'; 'dmg'='Archives'; 'pkg'='Archives'; 'deb'='Archives'
    'rpm'='Archives'; 'vhd'='Archives'
    # Code
    'py'='Code'; 'js'='Code'; 'ts'='Code'; 'css'='Code'; 'html'='Code'
    'htm'='Code'; 'php'='Code'; 'java'='Code'; 'class'='Code'; 'rb'='Code'
    'go'='Code'; 'rs'='Code'; 'cpp'='Code'; 'c'='Code'; 'h'='Code'
    'sql'='Code'; 'xml'='Code'; 'json'='Code'; 'yaml'='Code'; 'yml'='Code'
    'toml'='Code'; 'ini'='Code'; 'cfg'='Code'; 'ps1'='Code'; 'bat'='Code'
    'sh'='Code'; 'bash'='Code'
    # Executables
    'exe'='Executables'; 'msi'='Executables'; 'vsix'='Executables'
    'vsixpackage'='Executables'; 'apk'='Executables'; 'rdp'='Executables'
    'dll'='Executables'; 'sys'='Executables'
    # Data
    'db'='Data'; 'sqlite'='Data'; 'dat'='Data'; 'log'='Data'
    'tmp'='Data'; 'eml'='Data'; 'ics'='Data'; 'jar'='Data'
    'torrent'='Data'
}

# Folders managed by this script - never move these
$managedFolders = @(
    'Scripts','Folders','Others',
    'Images','Videos','Audio','Documents','Archives','Code','Executables','Data'
)

function Get-FolderName($extension) {
    $clean = $extension.TrimStart('.').ToLower()
    if ([string]::IsNullOrWhiteSpace($clean) -or $clean -notmatch '^[a-zA-Z0-9_]+$') {
        return 'Others'
    }
    if ($extensionMap.ContainsKey($clean)) {
        return $extensionMap[$clean]
    }
    return 'Others'
}

function Get-SafeDestination($destDir, $name) {
    $destPath = Join-Path $destDir $name
    if (-not (Test-Path -LiteralPath $destPath)) { return $destPath }

    $base      = [System.IO.Path]::GetFileNameWithoutExtension($name)
    $ext       = [System.IO.Path]::GetExtension($name)
    $counter   = 1
    do {
        $destPath = Join-Path $destDir "$base`_$counter$ext"
        $counter++
    } while (Test-Path -LiteralPath $destPath)

    return $destPath
}

function Ensure-Dir($path) {
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "  Downloads Organizer"
Write-Host "  Cutoff : files/folders older than 30 days"
Write-Host "  Groups : Images, Videos, Audio, Documents,"
Write-Host "           Archives, Code, Executables, Data, Others"
Write-Host "  Date  : $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Host "========================================"
Write-Host ""

$filesMoved   = 0
$filesSkipped = 0
$foldersMoved = 0
$foldersSkipped = 0

# ── CONSOLIDATE EXTENSION-NAMED FOLDERS ───────────────────────────────────────
# e.g. Downloads\PNG\  ->  Downloads\Images\
#      Downloads\PHP\  ->  Downloads\Code\
Write-Host "[ CONSOLIDATE EXTENSION FOLDERS ]"
$consolidateMoved  = 0
$consolidateSkipped = 0

$allDirs = Get-ChildItem -LiteralPath $downloads -Directory |
           Where-Object { $_.Name -notin $managedFolders }

foreach ($extFolder in $allDirs) {
    $ext         = $extFolder.Name.ToLower()
    $broadFolder = $null

    if ($extensionMap.ContainsKey($ext)) {
        $broadFolder = $extensionMap[$ext]
    }

    if (-not $broadFolder) {
        Write-Host "  [SKIP] $($extFolder.Name)\ - no matching category"
        continue
    }

    $destDir = Join-Path $downloads $broadFolder
    Ensure-Dir $destDir

    $children = Get-ChildItem -LiteralPath $extFolder.FullName -Recurse -File
    $allMoved = $true

    foreach ($file in $children) {
        $destPath = Get-SafeDestination $destDir $file.Name
        try {
            Move-Item -LiteralPath $file.FullName -Destination $destPath
            Write-Host "  [OK] $($extFolder.Name)\$($file.Name)  ->  $broadFolder\"
            $consolidateMoved++
        } catch {
            Write-Host "  [FAIL] $($extFolder.Name)\$($file.Name): $_"
            $consolidateSkipped++
            $allMoved = $false
        }
    }

    # Remove the now-empty extension folder (and any empty subfolders)
    if ($allMoved) {
        try {
            Remove-Item -LiteralPath $extFolder.FullName -Recurse -Force
            Write-Host "  [REMOVED] $($extFolder.Name)\"
        } catch {
            Write-Host "  [WARN] Could not remove $($extFolder.Name)\: $_"
        }
    }
}

Write-Host ""

# ── MOVE FILES ────────────────────────────────────────────────────────────────
Write-Host "[ FILES ]"
$oldFiles = Get-ChildItem -LiteralPath $downloads -File |
            Where-Object { $_.LastWriteTime -lt $cutoff }

foreach ($file in $oldFiles) {
    $folderName = Get-FolderName $file.Extension
    $destDir    = Join-Path $downloads $folderName

    Ensure-Dir $destDir

    $destPath = Get-SafeDestination $destDir $file.Name

    try {
        Move-Item -LiteralPath $file.FullName -Destination $destPath
        Write-Host "  [OK] $($file.Name)  ->  $folderName\"
        $filesMoved++
    } catch {
        Write-Host "  [FAIL] $($file.Name): $_"
        $filesSkipped++
    }
}

Write-Host ""

# ── MOVE FOLDERS ──────────────────────────────────────────────────────────────
Write-Host "[ FOLDERS ]"
$foldersBase = Join-Path $downloads "Folders"
Ensure-Dir $foldersBase

$oldFolders = Get-ChildItem -LiteralPath $downloads -Directory |
              Where-Object { $_.LastWriteTime -lt $cutoff -and $_.Name -notin $managedFolders }

foreach ($folder in $oldFolders) {
    $destPath = Get-SafeDestination $foldersBase $folder.Name

    try {
        Move-Item -LiteralPath $folder.FullName -Destination $destPath
        Write-Host "  [OK] $($folder.Name)\  ->  Folders\"
        $foldersMoved++
    } catch {
        Write-Host "  [FAIL] $($folder.Name): $_"
        $foldersSkipped++
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "  DONE"
Write-Host "  Consolidated : $consolidateMoved files  (skipped: $consolidateSkipped)"
Write-Host "  Files  moved : $filesMoved   (skipped: $filesSkipped)"
Write-Host "  Folders moved: $foldersMoved  (skipped: $foldersSkipped)"
Write-Host "========================================"
Write-Host ""
