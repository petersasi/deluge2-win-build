@rem This script is Copyright 
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@cd %~dp0
@call printc info "Entering parent of this script's folder [lib]."
@cd ..

@for /D %%d in (*-build) do @mklink /D %%d\lib %~dp0 || @call %~dp0\printc error "Failed to create some links to [lib]."
