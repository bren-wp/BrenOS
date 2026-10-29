[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$backup=Join-Path $env:LOCALAPPDATA 'BrenOS\Backup\cleanup-state.json'
if (-not (Test-Path -LiteralPath $backup)) {
    Write-Host 'Safe Cleanup backup not found; nothing to restore.'
    return
}
$state=Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json
foreach($entry in @($state.values)) {
    if ($entry.exists) {
        New-Item -Path $entry.key -Force | Out-Null
        New-ItemProperty -Path $entry.key -Name $entry.name -Value $entry.value -PropertyType DWord -Force | Out-Null
    } elseif(Test-Path $entry.key) {
        Remove-ItemProperty -Path $entry.key -Name $entry.name -ErrorAction SilentlyContinue
    }
}
Write-Host 'Safe Cleanup options restored to their original values.' -ForegroundColor Green
Write-Host 'Log off or restart Explorer for all changes to appear.'
