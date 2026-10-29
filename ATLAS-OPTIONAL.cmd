@echo off
echo AtlasOS is NOT part of BrenOS. Installing Atlas may require a Windows reinstall.
echo If you choose Atlas, read the official guide and BACK UP your files first.
choice /M "Open official AtlasOS installation documentation"
if errorlevel 2 exit /b 0
start "" "https://docs.atlasos.net/getting-started/install/install-playbook/"
