rem This script is Copyright 
rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@echo off

setlocal

for /F "tokens=1,2 delims=#" %%a ^
in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') ^
do set ESC=%%b

goto %~1 2>NUL || echo %ESC%[7m%~1%ESC%[0m	

:green
	shift
	echo %ESC%[92m%ESC%[7m%~1%ESC%[0m
exit /B 0

:red
	shift
	echo %ESC%[41m%~1%ESC%[0m
exit /B 0
