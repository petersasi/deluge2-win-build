@echo off
@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

GOTO:%~1 2>NUL
if %ERRORLEVEL% neq "0" (
	echo Invalid argument: %1
	echo.
	echo To build both installers, use:
	echo %~n0  all
	echo To build installer for the latest development version, use:
	echo %~n0  dev
	echo To build installer for the latest released version, use:
	echo %~n0  stable
	goto:EOF
)

:all
	echo Calling stable build script...
	call %~f0 stable
	echo Calling dev build script...
	call %~f0 dev
goto:EOF

:dev
	echo Building latest development version instaler:
goto:EOF

:stable
	echo Building latest development version instaler:
goto:EOF

