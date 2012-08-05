@echo off

REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
REM * The program NeXTTool.exe must exist in the same folder as this file or be on the path!*  
REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


if not exist NeXTTool.exe goto nexttoolmissing
if not exist MotorControl22.rxe goto binarymissing

goto download

goto end
:nexttoolmissing
echo.
echo   The NeXTTool, NeXTTool.exe, is missing.
echo   This file has to be in the same directory as this script
echo   or must reside in the Windows search path.
echo.
echo   Go to http://bricxcc.sourceforge.net/utilities.html
echo   and download the latest NeXTTool utility,
echo   or download BricxCC, where this tool is 
echo   already included.
echo   Then place NeXTTool.exe in this folder restart the script:
echo.
cd
echo.


goto end
:binarymissing
echo.
echo  Cannot find binary RXE file to transfer. Aborting...
echo.



goto end
:download

echo.
echo   This program downloads MotorControl22.rxe
echo   to the NXT brick. Please connect a single NXT brick
echo   via a USB cable and turn it on.
echo   Make sure Firmware 1.28 (or higher) is installed on the NXT.
echo.

pause

echo.
echo   Transferring program...

NeXTTool /COM=usb -download=MotorControl22.rxe

echo   Verifying download...
echo.
echo   If the next paragraph shows
echo  MotorControl22.rxe=xxxxx
echo   then everything worked.
echo   A blank line indicates failure!
echo.

NeXTTool /COM=usb -listfiles=MotorControl22.rxe


:end
echo.
echo Script finished.
echo.
pause