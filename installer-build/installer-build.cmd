@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@cd %~dp0

@goto %~1 2>NUL || (
	@echo Invalid argument: "%1"
	@echo.
	@echo To build both installers, use:
	@call lib\printc green "%~n0 all"
	@echo To build installer for the latest development version, use:
	@call lib\printc green "%~n0 dev"
	@echo To build installer for the latest released version, use:
	@call lib\printc green "%~n0 stable"
)

:all
	@call lib\printc "Calling stable build script..."
	@call %~f0 stable
	@call lib\printc "Calling dev build script..."
	@call %~f0 dev
@goto :EOF

:dev
	@call lib\printc "Building latest development version instaler:"
	@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do set sourceFolder=%%i
@goto common

:stable
	@call lib\printc "Building latest stable version instaler:"
	@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do set sourceFolder=%%i
@goto common

:common
	@call lib\initpath
	@curl https://dl.miyuru.lk/geoip/maxmind/country/maxmind4.dat.gz | "%programfiles%\7-Zip\7z" x -si -tgzip -so > C:\deluge2\%sourceFolder%\GeoIP.dat
	@"C:\Program Files (x86)\NSIS\makensis" /DPROGRAM_VERSION=%sourceFolder:~7% /Dsrcdir=C:\deluge2\%sourceFolder% C:\deluge2\nsis\packaging\win32\deluge-installer.nsi
	@call lib\restorepath
@goto :EOF