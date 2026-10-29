@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-Shortcuts.ps1" -DryRun
choice /M "Create BrenOS branded shortcuts in Start menu"
if errorlevel 2 exit /b 0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-Shortcuts.ps1"
pause
