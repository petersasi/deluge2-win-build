@pushd "%~dp0"
@call lib\printc green "This script is Copyright"
@call lib\printc green "2019-2020 Martin Hertz (mhertz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/"
@call lib\printc green "2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/"

@goto %~1 2>NUL || (
	@call lib\printc error "Invalid argument: '%~n0 %1'"
	@echo.
	@echo To build both installers, use:
	@call lib\printc green "%~n0 all"
	@call lib\printc green "%~n0 both"
	@echo To build installer for the latest development version, use:
	@call lib\printc green "%~n0 dev"
	@echo To build installer for the latest released version, use:
	@call lib\printc green "%~n0 stable"
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
	@call lib\printc info "Building latest development version Deluge Torrent:"
	@set DelugePipURL=git+https://github.com/deluge-torrent/deluge
	@set DelugeGitClone=https://github.com/deluge-torrent/deluge
	@set BuildVersion=dev
@goto common

:stable
	@call lib\printc info "Building latest stable version Deluge Torrent:"
	@set DelugePipURL=git+https://github.com/deluge-torrent/deluge@master
	@set DelugeGitClone=https://github.com/deluge-torrent/deluge -b master
	@set BuildVersion=stable
	@set notDev=/v
@goto common

:common
@call lib\initpath

@call lib\printc info "Install (1)Python, (2)additional packages, (3)windows-curses to make deluge-console usable, (4)Twisted and service_identity it asks for from file (fails to build from PyPi), (5)PyGobject and pycairo wheels built by gvsbuild and (6)deluge from git."
@for /f %%i in ('dir /b PyGObject-*-win_amd64.whl') do @set PyGObjectFile=%%i || @call lib\printc error "PyGObject wheel not found" && exit /B 1
@for /f %%i in ('dir /b Twisted-*-win_amd64.whl')   do @set TwistedFile=%%i   || @call lib\printc error "Twisted wheel not found"   && exit /B 1
@for /f %%i in ('dir /b pycairo-*-win_amd64.whl')   do @set pycairoFile=%%i   || @call lib\printc error "Twisted wheel not found"   && exit /B 1
@call lib\initPython.cmd C:\PROGRA~1\deluge pygeoip future requests windows-curses %pycairoFile% %PyGObjectFile% %TwistedFile% %DelugePipURL% || @call %~dp0\lib\printc error "Upgrading pip and installing modules failed." && exit /B 1

@call lib\printc info "Clone the deluge repo from git to build the plugins"
@git clone %DelugeGitClone% || @call lib\printc error "Deluge git clone for plugin-bulding failed" && exit /B 1

@cd deluge
@python version.py
@set /p delugeVersion=<RELEASE-VERSION
@call %~dp0\lib\printc info "Deluge version is %delugeVersion%"

@python setup.py build_plugins || @call %~dp0\lib\printc error "Build of Deluge plugins failed" && exit /B 1
@copy deluge\plugins\*.egg "%programfiles%\deluge\Lib\site-packages\deluge\plugins"

@call %~dp0\lib\printc info "Finding and downloading the latest YaRSS2 plugin"
@for /f "usebackq" %%i in (`curl -s https://bitbucket.org/bendikro/deluge-yarss-plugin/downloads/^|grep "YaRSS2.*-py3\.[789]\.egg"^|head -n1^|cut -d'^"' -f2`) do wget -O YaRSS2-2.x.x-py3.9.egg https://bitbucket.org%%i
@copy YaRSS2-2.x.x-py3.9.egg "%programfiles%\deluge\Lib\site-packages\deluge\plugins"

@call %~dp0\lib\printc info "Removing the deluge build folder"
@cd "%~dp0"
@rd /s /q deluge
@if exist deluge rd /s /q deluge

@call %~dp0\lib\printc info "Patching files"
@if "%BuildVersion%" EQU "dev" @(
	@patch "%programfiles%/deluge/Lib/site-packages/twisted/internet/_glibbase.py" < _glibbase.patch || @call lib\printc error "Patching failed" && exit /B 1
	@patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/client.py" < client.patch || @call lib\printc error "Patching failed" && exit /B 1
	@patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/gtk3/common.py" < common.patch || @call lib\printc error "Patching failed" && exit /B 1
	@patch "%programfiles%/deluge/Lib/site-packages/deluge/core/preferencesmanager.py" < preferencesmanager.patch || @call lib\printc error "Patching failed" && exit /B 1
	@patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/console/main.py" < consoleUIonWin.patch || @call lib\printc error "Patching failed" && exit /B 1
	@patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/console/modes/basemode.py" < consoleCommandLineOnWin.patch || @call lib\printc error "Patching failed" && exit /B 1
	@curl https://github.com/deluge-torrent/deluge/commit/543a91bd9b06ceb3eee35ff4e7e8f0225ee55dc5.patch | patch -d "%programfiles%/deluge/Lib/site-packages" -p1 --no-backup-if-mismatch  || @call lib\printc error "Patching failed" && exit /B 1
	@patch "%programfiles%/deluge/Lib/site-packages/deluge/log.py" < logging.patch || @call lib\printc error "Patching failed" && exit /B 1
) else (
	patch "%programfiles%/deluge/Lib/site-packages/twisted/internet/_glibbase.py" < _glibbase.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/client.py" < client.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/i18n/util.py" < util.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/gtk3/common.py" < common.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/core/preferencesmanager.py" < preferencesmanager.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/core/torrentmanager.py" < 2.0.3-torrentmanager.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/argparserbase.py" < 2.0.3-argparserbase.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/gtk3/glade/main_window.tabs.ui" < 2.0.3-main_window.tabs.ui.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/log.py" < 2.0.3-log.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/console/main.py" < consoleUIonWin.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/console/modes/basemode.py" < consoleCommandLineOnWin.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch -d "%programfiles%/deluge/Lib/site-packages" -p1 --no-backup-if-mismatch < 543a91bd9b06ceb3eee35ff4e7e8f0225ee55dc5-fixed.patch || @call lib\printc error "Patching failed" && exit /B 1
	curl https://git.deluge-torrent.org/deluge/patch/?id=4b29436cd5eabf9af271f3fa6250cd7c91cdbc9d | patch -d "%programfiles%/deluge/Lib/site-packages" -p1 --no-backup-if-mismatch || @call lib\printc error "Patching failed" && exit /B 1
	patch "%programfiles%/deluge/Lib/site-packages/deluge/log.py" < logging.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch -R "%programfiles%/deluge/Lib/site-packages/cairo/__init__.py" < pycairo_py3_8_load_dll.patch || @call lib\printc error "Patching failed" && exit /B 1
	patch -R "%programfiles%/deluge/Lib/site-packages/gi/__init__.py" < pygobject_py3_8_load_dll.patch || @call lib\printc error "Patching failed" && exit /B 1
)

@call %~dp0\lib\printc info "Moving and portable-patching CLI (python.exe) executables to the Program Files\Deluge folder"
@for %%i in (
	"%programfiles%\deluge\Scripts\deluge-console.exe" 
	"%programfiles%\deluge\Scripts\deluge-debug.exe" 
	"%programfiles%\deluge\Scripts\deluged.exe" 
	"%programfiles%\deluge\Scripts\deluged-debug.exe" 
	"%programfiles%\deluge\Scripts\deluge-web.exe" 
	"%programfiles%\deluge\Scripts\deluge-web-debug.exe") do @(
	@python portable.py -f "%%~i" -s "c:\program files\deluge\python.exe" -r python.exe
	@python portable.py -f "%%~i" -s "c:\progra~1\deluge\python.exe"      -r python.exe
	@copy "%%~i" "%programfiles%\deluge" || @call lib\printc error "Could not copy deluge executable %%~i" && exit /B 1
)

@call %~dp0\lib\printc info "Moving and portable-patching GUI (pythonw.exe) executables to the Program Files\Deluge folder"
@for %%i in (
	"%programfiles%\deluge\Scripts\deluge.exe" 
	"%programfiles%\deluge\Scripts\deluge-gtk.exe") do @(
	@python portable.py -f "%%~i" -s "c:\program files\deluge\pythonw.exe" -r pythonw.exe
	@python portable.py -f "%%~i" -s "c:\progra~1\deluge\pythonw.exe"      -r pythonw.exe
	@copy "%%~i" "%programfiles%\deluge" || @call lib\printc error "Could not copy deluge executable %%~i" && exit /B 1
)

@python fixdeluged.py
@python fixdeluge-web.py

@call %~dp0\lib\printc info "Adding the overlay files to the install."
@xcopy /ehq "C:\deluge2\overlay" "%programfiles%\deluge"

@call lib\printc info "Remove folders and files not used based on profiling deluge with process monitor."
@call lib\cleanfilesfolders.cmd "%~dp0\FilesUnusedList.txt" "%~dp0\FoldersUnusedList.txt" "%programfiles%\deluge"

@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr %notDev% dev') do rd /s /q C:\deluge2\%%i

@call libc\printc info "Find out the version of OpenSSL and GTK3 used"
@for /f %%i in ('powershell.exe "(Get-Item C:\deluge2\overlay\Lib\site-packages\libssl*.dll).VersionInfo" ^| findstr 1 ^| cut -d ' ' -f1') do @set opensslVersion=%%i
@for /f %%i in ('powershell.exe "(Get-Item C:\deluge2\overlay\data\bin\gtk-3*.dll).VersionInfo" ^| findstr 3 ^| cut -d ' ' -f1') do @set gtkVersion=%%i
@for /f %%i in ('dir /b C:\deluge2\overlay\Lib\site-packages\boost*.txt ^| sed "s/.txt//"') do @set boostVersion=%%i
@for /f %%i in ('dir /b C:\deluge2\overlay\Lib\site-packages\lt*.txt ^| sed "s/.txt//"') do @set ltVersion=%%i

@call lib\printc success "Copy the "finalized" (frozen) deluge folder to our own build directory indicating versions"
@xcopy /ehq "%programfiles%\deluge" "C:\deluge2\deluge-%delugeVersion%-%ltVersion:~0,8%-%boostVersion:~0,9%-py%pythonVersion%-ossl%opensslVersion%-GTK%gtkVersion%\"

@call lib\removePython.cmd %PYTHONPATH%
@call lib\restorepath
@popd
