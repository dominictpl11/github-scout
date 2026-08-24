<#
.SYNOPSIS
    Sync core/*.md into each adapter's references/ directory.

.DESCRIPTION
    core/ is the single source of truth. Adapters are distributed as
    self-contained directories, so they cannot reference ../core/ at runtime.
    This script copies core/*.md into <adapter>/references/ for each adapter.

    Files under <adapter>/references/ are build output. Do not edit them by
    hand -- changes will be overwritten on the next sync.

    The script is idempotent: running it twice produces the same result.

.PARAMETER Check
    Verify that every adapter's references/ is in sync with core/ without
    writing anything. Exits 1 when any adapter is stale. Intended for CI.

.EXAMPLE
    .\scripts\sync.ps1
    .\scripts\sync.ps1 -Check
#>

[CmdletBinding()]
param(
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$coreDir  = Join-Path $repoRoot 'core'

if (-not (Test-Path $coreDir)) {
    Write-Error "core/ not found at $coreDir"
    exit 1
}

$coreFiles = Get-ChildItem -Path $coreDir -Filter '*.md' -File
if ($coreFiles.Count -eq 0) {
    Write-Error 'core/ contains no .md files -- nothing to sync.'
    exit 1
}

# An adapter is any top-level directory holding a SKILL.md.
$adapters = Get-ChildItem -Path $repoRoot -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }

if ($adapters.Count -eq 0) {
    Write-Warning 'No adapter directories found (looking for */SKILL.md). Nothing to do.'
    exit 0
}

function Get-FileHashOrNull {
    param([string]$Path)
    if (Test-Path $Path) { return (Get-FileHash -Path $Path -Algorithm SHA256).Hash }
    return $null
}

$staleCount = 0

foreach ($adapter in $adapters) {
    $refDir = Join-Path $adapter.FullName 'references'

    if ($Check) {
        foreach ($file in $coreFiles) {
            $target = Join-Path $refDir $file.Name
            if ((Get-FileHashOrNull $target) -ne (Get-FileHashOrNull $file.FullName)) {
                Write-Host "STALE  $($adapter.Name)/references/$($file.Name)" -ForegroundColor Yellow
                $staleCount++
            }
        }
        continue
    }

    if (-not (Test-Path $refDir)) {
        New-Item -ItemType Directory -Path $refDir -Force | Out-Null
    }

    # Remove orphans: files in references/ that no longer exist in core/.
    Get-ChildItem -Path $refDir -Filter '*.md' -File -ErrorAction SilentlyContinue |
        Where-Object { $file = $_; -not ($coreFiles | Where-Object { $_.Name -eq $file.Name }) } |
        ForEach-Object {
            Write-Host "remove $($adapter.Name)/references/$($_.Name)" -ForegroundColor DarkGray
            Remove-Item -Path $_.FullName -Force
        }

    foreach ($file in $coreFiles) {
        $target = Join-Path $refDir $file.Name
        if ((Get-FileHashOrNull $target) -eq (Get-FileHashOrNull $file.FullName)) {
            Write-Host "ok     $($adapter.Name)/references/$($file.Name)" -ForegroundColor DarkGray
        } else {
            Copy-Item -Path $file.FullName -Destination $target -Force
            Write-Host "sync   $($adapter.Name)/references/$($file.Name)" -ForegroundColor Green
        }
    }
}

if ($Check) {
    if ($staleCount -gt 0) {
        Write-Host ''
        Write-Error "$staleCount file(s) out of sync. Run .\scripts\sync.ps1 to fix."
        exit 1
    }
    Write-Host 'All adapters are in sync with core/.' -ForegroundColor Green
    exit 0
}

Write-Host ''
Write-Host "Synced $($coreFiles.Count) core file(s) into $($adapters.Count) adapter(s)." -ForegroundColor Cyan
