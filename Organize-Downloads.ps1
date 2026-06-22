# =============================================================================
# Organize-Downloads.ps1
# Author: Siddharth
# Run this script monthly to organize your Downloads folder.
#
# What it does:
#   - Moves FILES older than 30 days into extension-based folders (PDF, ZIP, etc.)
#   - Moves FOLDERS older than 30 days into a "Folders\" subfolder
#   - Files/folders with no or unusual extensions go into "Others\"
#   - Skips the Scripts\ folder and all extension folders created by this script
#   - Handles duplicate name conflicts automatically
# =============================================================================

$downloads = "$env:USERPROFILE\Downloads"
$cutoff    = (Get-Date).AddDays(-30)

# Folders managed by this script - never move these
$managedFolders = @(
    'Scripts','Folders','Others',
    'CSV','ZIP','PDF','JPG','JPEG','PNG','HTM','XLSX','EXE','RDP','JSON',
    'PPTX','HTML','MD','DOCX','MSI','VSIX','TXT','JAR','SQL','WEBP','PHP',
    'XLS','MP3','M4A','MP4','TMP','SVG','AVIF','VSIXPACKAGE','GIF','JAVA',
    'XML','TS','EML','ONE','ICS','EPUB','BAT','PS1','PPT','CLASS','RAR',
    'TAR','GZ','7Z','BMP','ICO','TIFF','WAV','OGG','FLAC','AVI','MKV',
    'MOV','CSS','JS','PY','RB','GO','RS','CPP','C','H','TOML','YAML','YML',
    'INI','CFG','LOG','DAT','DB','SQLITE','DLL','SYS','ISO','IMG','VHD',
    'TORRENT','APK','DMG','PKG','DEB','RPM'
)

function Get-FolderName($extension) {
    $clean = $extension.TrimStart('.')
    if ([string]::IsNullOrWhiteSpace($clean) -or $clean -notmatch '^[a-zA-Z0-9_]+$') {
        return 'Others'
    }
    return $clean.ToUpper()
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
Write-Host "  Cutoff: files/folders older than 30 days"
Write-Host "  Date  : $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Host "========================================"
Write-Host ""

$filesMoved   = 0
$filesSkipped = 0
$foldersMoved = 0
$foldersSkipped = 0

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
Write-Host "  Files  moved : $filesMoved   (skipped: $filesSkipped)"
Write-Host "  Folders moved: $foldersMoved  (skipped: $foldersSkipped)"
Write-Host "========================================"
Write-Host ""
