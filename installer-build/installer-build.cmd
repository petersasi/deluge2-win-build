@pushd %~dp0
@call lib\printc green "This script is Copyright"
@call lib\printc green "2019-2020 Martin Hertz (mhertz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/"
@call lib\printc green "2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/"

@goto %~1 2>NUL || (
	@call lib\printc error "Invalid argument: '%~n0 %1'"
	@echo.
	@echo To build both installers, use:
	@call lib\printc green "%~nx0 all"
	@call lib\printc green "%~nx0 both"
	@echo To build installer for the latest development version, use:
	@call lib\printc green "%~nx0 dev"
	@echo To build installer for the latest released version, use:
	@call lib\printc green "%~nx0 stable"
	@popd
)

:both
:all
	@call lib\printc info "Calling stable build script..."
	@call %~f0 stable
	@call lib\printc info "Calling dev build script..."
	@call %~f0 dev
	@popd
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
	@curl https://mailfud.org/geoip-legacy/GeoIP.dat.gz | gzip -d -c > C:\deluge2\%sourceFolder%\GeoIP.dat
	@curl https://mailfud.org/geoip-legacy/GeoIPv6.dat.gz | gzip -d -c > C:\deluge2\%sourceFolder%\GeoIPv6.dat

	@call lib\printc info "Starting NSIS build."
	@"C:\Program Files (x86)\NSIS\makensis" /DPROGRAM_VERSION=%sourceFolder:~7% /Dsrcdir=C:\deluge2\%sourceFolder% C:\deluge2\nsis\packaging\win32\deluge-installer.nsi

	@call lib\restorepath
	@popd
@goto :EOF