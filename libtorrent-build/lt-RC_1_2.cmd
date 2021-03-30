@cd "%~dp0"
@call lib\printc green "This script is Copyright:"
@call lib\printc green "2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/"
@call lib\printc green "2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/"

@call lib\printc info "Prepare variables for boost building (ROOT and BUILD_PATH) and download"
@set BOOST_ROOT=c:\boost
@set BOOST_BUILD_PATH=%BOOST_ROOT%\tools\build
@set BOOST_FOLDER=boost_1_75_0
@set BOOST_ARCHIVE=%BOOST_FOLDER%.7z
@for /f %%i in ('echo %BOOST_FOLDER% ^| sed "s/boost_//" ^| tr "_" "."') do set BOOST_VERSION=%%i

@call lib\initpath "%BOOST_BUILD_PATH%\src\engine;%BOOST_ROOT%"
@call lib\initPython.cmd C:\python

@call lib\printc info "Download boost %BOOST_VERSION%, add -C - so that download is resumed / skipped"
@curl -C - -LO https://dl.bintray.com/boostorg/release/%BOOST_VERSION%/source/%BOOST_ARCHIVE% || @call lib\printc error "Could not fetch Boost archive" && exit /B 1

@call lib\printc info "Decompress the selected version of boost archive in the folder of this script, -aos for skip extraction of files already there."
@7z x -aos %BOOST_ARCHIVE% -o%~dp0 || @call lib\printc error "Error decompressing Boost archive" && exit /B 1

@call lib\printc info "Link the specific boost version's folder in this script's folder to C:\boost"
@mklink /d C:\boost "%~dp0\%BOOST_FOLDER%" || @call lib\printc error "Could not create build link to Boost folder" && exit /B 1

@call lib\printc info "Get the latest libtorrent version from the RC_1_2 branch"
@git clone https://github.com/arvidn/libtorrent -b RC_1_2 C:/libtorrent || @call lib\printc error "Failed to clone LibTorrent from git" && exit /B 1

@for /f %%i in ('grep "LIBTORRENT_VERSION " c:\libtorrent\include\libtorrent\version.hpp ^| cut -d " " -f3 ^| tr -d """"') do @set LIBTORRENT_VERSION=%%i
@call lib\printc info "Found %LIBTORRENT_VERSION% LibTorrent version"

@call lib\printc info "Set MS Visual C build variables, turn back display of path and command lines executed for easier debugging"
@call "%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
@echo on

@call lib\printc info "Bootstrap boost"
@cd c:\boost
@call bootstrap.bat || @call %~dp0\lib\printc error "Boost b2 bootstrap failed." && exit /B 1
@echo on

@call %~dp0\lib\printc info "Start LibTorrent (and boost) build"
@cd C:\libtorrent\bindings\python
@python setup.py build_ext --b2-args="libtorrent-link=static boost-link=static variant=release toolset=msvc-14.2 crypto=openssl optimization=speed lto=on lto-mode=full" || @call %~dp0\lib\printc error "Building LibTorrent failed." && exit /B 1

@call %~dp0\lib\printc success "Copy the freshly made libtorrent python lib in its place"
@for /r %%i in (libtorrent*.pyd) do @copy /y %%i C:\deluge2\overlay\Lib\site-packages\libtorrent.pyd & @del /f /q C:\deluge2\overlay\Lib\site-packages\boost*.txt C:\deluge2\overlay\Lib\site-packages\lt*.txt || @call %~dp0\lib\printc error "Copying libtorrent.pyd to overlay folder failed." && exit /B 1

@cd "%~dp0"
@call lib\printc success "...and save the boost and libtorrent versions used to build it there."
@echo %BOOST_VERSION% > C:\deluge2\overlay\Lib\site-packages\boost%BOOST_VERSION%.txt
@echo %LIBTORRENT_VERSION% > C:\deluge2\overlay\Lib\site-packages\lt%LIBTORRENT_VERSION%.txt

@call lib\printc info "Update the present built deluge directories as weel"
@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do copy /y C:\deluge2\overlay\Lib\site-packages\libtorrent.pyd C:\deluge2\%%i\Lib\site-packages
@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do copy /y C:\deluge2\overlay\Lib\site-packages\libtorrent.pyd C:\deluge2\%%i\Lib\site-packages

@call lib\printc info "Remove LibTorrent and Boost build dirs"
@rd /s /q C:\boost
@rd /s /q C:\libtorrent
@call lib\removePython.cmd %PYTHONPATH%
@call lib\restorepath
