@echo off
cd /d "%~dp0"
echo BrenOS Safe Cleanup - preview first; no Windows components are deleted.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Safe-Cleanup.ps1" -DryRun
choice /M "Apply only the reversible cosmetic cleanup shown above"
if errorlevel 2 exit /b 0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Safe-Cleanup.ps1"
pause
