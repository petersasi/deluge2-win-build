@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

cd "%~dp0"
set DOWNLOAD_DIR=C:\gtk-cache
set PYTHONPATH=C:\python
set MSYSPATH=C:\msys64\usr\bin

rem Save the original PATH so that it does not keep growing on many runs
set OLDPATH=%PATH%
set PATH=%PYTHONPATH%;%PYTHONPATH%\Scripts;C:\gtk-build\gtk\x64\release\bin;%MSYSPATH%;%PATH%

set platform=x64
set VS_VER=16
set VS_VCVARS=14.25
set arch=amd64
set VSCMD_DEBUG=1
for /f %%i in ('curl -s https://www.python.org/ ^| grep "Latest: " ^| cut -d/ -f5 ^| cut -d" " -f2 ^| tr -d "<"') do set var2=%%i
for /f %%i in ('echo %var2% ^| cut -d. -f1-2 ^| tr -d .') do set PYTHONVER=%%i
rem add -C - to curl so downloaded files are resumed / not downloaded again
curl -C - -O https://www.python.org/ftp/python/%var2%/python-%var2%-amd64.exe

python-%var2%-amd64.exe /quiet InstallAllUsers=1 Include_test=0 InstallLauncherAllUsers=0 Include_launcher=0 TargetDir=C:\python

rem as suggested by python itself, upgrade pip
python -m pip install --upgrade pip

cd "%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build"
call vcvars64.bat

rem turn back display of path and command lines executed for easier debugging
echo on

git clone https://github.com/wingtk/gvsbuild C:\gtk-build\github\gvsbuild
cd C:\gtk-build\github\gvsbuild
patch -p1 < "%~dp0gtk3.patch"
pip install wheel
python build.py -d build --gtk3-ver=3.24 --archives-download-dir=%DOWNLOAD_DIR% --vs-ver=%VS_VER% --platform=x64 --vs-install-path="%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --python-dir=C:\python -k --enable-gi --py-wheel --python-ver=%var2% enchant gtk3-full pycairo pygobject lz4 --skip gtksourceview3,emeus,clutter,adwaita-icon-theme --capture-out --print-out
tar -zcf gvsbuild-vs%VS_VER%-%PLATFORM%-%PYTHONVER%.tar.gz -C c:/gtk-build/gtk/x64 release
cd "%~dp0"
python-%var2%-amd64.exe /uninstall /quiet
rd /s /q C:\python
rd /s /q C:\python

rem Do not remove so that we do not have to redownload if this script is restarted
rem del python*.exe
del C:\gtk-build\gtk\x64\release\bin\*.exe
del C:\gtk-build\gtk\x64\release\bin\*.pdb
del C:\gtk-build\gtk\x64\release\\bin\gdbus-codegen
del C:\gtk-build\gtk\x64\release\\bin\g-ir-annotation-tool
del C:\gtk-build\gtk\x64\release\bin\g-ir-scanner
del C:\gtk-build\gtk\x64\release\bin\glib-genmarshal
del C:\gtk-build\gtk\x64\release\bin\glib-mkenums
del C:\gtk-build\gtk\x64\release\bin\gtester-report
del C:\gtk-build\gtk\x64\release\etc\gtk-3.0\im-multipress.conf
del C:\gtk-build\gtk\x64\release\lib\harfbuzz.lib
del C:\gtk-build\gtk\x64\release\lib\*.pdb
del C:\gtk-build\gtk\x64\release\lib\enchant\*.pdb
move /y C:\gtk-build\gtk\x64\release\python\*.whl C:\deluge2\deluge-build
rd /s /q C:\gtk-build\gtk\x64\release\include 
rd /s /q C:\gtk-build\gtk\x64\release\libexec
rd /s /q C:\gtk-build\gtk\x64\release\python
rd /s /q C:\gtk-build\gtk\x64\release\share\aclocal 
rd /s /q C:\gtk-build\gtk\x64\release\share\cogl-1.0
rd /s /q C:\gtk-build\gtk\x64\release\share\doc 
rd /s /q C:\gtk-build\gtk\x64\release\share\gettext 
rd /s /q C:\gtk-build\gtk\x64\release\share\gir-1.0 
rd /s /q C:\gtk-build\gtk\x64\release\share\gobject-introspection-1.0
rd /s /q C:\gtk-build\gtk\x64\release\share\gtk-2.0 
rd /s /q C:\gtk-build\gtk\x64\release\share\gtk-3.0
rd /s /q C:\gtk-build\gtk\x64\release\share\installed-tests 
rd /s /q C:\gtk-build\gtk\x64\release\share\man 
rd /s /q C:\gtk-build\gtk\x64\release\share\pkgconfig
rd /s /q C:\gtk-build\gtk\x64\release\share\thumbnailers
rd /s /q C:\gtk-build\gtk\x64\release\share\icons\Adwaita\cursors
del C:\gtk-build\gtk\x64\release\lib\gdk-pixbuf-2.0\2.10.0\loaders\*.pdb
del C:\gtk-build\gtk\x64\release\lib\gobject-introspection\giscanner\_giscanner.pdb
move C:\deluge2\overlay\data\bin\vcruntime140_1.dll C:\gtk-build\gtk\x64\release\bin
move C:\deluge2\overlay\data\bin\msvcp140.dll C:\gtk-build\gtk\x64\release\bin
move C:\deluge2\overlay\data\etc\gtk-3.0\settings.ini C:\gtk-build\gtk\x64\release\etc\gtk-3.0
rd /s /q C:\gtk-build\gtk\x64\release\share\icons
rd /s /q C:\gtk-build\gtk\x64\release\share\icons
move C:\deluge2\overlay\data\share\icons C:\gtk-build\gtk\x64\release\share
rd /s /q  C:\deluge2\overlay\data
rd /s /q  C:\deluge2\overlay\data
move C:\gtk-build\gtk\x64\release C:\deluge2\overlay\data

rem save the more detailed log
move C:\gtk-build\logs\gvsbuild-log.txt C:\deluge2\gvsbuild-build

rd /s /q C:\gtk-build
rd /s /q C:\gtk-build
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do rd /s /q C:\deluge2\%%i\data
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do rd /s /q C:\deluge2\%%i\data
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do rd /s /q C:\deluge2\%%i\data
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do rd /s /q C:\deluge2\%%i\data
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do xcopy /ehq C:\deluge2\overlay\data C:\deluge2\%%i\data\
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do xcopy /ehq C:\deluge2\overlay\data C:\deluge2\%%i\data\

rem Restore the original PATH so that it does not keep growing on many runs
set PATH=%OLDPATH%
