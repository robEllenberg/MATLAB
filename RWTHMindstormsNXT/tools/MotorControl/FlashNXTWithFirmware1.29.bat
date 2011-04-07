@echo off

REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
REM * The program NeXTTool.exe must exist in the same folder as this file or be on the path!*  
REM * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


if not exist NeXTTool.exe goto nexttoolmissing
if not exist "LEGO_MINDSTORMS_NXT_Firmware_V1.29.rfw" goto firmwaremissing



goto flash


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
:firmwaremissing
echo.
echo   The firmware file is missing:
echo   "LEGO_MINDSTORMS_NXT_Firmware_V1.29.rfw"
echo   This file has to be in the same directory as this script
echo   or must reside in the Windows search path.
echo.
echo   Obtain the file from the internet at:
echo   http://mindstorms.lego.com/en-us/support/files/Driver.aspx#Firmware
echo   or from the NXT-G software package. If you modify this script,
echo   you can also use J. Hansens enhanced Firmware 1.28,
echo   or the NXT Retail 2.0 Firmware 1.28.
echo.
echo   Place the file in this folder and restart the script:
echo.
cd
echo.
echo   LEGO mispelled the firmware file in one of their download archives,
echo   if you downloaded   "LEGO_MINDSTORMS_NXT_Firrmware_V1.29.rfw", 
echo   rename the file to  "LEGO_MINDSTORMS_NXT_Firmware_V1.29.rfw"
echo.




goto end
:flash

echo.
echo   This program will update the NXT's firmware to version 1.29
echo   Please connect a single NXT brick via a USB cable and turn it on.
echo   This will take a bit, the NXT will make a clicking sound.
echo   If it fails, you can reset the NXT brick and/or restart the script.
echo   After a successful download the NXT should automatically boot.
echo.

pause

echo.
echo   Flashing firmware...
echo.

NeXTTool /COM=usb -firmware="LEGO_MINDSTORMS_NXT_Firmware_V1.29.rfw"


:end
echo.
echo Script finished.
pause