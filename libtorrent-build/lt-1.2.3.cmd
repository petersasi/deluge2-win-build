@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

cd "%~dp0"
call ..\lib\initpath

curl -LO https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.7z
7z x boost_*.7z -oC:
move C:\boost_* C:\boost
set BOOST_ROOT=c:\boost
set BOOST_BUILD_PATH=%BOOST_ROOT%\tools\build
set PATH=%PATH%;%BOOST_BUILD_PATH%\src\engine\bin.ntx86;%BOOST_ROOT%;C:\python
git clone https://github.com/arvidn/libtorrent -b libtorrent-1_2_3 C:/libtorrent
for /f %%i in ('curl -s https://www.python.org/ ^| grep "Latest: " ^| cut -d/ -f5 ^| cut -d" " -f2 ^| tr -d "<"') do set var2=%%i
curl -O https://www.python.org/ftp/python/%var2%/python-%var2%-amd64.exe
python-%var2%-amd64.exe /quiet InstallAllUsers=1 Include_test=0 InstallLauncherAllUsers=0 Include_launcher=0 TargetDir=C:\python
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
cd c:\boost
call bootstrap.bat
cd "%~dp0"
patch C:/libtorrent/bindings/python/setup.py < 1.2-setup-V3.patch
cd C:\libtorrent\bindings\python
python setup.py build --bjam
md C:\deluge2\libtorrent\lt1.2.3\Lib\site-packages 2> nul
move /y libtorrent.pyd C:\deluge2\libtorrent\lt1.2.3\Lib\site-packages
cd "%~dp0"
python-%var2%-amd64.exe /uninstall /quiet
rd /s /q C:\boost
rd /s /q C:\boost 2>nul
rd /s /q C:\libtorrent
rd /s /q C:\libtorrent 2>nul
rd /s /q C:\python 2>nul
rd /s /q C:\python 2>nul
del python*.exe boost_*.7z
pause

call ..\lib\restorepath
