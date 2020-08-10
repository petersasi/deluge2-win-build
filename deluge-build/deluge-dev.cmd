@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@cd "%~dp0"
call lib\printc info "Changed to the directory of this script"

call lib\initpath

@echo Find out what is the latest python version Released
@for /f %%i in ('curl -s https://www.python.org/ ^| grep "Latest: " ^| cut -d/ -f5 ^| cut -d" " -f2 ^| tr -d "<"') do @set pythonVersion=%%i

@echo Download that python %pythonVersion%, with "curl -C -" so that download is resumed / skipped
@curl -C - -O https://www.python.org/ftp/python/%pythonVersion%/python-%pythonVersion%-amd64.exe || @echo ERROR cURL returned an error downloading the Python installer!

@echo Install python creating a Program Files\deluge folder
@python-%pythonVersion%-amd64.exe /quiet InstallAllUsers=1 Include_test=0 InstallLauncherAllUsers=0 Include_launcher=0 TargetDir="%programfiles%\deluge" || @echo ERROR Python installer returned an error!

@echo Add the freshly installed Python  to the PATH with the 8.3 filename, so that the plugin building setup.py does not fail
@set PATH=C:\PROGRA~1\deluge\Scripts;C:\PROGRA~1\deluge;%PATH%

@Echo Upgrade pip as suggested by itself when the old version is run
@python -m pip install --upgrade pip || @echo ERROR in PIP upgrade!

@echo Install Wheel to avoid buld warnings
@pip install wheel || @echo ERROR installing wheel using pip!

@echo Install additional packages necessary using pip
@pip install pycairo-1.19.1-cp38-cp38-win_amd64.whl		|| @echo ERROR installing local pycairo using pip!
@pip install PyGObject-3.36.0-cp38-cp38-win_amd64.whl	|| @echo ERROR installing local PyGObject using pip!
@pip install pygeoip									|| @echo ERROR installing PyGeoIP using pip!
@pip install future										|| @echo ERROR installing future using pip!
@pip install requests									|| @echo ERROR installing windows-curses using pip!

@echo Install windows-curses to make deluge-console usable
@pip install windows-curses || @echo ERROR installing windows-curses using pip!

@Echo Copy the installers with better windows integration into place
@copy /y ..\loaders\* "%programfiles%\Deluge\Lib\site-packages\pip\_vendor\distlib" || @echo ERROR Unable to copy the loaders!

@echo Install deluge latest dev version from git using pip
@pip install git+https://github.com/deluge-torrent/deluge

@echo Clone the deluge repo from git to build the plugins
@git clone https://github.com/deluge-torrent/deluge || @echo ERROR Cannot clone git!

cd deluge
python version.py
set /p delugeVersion=<RELEASE-VERSION

python setup.py build_plugins
copy deluge\plugins\*.egg "%programfiles%\deluge\Lib\site-packages\deluge\plugins"

call lib\printc info "Finding and downloading the latest YaRSS2 plugin"
for /f "usebackq" %%i in (`curl -s https://bitbucket.org/bendikro/deluge-yarss-plugin/downloads/^|grep "YaRSS2.*-py3\.[789]\.egg"^|head -n1^|cut -d'^"' -f2`) do curl -C - -o YaRSS2-2.x.x-py3.8.egg https://bitbucket.org%%i
copy YaRSS2-2.x.x-py3.8.egg "%programfiles%\deluge\Lib\site-packages\deluge\plugins"

cd "%~dp0"
if exist deluge rd /s /q deluge
if exist deluge rd /s /q deluge

patch "%programfiles%/deluge/Lib/site-packages/twisted/internet/_glibbase.py" < _glibbase.patch
patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/client.py" < client.patch
patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/gtk3/common.py" < common.patch
patch "%programfiles%/deluge/Lib/site-packages/deluge/core/preferencesmanager.py" < preferencesmanager.patch
patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/console/main.py" < consoleUIonWin.patch
patch "%programfiles%/deluge/Lib/site-packages/deluge/ui/console/modes/basemode.py" < consoleCommandLineOnWin.patch
curl https://github.com/deluge-torrent/deluge/commit/543a91bd9b06ceb3eee35ff4e7e8f0225ee55dc5.patch | patch -d "%programfiles%/deluge/Lib/site-packages" -p1 --no-backup-if-mismatch
patch "%programfiles%/Deluge2/Lib/site-packages/deluge/log.py" < logging.patch
patch -R "%programfiles%/deluge/Lib/site-packages/cairo/__init__.py" < pycairo_py3_8_load_dll.patch
patch -R "%programfiles%/deluge/Lib/site-packages/gi/__init__.py" < pygobject_py3_8_load_dll.patch

copy "%programfiles%\deluge\Scripts\deluge.exe" "%programfiles%\deluge"
copy "%programfiles%\deluge\Scripts\deluge-console.exe" "%programfiles%\deluge"
copy "%programfiles%\deluge\Scripts\deluged.exe" "%programfiles%\deluge"
copy "%programfiles%\deluge\Scripts\deluged-debug.exe" "%programfiles%\deluge"
copy "%programfiles%\deluge\Scripts\deluge-debug.exe" "%programfiles%\deluge"
copy "%programfiles%\deluge\Scripts\deluge-gtk.exe" "%programfiles%\deluge"
copy "%programfiles%\deluge\Scripts\deluge-web.exe" "%programfiles%\deluge"
copy "%programfiles%\deluge\Scripts\deluge-web-debug.exe" "%programfiles%\deluge"
if exist "%programfiles%\deluge\Scripts" rd /s /q "%programfiles%\deluge\Scripts"
if exist "%programfiles%\deluge\Scripts" rd /s /q "%programfiles%\deluge\Scripts"

@rem Remove the "C:\Program Files\" path from referencing the python executables for portability by search and replace in all 8 deluge executables.
python portable.py -f "%programfiles%\deluge\deluged.exe"          -s "c:\program files\deluge\python.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluged-debug.exe"    -s "c:\program files\deluge\python.exe" -r python.exe
python portable.py -f "%programfiles%\deluge\deluge-web.exe"       -s "c:\program files\deluge\python.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluge-web-debug.exe" -s "c:\program files\deluge\python.exe" -r python.exe
python portable.py -f "%programfiles%\deluge\deluge.exe"           -s "c:\program files\deluge\pythonw.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluge-debug.exe"     -s "c:\program files\deluge\python.exe" -r python.exe
python portable.py -f "%programfiles%\deluge\deluge-gtk.exe"       -s "c:\program files\deluge\pythonw.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluge-console.exe"   -s "c:\program files\deluge\python.exe" -r python.exe
@rem Need to search and replace the 8.3 names too not to contain path, just executable
python portable.py -f "%programfiles%\deluge\deluged.exe"          -s "c:\progra~1\deluge\python.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluged-debug.exe"    -s "c:\progra~1\deluge\python.exe" -r python.exe
python portable.py -f "%programfiles%\deluge\deluge-web.exe"       -s "c:\progra~1\deluge\python.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluge-web-debug.exe" -s "c:\progra~1\deluge\python.exe" -r python.exe
python portable.py -f "%programfiles%\deluge\deluge.exe"           -s "c:\progra~1\deluge\pythonw.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluge-debug.exe"     -s "c:\progra~1\deluge\python.exe" -r python.exe
python portable.py -f "%programfiles%\deluge\deluge-gtk.exe"       -s "c:\progra~1\deluge\pythonw.exe" -r pythonw.exe
python portable.py -f "%programfiles%\deluge\deluge-console.exe"   -s "c:\progra~1\deluge\python.exe" -r python.exe

python fixdeluged.py
python fixdeluge-web.py

xcopy /ehq "C:\deluge2\overlay" "%programfiles%\deluge"
@rem This is no longer necessary
@rem xcopy /ehq "C:\deluge2\themes\icons" "%programfiles%\deluge\data\share\icons\"

del "%programfiles%\deluge\Lib\site-packages\easy_install.py"
del "%programfiles%\deluge\Lib\site-packages\PyWin32.chm"

@rem Remove folders and files not used based on profiling deluge with process monitor.
@for /f "delims=" %%i in ( FilesUnusedList.txt ) do @del /f /q "%programfiles%\deluge\%%i" || @echo ERROR Cannot delete: %programfiles%\deluge\%%i
@for /f "delims=" %%i in ( FoldersUnusedList.txt ) do @rd /s /q "%programfiles%\deluge\%%i" || @echo ERROR Cannot remove folder: %programfiles%\deluge\%%i

@rem removing all directories based on a list in a file above
@rem rd /s /q "%programfiles%\deluge\Lib\site-packages\PIL"
@rem rd /s /q "%programfiles%\deluge\Lib\idlelib"
@rem rd /s /q "%programfiles%\deluge\Lib\distutils"
@rem rd /s /q "%programfiles%\deluge\Lib\site-packages\pip"
@rem rd /s /q "%programfiles%\deluge\Lib\site-packages\setuptools"
@rem rd /s /q "%programfiles%\deluge\Lib\site-packages\pythonwin"
@rem rd /s /q "%programfiles%\deluge\Doc"
@rem rd /s /q "%programfiles%\deluge\libs"
@rem rd /s /q "%programfiles%\deluge\include"
@rem rd /s /q "%programfiles%\deluge\Tools"
@rem rd /s /q "%programfiles%\deluge\tcl"

@rem I think this does the same as the next double delete with the for commands, so commented out
@rem if exist C:\deluge2\deluge-%delugeVersion%* rd /s /q C:\deluge2\deluge-%delugeVersion%*
@rem if exist C:\deluge2\deluge-%delugeVersion%* rd /s /q C:\deluge2\deluge-%delugeVersion%*

for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do rd /s /q C:\deluge2\%%i
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do rd /s /q C:\deluge2\%%i

@rem Find out the version of OpenSSL and GTK3 used
for /f %%i in ('powershell.exe "(Get-Item C:\deluge2\overlay\Lib\site-packages\libssl*.dll).VersionInfo" ^| findstr 1 ^| cut -d ' ' -f1') do set opensslVersion=%%i
for /f %%i in ('powershell.exe "(Get-Item C:\deluge2\overlay\data\bin\gtk-3*.dll).VersionInfo" ^| findstr 3 ^| cut -d ' ' -f1') do set gtkVersion=%%i
for /f %%i in ('dir /b C:\deluge2\overlay\Lib\site-packages\boost*.txt ^| sed "s/.txt//"') do set boostVersion=%%i
for /f %%i in ('dir /b C:\deluge2\overlay\Lib\site-packages\lt*.txt ^| sed "s/.txt//"') do set ltVersion=%%i

@rem Copy the "finalized" (frozen) deluge folder to our own build directory indicating versions
xcopy /ehq "%programfiles%\deluge" "C:\deluge2\deluge-%delugeVersion%-%ltVersion%-%boostVersion%-py%pythonVersion%-ossl%opensslVersion%-GTK%gtkVersion%\"

@rem Uninstall python 
python-%pythonVersion%-amd64.exe /uninstall /quiet
if exist "%programfiles%\deluge" rd /s /q "%programfiles%\deluge"
if exist "%programfiles%\deluge" rd /s /q "%programfiles%\deluge"

@rem let'a not remove so that download can be resumed / skipped on next run
@rem del python*.exe

call lib\restorepath
