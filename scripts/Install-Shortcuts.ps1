# Create branded shortcuts (no reassociation of system executables).
[CmdletBinding()]
param([switch]$Desktop,[switch]$DryRun)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=Join-Path $env:LOCALAPPDATA 'BrenOS'
$iconDir=Join-Path $root 'assets\generated\icons\ico'
$startMenu=Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs\BrenOS'
$backup=Join-Path $root 'Backup\shortcuts.json'
if (-not (Test-Path $iconDir)) { throw 'Install BrenOS first to generate its icon pack.' }
$places=@($startMenu)
if ($Desktop) { $places+=([Environment]::GetFolderPath('DesktopDirectory')) }
$explorer=Join-Path $env:WINDIR 'explorer.exe'
$entries=@(
    @{label='BrenOS - This PC';target=$explorer;arguments='shell:MyComputerFolder';icon='computer'},
    @{label='BrenOS - Files';target=$explorer;arguments='shell:Downloads';icon='explorer'},
    @{label='BrenOS - Documents';target=$explorer;arguments='shell:Personal';icon='document'},
    @{label='BrenOS - Pictures';target=$explorer;arguments='shell:My Pictures';icon='pictures'},
    @{label='BrenOS - Terminal';target=(Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe');arguments='-NoProfile';icon='terminal'}
)
$saved=@()
if (Test-Path -LiteralPath $backup) { $saved=@(Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json) }
$scriptSaved=@()
foreach($dir in $places) {
    foreach($entry in $entries) {
        $path=Join-Path $dir ($entry.label+'.lnk')
        if (Test-Path -LiteralPath $path) { continue } # Never overwrite user shortcuts.
        if ($DryRun) { Write-Host "Would create $path"; continue }
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
        $shell=New-Object -ComObject WScript.Shell
        $lnk=$shell.CreateShortcut($path)
        $lnk.TargetPath=$entry.target
        $lnk.Arguments=$entry.arguments
        $lnk.IconLocation=(Join-Path $iconDir ($entry.icon+'.ico'))+',0'
        $lnk.Description='Branded BrenOS shortcut (Windows target unchanged)'
        $lnk.Save()
        $scriptSaved+=($path)
    }
}
if (-not $DryRun -and $scriptSaved.Count -gt 0) {
    New-Item -Path (Split-Path -Parent $backup) -ItemType Directory -Force | Out-Null
    @($saved)+@($scriptSaved) | ConvertTo-Json | Set-Content -LiteralPath $backup -Encoding UTF8
}
Write-Host 'No system executable, system icon resource or file association was modified.'
