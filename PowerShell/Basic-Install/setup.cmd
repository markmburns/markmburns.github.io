@ECHO OFF
REM run the powershell
REM take input to choose version, otherwise default to latest
powershell -ex bypass -file .\Basic-Install.ps1 %1
ECHO Restart after pause
pause
wpeutil reboot