# BrenOS Safe Cleanup. User-level and fully reversible. Windows 11.
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$HideDesktopSystemIcons
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
if ([Environment]::OSVersion.Platform -ne 'Win32NT') { throw 'Windows required.' }
if ([Environment]::OSVersion.Version.Build -lt 22000) { throw 'Windows 11 required.' }
$root=Join-Path $env:LOCALAPPDATA 'BrenOS'
$backup=Join-Path $root 'Backup\cleanup-state.json'
$recommend='HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$explorer='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$desktop='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
# Optional cosmetic switches only. Keep security, driver and recovery notifications.
$changes=@(
  @{key=$recommend;name='SoftLandingEnabled';value=0},
  @{key=$recommend;name='SystemPaneSuggestionsEnabled';value=0},
  @{key=$recommend;name='SubscribedContent-338388Enabled';value=0},
  @{key=$explorer;name='ShowSyncProviderNotifications';value=0},
  @{key=$explorer;name='TaskbarDa';value=0}
)
# Desktop icons are HIDDEN, not deleted. Recycle Bin stays available through Explorer.
if ($HideDesktopSystemIcons) {
  foreach($id in @(
    '{20D04FE0-3AEA-1069-A2D8-08002B30309D}', # This PC
    '{645FF040-5081-101B-9F08-00AA002F954E}', # Recycle Bin
    '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}', # Network
    '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'  # Control Panel
  )) {
    $changes+=@{key=$desktop;name=$id;value=1}
  }
}
if ($DryRun) {
  Write-Host 'BrenOS Safe Cleanup preview: no data will be deleted.' -ForegroundColor Cyan
  foreach($change in $changes) {Write-Host ("  {0} :: {1} => {2}" -f $change.key,$change.name,$change.value)}
  Write-Host 'Windows Security, UAC, Defender, Update, system dialogs, apps and drivers stay untouched.'
  return
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backup) | Out-Null
# Persist original values only once; never overwrite on repeated cleanup.
if (Test-Path -LiteralPath $backup) {
  $snapshot=Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json
  $previous=@($snapshot.values)
} else {
  $previous=@()
}
foreach ($change in $changes) {
  $exists=@($previous | Where-Object { $_.key -eq $change.key -and $_.name -eq $change.name }).Count -gt 0
  if (-not $exists) {
    $value=$null
    $found=$false
    if (Test-Path -LiteralPath $change.key) {
      $item=Get-ItemProperty -Path $change.key
      if ($item.PSObject.Properties.Name -contains $change.name) {
        $found=$true
        $value=$item.PSObject.Properties[$change.name].Value
      }
    }
    $previous+=([pscustomobject]@{key=$change.key;name=$change.name;exists=$found;value=$value})
  }
}
[pscustomobject]@{ version=1; values=@($previous) } |
  ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $backup -Encoding UTF8
foreach($change in $changes) {
  New-Item -Path $change.key -Force | Out-Null
  New-ItemProperty -Path $change.key -Name $change.name -PropertyType DWord -Value $change.value -Force | Out-Null
}
Write-Host 'Safe Cleanup applied. Restart Explorer or sign out for some changes to appear.' -ForegroundColor Green
Write-Host 'No Windows files or applications have been removed.'
