# Copyright (c) 2026 Brendigo. Licensed under the repository MIT license.
# No admin rights; no system DLL patches; no changes to Defender, UAC, services, or Windows Update.
[CmdletBinding()]
param(
    [ValidateSet('Flow','Dawn','Midnight')][string]$Wallpaper='Flow',
    [switch]$DryRun,
    [switch]$NoShortcut
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
if ([Environment]::OSVersion.Platform -ne 'Win32NT') { throw 'BrenOS runs on Windows 11.' }
$root=Split-Path -Parent $PSScriptRoot
$assets=Join-Path $root 'assets\generated'
$target=Join-Path $env:LOCALAPPDATA 'BrenOS'
$stateFile=Join-Path $target 'Backup\state.json'
$srcWallpaper=Join-Path $assets ("wallpapers\BrenOS-$Wallpaper.jpg")
if (-not (Test-Path -LiteralPath $srcWallpaper)) {
    throw 'No compiled assets found. Download the BrenOS installer ZIP from Releases, not the GitHub source ZIP.'
}
$os=[Environment]::OSVersion.Version.Build
if ($os -lt 22000) { throw 'BrenOS currently supports Windows 11 (build 22000+).' }
$personal='HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$desktop='HKCU:\Control Panel\Desktop'
function Read-Reg([string]$key,[string]$name) {
    if (Test-Path $key) {
        $item=Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
        if ($null -ne $item -and $item.PSObject.Properties.Name -contains $name) {
            return [pscustomobject]@{Key=$key;Name=$name;Exists=$true;Value=$item.$name}
        }
    }
    return [pscustomobject]@{Key=$key;Name=$name;Exists=$false;Value=$null}
}
function Set-DesktopWallpaper([string]$file) {
    if (-not ('BrenOS.NativeWallpaper' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace BrenOS {
 public static class NativeWallpaper {
  [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
  public static extern bool SystemParametersInfo(int action,int param,string value,int flags);
 }
}
'@
    }
    if (-not [BrenOS.NativeWallpaper]::SystemParametersInfo(20,0,$file,3)) {
        throw "Windows wallpaper API failed with error $([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
    }
}
if ($DryRun) {
    Write-Host "BrenOS preview: $Wallpaper wallpaper, dark applications, theme and desktop shortcut." -ForegroundColor Cyan
    Write-Host "Assets source: $assets"
    Write-Host "Install destination: $target"
    Write-Host 'No administrator rights, Windows image replacement, AtlasOS automation or system-file modification.'
    return
}
New-Item -Path (Join-Path $target 'Backup') -ItemType Directory -Force | Out-Null
# Preserve FIRST pre-BrenOS snapshot across reinstalls. Never overwrite it.
if (-not (Test-Path -LiteralPath $stateFile)) {
    $reg=@(
       (Read-Reg $personal 'AppsUseLightTheme')
       (Read-Reg $personal 'SystemUsesLightTheme')
       (Read-Reg $desktop 'WallPaper')
       (Read-Reg $desktop 'WallpaperStyle')
       (Read-Reg $desktop 'TileWallpaper')
    )
    $oldWall=[string](($reg | Where-Object Name -eq 'WallPaper' | Select-Object -First 1).Value)
    $backupWallpaper=''
    if ($oldWall -and (Test-Path -LiteralPath $oldWall -PathType Leaf)) {
        $suffix=[IO.Path]::GetExtension($oldWall)
        if ($suffix -notin @('.jpg','.jpeg','.png','.bmp')) { $suffix='.jpg' }
        $backupWallpaper=Join-Path $target ("Backup\previous-wallpaper$suffix")
        Copy-Item -LiteralPath $oldWall -Destination $backupWallpaper -Force
    }
    [pscustomobject]@{
        version='1.0'; date=(Get-Date).ToString('o'); registry=@($reg);
        previousWallpaper=$backupWallpaper; shortcutPath=''
    } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $stateFile -Encoding UTF8
}
$targetAssets=Join-Path $target 'assets'
# Copy into an independent location; original ZIP may safely be deleted after installation.
if ([IO.Path]::GetFullPath($assets) -ne [IO.Path]::GetFullPath((Join-Path $targetAssets 'generated'))) {
    New-Item -Path $targetAssets -ItemType Directory -Force | Out-Null
    Copy-Item -LiteralPath $assets -Destination $targetAssets -Recurse -Force
}
$targetScripts=Join-Path $target 'scripts'
New-Item -Path $targetScripts -ItemType Directory -Force | Out-Null
foreach ($name in @('Restore-BrenOS.ps1','Restore-Cleanup.ps1','Safe-Cleanup.ps1','BrenOS-Center.ps1','Install-BrenOS.ps1')) {
    $src=Join-Path $PSScriptRoot $name
    $dst=Join-Path $targetScripts $name
    if ([IO.Path]::GetFullPath($src) -ne [IO.Path]::GetFullPath($dst)) {
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
}
New-Item -Path $personal -Force | Out-Null
New-ItemProperty -Path $personal -Name AppsUseLightTheme -PropertyType DWord -Value 0 -Force | Out-Null
New-ItemProperty -Path $personal -Name SystemUsesLightTheme -PropertyType DWord -Value 0 -Force | Out-Null
Set-ItemProperty -Path $desktop -Name WallpaperStyle -Value '10'
Set-ItemProperty -Path $desktop -Name TileWallpaper -Value '0'
$wall=Join-Path $targetAssets ("generated\wallpapers\BrenOS-$Wallpaper.jpg")
Set-DesktopWallpaper $wall
$themeFolder=Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Themes'
New-Item -Path $themeFolder -ItemType Directory -Force | Out-Null
$themePath=Join-Path $themeFolder 'BrenOS-Premium.theme'
@"
[Theme]
DisplayName=BrenOS Premium
[Control Panel\Desktop]
Wallpaper=$wall
WallpaperStyle=10
TileWallpaper=0
[VisualStyles]
Path=%ResourceDir%\Themes\Aero\Aero.msstyles
ColorStyle=NormalColor
Size=NormalSize
[MasterThemeSelector]
MTSM=DABJDKT
"@ | Set-Content -LiteralPath $themePath -Encoding Unicode
if (-not $NoShortcut) {
    $desktopDir=[Environment]::GetFolderPath('DesktopDirectory')
    $shortcutPath=Join-Path $desktopDir 'BrenOS Control Center.lnk'
    if (-not (Test-Path -LiteralPath $shortcutPath)) {
        $sh=New-Object -ComObject WScript.Shell
        $lnk=$sh.CreateShortcut($shortcutPath)
        $lnk.TargetPath=(Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe')
        $lnk.Arguments='-NoProfile -ExecutionPolicy Bypass -File "'+(Join-Path $targetScripts 'BrenOS-Center.ps1')+'"'
        $lnk.WorkingDirectory=$target
        $lnk.Description='BrenOS - personalization and restore'
        $ico=Join-Path $targetAssets 'generated\brand\BrenOS.ico'
        if (Test-Path $ico) {$lnk.IconLocation="$ico,0"}
        $lnk.Save()
        $snapshot=Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
        $snapshot.shortcutPath=$shortcutPath
        $snapshot | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $stateFile -Encoding UTF8
    }
}
Write-Host "BrenOS installed successfully: $wall" -ForegroundColor Green
Write-Host 'Lock screen and protected Windows UI remain controlled by Windows Settings.'
Write-Host 'To uninstall: run RESTORE.cmd or open BrenOS Control Center.'
