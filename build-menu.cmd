@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@echo off
net sess>nul 2>&1||(echo(CreateObject("Shell.Application"^).ShellExecute"%~0",,,"RunAs",1:CreateObject("Scripting.FileSystemObject"^).DeleteFile(wsh.ScriptFullName^)>"%temp%\%~nx0.vbs"&start wscript.exe "%temp%\%~nx0.vbs"&exit)
cd "%~dp0"
echo.
echo Which component(s) would you like to build?
echo.
echo 1. openssl
echo 2. libtorrent 1.1.x
echo 3. libtorrent 1.2.3
echo 4. libtorrent 1.2.x
echo 5. gtk3
echo 6. deluge-stable
echo 7. deluge-dev
echo 8. installer-stable
echo 9. installer-dev
echo.
set /p var="Enter number(s), separated by commas without space, and press return: "
for /f "delims=, tokens=1-9" %%i in ("%var%") do (
set i=%%i
set j=%%j
set k=%%k
set l=%%l
set m=%%m
set n=%%n
set o=%%o
set p=%%p
set q=%%q
)
if %i%X neq X set last=1b & goto %i%
:1b
if %j%X neq X set last=2b & goto %j%
:2b
if %k%X neq X set last=3b & goto %k%
:3b
if %l%X neq X set last=4b & goto %l%
:4b
if %m%X neq X set last=5b & goto %m%
:5b
if %n%X neq X set last=6b & goto %n%
:6b
if %o%X neq X set last=7b & goto %o%
:7b
if %p%X neq X set last=8b & goto %p%
:8b
if %q%X neq X set last=end & goto %q%
:end
pause
exit
:1
cmd /c openssl-build\openssl.cmd
goto %last%
:2
cmd /c libtorrent-build\lt-RC_1_1.cmd
goto %last%
:3
cmd /c libtorrent-build\lt-1.2.3.cmd
goto %last%
:4
cmd /c libtorrent-build\lt-RC_1_2.cmd
goto %last%
:5
cmd /c gvsbuild-build\gvsbuild.cmd
goto %last%
:6
cmd /c deluge-build\deluge-stable.cmd
goto %last%
:7
cmd /c deluge-build\deluge-dev.cmd
goto %last%
:8
cmd /c installer-build\installer-build.cmd stable
goto %last%
:9
cmd /c installer-build\installer-build.cmd dev
goto %last%
