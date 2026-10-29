# Delete only shortcuts that BrenOS created and recorded itself.
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=Join-Path $env:LOCALAPPDATA 'BrenOS'
$backup=Join-Path $root 'Backup\shortcuts.json'
if (-not (Test-Path -LiteralPath $backup)) { Write-Host 'No shortcut backup.';return }
$paths=@(Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json)
foreach($path in $paths) {
    if (([string]$path).EndsWith('.lnk') -and (Test-Path -LiteralPath ([string]$path))) {
        Remove-Item -LiteralPath ([string]$path) -Force
    }
}
Write-Host 'BrenOS-created shortcuts restored; no Windows shortcuts were removed.'
