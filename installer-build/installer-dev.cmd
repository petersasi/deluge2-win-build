@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

cd C:\deluge2
for /f %%i in ('dir /b deluge-2* ^| findstr dev') do set DEVFOLDER=%%i
curl https://dl.miyuru.lk/geoip/maxmind/country/maxmind4.dat.gz | "%programfiles%\7-Zip\7z" x -si -tgzip -so > %DEVFOLDER%\GeoIP.dat
"C:\Program Files (x86)\NSIS\makensis" /DPROGRAM_VERSION=%DEVFOLDER:~7% /Dsrcdir=C:\deluge2\%DEVFOLDER% C:\deluge2\nsis\packaging\win32\deluge-installer.nsi
