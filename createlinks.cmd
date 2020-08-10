rem This script is Copyright 
rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@echo off

for /D %%d in (%~dp0\*-build) ^
do mklink /D %%d\lib %~dp0\lib
