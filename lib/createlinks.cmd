rem This script is Copyright 
rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@echo off

cd %~dp0
call printc info "Entering parent of this script's folder [lib]."
cd ..

for /D %%d in (*-build) ^
do mklink /D %%d\lib %~dp0
