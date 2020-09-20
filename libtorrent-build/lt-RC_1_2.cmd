@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

cd "%~dp0"
call ..\lib\initpath

@rem Prepare variables for boost building (ROOT and BUILD_PATH)
set BOOST_ROOT=c:\boost
set BOOST_BUILD_PATH=%BOOST_ROOT%\tools\build
set PATH=%PATH%;%BOOST_BUILD_PATH%\src\engine;%BOOST_ROOT%;C:\python

@rem Scrape the latest python version from the main web page
for /f %%i in ('curl -s https://www.python.org/ ^| grep "Latest: " ^| cut -d/ -f5 ^| cut -d" " -f2 ^| tr -d "<"') do set var2=%%i
@rem add -C - so that download is resumed / skipped
curl -C - -O https://www.python.org/ftp/python/%var2%/python-%var2%-amd64.exe
@rem Install the downloaded python version
python-%var2%-amd64.exe /quiet InstallAllUsers=1 Include_test=0 InstallLauncherAllUsers=0 Include_launcher=0 TargetDir=C:\python

@rem Define the boost archive to download and decompress specifically 
set BOOST_FOLDER=boost_1_73_0
set BOOST_ARCHIVE=%BOOST_FOLDER%.7z
for /f %%i in ('echo %BOOST_FOLDER% ^| sed "s/boost_//" ^| tr "_" "."') do set BOOST_VERSION=%%i

@rem add -C - so that download is resumed / skipped
curl -C - -LO https://dl.bintray.com/boostorg/release/%BOOST_VERSION%/source/%BOOST_ARCHIVE%

@rem Decompress only one specific boost archive in the folder of this script, -aos for skip extraction if file is already there
7z x -aos %BOOST_ARCHIVE% -o%~dp0

@rem try to link  the specific boost version's folder in this script's folder to C:\
mklink /d C:\boost "%~dp0\%BOOST_FOLDER%"

@rem try to get rid of many warnings to help readability - they are:
@rem Info: Boost.Config is older than your compiler version - probably nothing bad will happen - but you may wish to look for an update Boost version.  Define BOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE to suppress this message.
@rem set BOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE=1

@rem Get the latest libtorrent version from the RC_1_2 branch
git clone https://github.com/arvidn/libtorrent -b RC_1_2 C:/libtorrent
@rem Find out the version and revision of the latest libtorrent
for /f %%i in ('grep "LIBTORRENT_VERSION " c:\libtorrent\include\libtorrent\version.hpp ^| cut -d " " -f3 ^| tr -d """"') do set LIBTORRENT_VERSION=%%i

@rem seems useless, let's no keep track of LIBTORRENT_REVISION 
@rem for /f %%i in ('grep LIBTORRENT_REVISION c:\libtorrent\include\libtorrent\version.hpp ^| cut -d " " -f3 ^| tr -d """"') do set LIBTORRENT_REVISION=%%i

call "%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
@rem turn back display of path and command lines executed for easier debugging
echo on

cd c:\boost
call bootstrap.bat
@rem turn back display of path and command lines executed for easier debugging
echo on

cd "%~dp0"
patch C:/libtorrent/bindings/python/setup.py < 1.2-setup-v3.patch

cd C:\libtorrent\bindings\python
	
@rem Copy the bat file it was looking for where it is looking for it
@rem Seems te Boost B2 build system is fixed, copying is no longer necessary.
@rem copy "%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" "%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.26.28801\bin\Hostx64\vcvarsall.bat"

python setup.py build --bjam

@rem Remove the bat file we have copied around
@rem Seems te Boost B2 build system is fixed, copying is no longer necessary.
@rem del "%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.26.28801\bin\Hostx64\vcvarsall.bat"

@rem Put the freshly made libtorrent python lib in its place
copy /y libtorrent.pyd C:\deluge2\overlay\Lib\site-packages & del /f /q C:\deluge2\overlay\Lib\site-packages\boost*.txt C:\deluge2\overlay\Lib\site-packages\lt*.txt
@rem ...and save there what were the boost ad libtorrent versions used to build it
echo %BOOST_VERSION% > C:\deluge2\overlay\Lib\site-packages\boost%BOOST_VERSION%.txt

@rem seems useless, let's no keep track of LIBTORRENT_REVISION 
@rem echo %LIBTORRENT_VERSION%%LIBTORRENT_REVISION% > C:\deluge2\overlay\Lib\site-packages\libtorrent%LIBTORRENT_VERSION%%LIBTORRENT_REVISION%.txt
echo %LIBTORRENT_VERSION% > C:\deluge2\overlay\Lib\site-packages\lt%LIBTORRENT_VERSION%.txt

for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do copy /y libtorrent.pyd C:\deluge2\%%i\Lib\site-packages
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do copy /y libtorrent.pyd C:\deluge2\%%i\Lib\site-packages

cd "%~dp0"
python-%var2%-amd64.exe /uninstall /quiet
rd /s /q C:\boost
rd /s /q C:\libtorrent
rd /s /q C:\python

@rem let'a not remove so that download can be resumed / skipped on next run
@rem del python*.exe boost_*.7z

call lib\restorepath
