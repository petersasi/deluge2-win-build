rem This script is Copyright 
rem 2019-2020 mherz (Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
rem 2020 PeterSasi user of the Deluge Forum https://forum.deluge-torrent.org/

rd /s /q C:\msys64
rd /s /q C:\msys64
rd /s /q C:\gtk-cache
rd /s /q C:\gtk-cache
"C:\OpenSSL-Win64\unins000.exe" /silent
"C:\Program Files (x86)\NSIS\uninst-nsis.exe" /S
"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" /uninstall -q
rd /s /q "C:\Program Files (x86)\Microsoft Visual Studio"
rd /s /q "C:\Program Files (x86)\Microsoft Visual Studio"
