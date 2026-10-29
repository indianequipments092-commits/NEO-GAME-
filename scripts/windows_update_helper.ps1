param(
    [Parameter(Mandatory=$true)][string]$ArchivePath,
    [Parameter(Mandatory=$true)][string]$TargetDirectory,
    [Parameter(Mandatory=$true)][string]$ExecutableName,
    [Parameter(Mandatory=$true)][int]$ProcessId
)
$ErrorActionPreference = "Stop"
$target = [System.IO.Path]::GetFullPath($TargetDirectory)
$archive = [System.IO.Path]::GetFullPath($ArchivePath)
if (!(Test-Path -LiteralPath $archive -PathType Leaf)) { exit 10 }
if (!(Test-Path -LiteralPath $target -PathType Container)) { exit 11 }

# Wait until the game process has exited before touching its executable.
try { Wait-Process -Id $ProcessId -Timeout 90 -ErrorAction Stop } catch {
    if (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue) { exit 12 }
}
$temp = Join-Path $env:TEMP ("neon-update-" + [guid]::NewGuid().ToString("N"))
$backup = Join-Path $temp "backup"
$stage = Join-Path $temp "stage"
New-Item -ItemType Directory -Path $backup, $stage -Force | Out-Null
$changed = New-Object System.Collections.Generic.List[string]
try {
    Expand-Archive -LiteralPath $archive -DestinationPath $stage -Force
    $files = Get-ChildItem -LiteralPath $stage -File -Recurse
    if ($files.Count -eq 0) { throw "Update archive is empty" }
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($stage.TrimEnd([char]92).Length).TrimStart([char]92)
        $destination = Join-Path $target $relative
        $parent = Split-Path -Parent $destination
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        if (Test-Path -LiteralPath $destination -PathType Leaf) {
            $backupPath = Join-Path $backup $relative
            New-Item -ItemType Directory -Path (Split-Path -Parent $backupPath) -Force | Out-Null
            Copy-Item -LiteralPath $destination -Destination $backupPath -Force
        }
        Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
        $changed.Add($relative)
    }
    $exe = Join-Path $target $ExecutableName
    if (!(Test-Path -LiteralPath $exe -PathType Leaf)) { throw "Updated executable is missing" }
    Start-Process -FilePath $exe -WorkingDirectory $target
    Remove-Item -LiteralPath $archive -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    exit 0
} catch {
    $changedArray = $changed.ToArray()
    [array]::Reverse($changedArray)
    foreach ($relative in $changedArray) {
        $destination = Join-Path $target $relative
        $backupPath = Join-Path $backup $relative
        if (Test-Path -LiteralPath $backupPath -PathType Leaf) {
            Copy-Item -LiteralPath $backupPath -Destination $destination -Force
        } else {
            Remove-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue
        }
    }
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    exit 20
}
