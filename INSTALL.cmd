@echo off
setlocal
cd /d "%~dp0"
where powershell.exe >nul 2>&1 || (echo Windows PowerShell not found.& pause & exit /b 1)
echo.
echo   BrenOS - Premium Windows Personalization
echo   Installs for the current user. No administrator access required.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-BrenOS.ps1"
if errorlevel 1 (echo BrenOS installation failed. No system files were modified.& pause & exit /b 1)
echo.
echo Installation finished. Press any key to close.
pause >nul
