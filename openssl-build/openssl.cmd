rem This script is Copyright 
rem 2019-2020 mherz (Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
rem 2020 PeterSasi user of the Deluge Forum https://forum.deluge-torrent.org/

cd "%~dp0"

rem Save the original PATH so that it does not keep growing on many runs
set OLDPATH=%PATH%
set PATH=C:\msys64\usr\bin;%PATH%

for /f %%i in ('git ls-remote --tags https://github.com/openssl/openssl ^| grep -E 'OpenSSL_[0-9]_[0-9]_[0-9][a-z]' ^| cut -d/ -f3 ^| tr -d "^{}" ^| cut -d_ -f2-4') do set var=%%i

rem Added -C - to curl so that downloads are resumed
curl -C - -O https://slproweb.com/download/Win64OpenSSL-%var%.exe

rem Install it on this machine
Win64OpenSSL-%var%.exe /dir="C:\OpenSSL-Win64" /verysilent

rem Fish out the necessary DDLs from it and add them to our build overlay and the already built deluge folders (if any)
copy /y C:\OpenSSL-Win64\*.dll C:\deluge2\overlay\Lib\site-packages
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do copy /y C:\OpenSSL-Win64\*.dll C:\deluge2\%%i\Lib\site-packages
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do copy /y C:\OpenSSL-Win64\*.dll C:\deluge2\%%i\Lib\site-packages

rem We can keep the downloaded installer so that we resume / do not download next time
rem del Win64OpenSSL-%var%.exe

rem Restore the original PATH so that it does not keep growing on many runs
set PATH=%OLDPATH%
