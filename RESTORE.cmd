@echo off
cd /d "%~dp0"
echo Restoring BrenOS visual settings, optional Safe Cleanup and branded shortcuts...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Restore-Cleanup.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Restore-Shortcuts.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Restore-BrenOS.ps1"
echo Your saved pre-BrenOS appearance values have been restored.
pause
