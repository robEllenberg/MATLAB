@echo off


if exist nbc.exe goto compile else goto nbcmissing


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
:compile

echo.
echo Compiling...

nbc -v=128 -O=MotorControl22.rxe MotorControl22.nxc


:end
echo.
echo Done.
echo.
pause