@call %~dp0\printc "Save the original PATH (to keep from growing on many runs) add MSYS2 /usr/bin to the front of the PATH"
@set OLDPATH=%PATH%
@set PATH=C:\msys64\usr\bin;%PATH%
