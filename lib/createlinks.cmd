rem This script is Copyright 
rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@echo off

cd %~dp0
call printc "INFO: Entering parent of the lib folder, where this script is supposed to be."
cd ..

for /D %%d in (*-build) ^
do mklink /D %%d\lib %~dp0
