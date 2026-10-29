# Copyright (c) 2026 Brendigo. MIT.
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$root=Join-Path $env:LOCALAPPDATA 'BrenOS'
$statePath=Join-Path $root 'Backup\state.json'
if (-not (Test-Path -LiteralPath $statePath)) { Write-Warning 'BrenOS backup not found; nothing to restore.'; return }
$state=Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
foreach ($r in @($state.registry)) {
    if ($r.Exists) {
        New-Item -Path $r.Key -Force | Out-Null
        Set-ItemProperty -Path $r.Key -Name $r.Name -Value $r.Value
    } elseif (Test-Path $r.Key) {
        Remove-ItemProperty -Path $r.Key -Name $r.Name -ErrorAction SilentlyContinue
    }
}
$image=[string]$state.previousWallpaper
if (-not $image -or -not (Test-Path -LiteralPath $image)) {
    $old=@($state.registry | Where-Object Name -eq 'WallPaper' | Select-Object -First 1)
    if ($old.Count -gt 0) { $image=[string]$old[0].Value }
}
if ($image -and (Test-Path -LiteralPath $image)) {
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
    if (-not [BrenOS.NativeWallpaper]::SystemParametersInfo(20,0,$image,3)) {
        Write-Warning 'Wallpaper restore via Windows API failed; choose it in Windows Settings.'
    }
}
if ($state.shortcutPath -and (Test-Path -LiteralPath ([string]$state.shortcutPath))) {
    Remove-Item -LiteralPath ([string]$state.shortcutPath) -Force
}
$theme=Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Themes\BrenOS-Premium.theme'
if (Test-Path -LiteralPath $theme) {Remove-Item -LiteralPath $theme -Force}
Write-Host 'Original saved settings restored. Backup and assets kept for safety.' -ForegroundColor Green
