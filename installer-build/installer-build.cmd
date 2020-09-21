@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@cd %~dp0

@goto %~1 2>NUL || (
	@call lib\printc error "Invalid argument: '%~n0 %1'"
	@echo.
	@echo To build both installers, use:
	@call lib\printc green "%~n0 all"
	@echo To build installer for the latest development version, use:
	@call lib\printc green "%~n0 dev"
	@echo To build installer for the latest released version, use:
	@call lib\printc green "%~n0 stable"
)

:all
	@call lib\printc info "Calling stable build script..."
	@call %~f0 stable
	@call lib\printc info "Calling dev build script..."
	@call %~f0 dev
@goto :EOF

:dev
	@call lib\printc info "Building latest development version instaler:"
	@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do @set sourceFolder=%%i
@goto common

:stable
	@call lib\printc info "Building latest stable version instaler:"
	@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do @set sourceFolder=%%i
@goto common

:common
	@call lib\initpath

	@call lib\printc info "Downloading and unzipping latest GeoIP.dat into the source folder."
	@curl https://dl.miyuru.lk/geoip/maxmind/country/maxmind4.dat.gz | 7z x -si -tgzip -so > C:\deluge2\%sourceFolder%\GeoIP.dat
	patch "C:\deluge2\nsis\packaging\win32\deluge-win32-installer.nsi" < nsi-installer.patch
	@for /f %%i in ('curl -s https://www.python.org/ ^| grep "Latest: " ^| cut -d/ -f5 ^| cut -d" " -f2 ^| tr -d "<"') do set var2=%%i
	curl -O https://www.python.org/ftp/python/%var2%/python-%var2%-amd64.exe
	set PATH=%PATH%;C:\python
	python-%var2%-amd64.exe /quiet InstallAllUsers=1 Include_test=0 InstallLauncherAllUsers=0 Include_launcher=0 TargetDir=C:\python
	python generate-filelists.py "C:\deluge2\%sourceFolder%"
	python-%var2%-amd64.exe /uninstall /quiet
	rd /s /q C:\python 2>nul
	rd /s /q C:\python 2>nul
	@call lib\printc info "Starting NSIS build."
	@"C:\Program Files (x86)\NSIS\makensis" /DPROGRAM_VERSION=%sourceFolder:~7% /Dsrcdir=C:\deluge2\%sourceFolder% C:\deluge2\nsis\packaging\win32\deluge-installer.nsi

	@call lib\restorepath
@goto :EOF
