@rem This script is Copyright
@rem 2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@for /F "tokens=1,2 delims=#" %%a ^
in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') ^
do @set ESC=%%b

@goto %~1 2>NUL || @echo %ESC%[7m%~1%ESC%[0m

:success
	@call :initprefix SUCCESS
:green
	@shift /1
	@echo %ESC%[92m%ESC%[7m%prefixStr%%~1%ESC%[0m
@goto common

:error
	@call :initprefix ERROR
:red
	@shift /1
	@echo %ESC%[41m%prefixStr%%~1%ESC%[0m
@goto common

:info
	@call :initprefix INFO
:blue
	@shift /1
	@echo %ESC%[34m%prefixStr%%~1%ESC%[0m
@goto common

:value
	@call :initprefix VALUE
:yellow
	@shift /1
	@echo %ESC%[93m%prefixStr%%~1%ESC%[0m
@goto common

:common
	@set prefixStr=
@goto :EOF

:initprefix
	@set /A msgCounter+=1
	@set prefixStr=#%msgCounter%[%~1]:
@goto :EOF
