@echo off

REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
REM * The program nbc.exe must exist in the same folder as this file or be on the path! *  
REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


if exist nbc.exe goto download else goto nbcmissing


:nbcmissing
echo.
echo   The NBC/NCC compiler executable, nbc.exe, is missing.
echo   This file has to be in the same directory as this script
echo   or must reside in the Windows search path.
echo.
echo   Go to http://bricxcc.sourceforge.net/nbc
echo   and download the latest (beta) binary files,
echo   then place nbc.exe in this folder:
echo.
cd
echo.
echo   If you get compiler errors, try the very latest
echo   NBC version, the file should be included in 
echo   test_release.zip from http://bricxcc.sourceforge.net
echo.


goto end
:download

echo.
echo   This program compiles and downloads MotorControl22.nxc
echo   to the NXT brick. Please connect a single NXT brick
echo   via a USB cable and turn it on.
echo   Make sure Firmware 1.28 (or higher) is installed on the NXT.
echo   After a successful download the NXT will beep once...
echo.

pause

echo.
echo Compiling and downloading...
echo.

nbc -d -S=usb -v=128 MotorControl22.nxc


:end
echo.
echo Script finished.
pause