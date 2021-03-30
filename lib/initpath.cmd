@rem This script is Copyright
@rem 2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@call %~dp0\printc info "Save the original PATH (to keep from growing on many runs) add MSYS2 /usr/bin to the front of the PATH"
@if NOT DEFINED OLDPATH ( @set OLDPATH=%PATH% ) else call %~dp0\printc error "PATH was already saved earlier, not overwriting"

@call %~dp0\printc info "Adding MSYS2 to the front of the PATH"
@set PATH=C:\msys64\usr\bin;C:\msys64\usr\lib\p7zip;%PATH%

@if "x%~1" NEQ "x" (
	@call %~dp0\printc info "Adding build specific dir %~1 to PATH"
	@set PATH=%~1;%PATH%
) ^
else @call %~dp0\printc info "Finished, no build specific dir to add to PATH"
